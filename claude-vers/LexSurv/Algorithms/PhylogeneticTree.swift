import Foundation

/// A node in a phylogenetic tree.
final class PhyloNode: Identifiable {
    let id = UUID()
    var name: String        // leaf taxon name (empty for internal nodes)
    var branchLength: Double // length of the edge connecting this node to its parent
    var children: [PhyloNode]

    init(name: String = "", branchLength: Double = 0, children: [PhyloNode] = []) {
        self.name = name
        self.branchLength = branchLength
        self.children = children
    }

    var isLeaf: Bool { children.isEmpty }

    /// Maximum distance from this node to any descendant leaf (in branch-length units).
    var depth: Double {
        if isLeaf { return 0 }
        return children.map { $0.branchLength + $0.depth }.max() ?? 0
    }

    /// All leaves under this node (recursive).
    var leaves: [PhyloNode] {
        if isLeaf { return [self] }
        return children.flatMap { $0.leaves }
    }
}

enum PhyloMethod: String, CaseIterable, Identifiable {
    case neighborJoining
    case upgma

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .neighborJoining: return "Neighbor-Joining"
        case .upgma: return "UPGMA"
        }
    }
}

/// Convert pairwise similarity percentages into a distance matrix.
/// `distance = (100 - percent) / 100` so distances live in [0, 1].
func distanceMatrix(from similarity: [[PairSimilarity]]) -> [[Double]] {
    similarity.map { row in
        row.map { pair in
            max(0.0, min(1.0, Double(100 - pair.percent) / 100.0))
        }
    }
}

// MARK: - Neighbor Joining

enum NeighborJoining {
    /// Saitou & Nei 1987. Returns an unrooted tree rendered as a rooted tree at the final star.
    static func build(distances input: [[Double]], names: [String]) -> PhyloNode {
        precondition(input.count == names.count, "Names count must match matrix size")
        let n0 = input.count
        guard n0 > 1 else {
            return PhyloNode(name: names.first ?? "")
        }

        // Mutable list of active nodes and the current distance matrix.
        var nodes: [PhyloNode] = names.map { PhyloNode(name: $0) }
        var d: [[Double]] = input

        while nodes.count > 2 {
            let n = nodes.count
            // Compute row sums r_i = Σ_k d[i][k]
            var r = Array(repeating: 0.0, count: n)
            for i in 0..<n {
                for j in 0..<n where j != i {
                    r[i] += d[i][j]
                }
            }
            // Find the pair (i,j) minimizing Q(i,j) = (n-2) d(i,j) - r_i - r_j
            var bestI = 0, bestJ = 1
            var bestQ = Double.greatestFiniteMagnitude
            for i in 0..<n {
                for j in (i+1)..<n {
                    let q = Double(n - 2) * d[i][j] - r[i] - r[j]
                    if q < bestQ {
                        bestQ = q
                        bestI = i
                        bestJ = j
                    }
                }
            }
            let i = bestI, j = bestJ
            let dij = d[i][j]
            let denom = Double(2 * max(1, n - 2))
            let diu = 0.5 * dij + (r[i] - r[j]) / denom
            let dju = dij - diu

            let nodeI = nodes[i]
            let nodeJ = nodes[j]
            nodeI.branchLength = max(0, diu)
            nodeJ.branchLength = max(0, dju)
            let u = PhyloNode(children: [nodeI, nodeJ])

            // Rebuild a new distance row/column for u, dropping i and j.
            var newD = Array(repeating: Array(repeating: 0.0, count: n - 1), count: n - 1)
            var newNodes: [PhyloNode] = []
            newNodes.reserveCapacity(n - 1)
            // The new node will be index 0; original indices excluding i, j follow.
            newNodes.append(u)
            let remaining = (0..<n).filter { $0 != i && $0 != j }
            for k in remaining {
                newNodes.append(nodes[k])
            }
            for (a, ka) in remaining.enumerated() {
                let dau = 0.5 * (d[i][ka] + d[j][ka] - dij)
                newD[0][a + 1] = max(0, dau)
                newD[a + 1][0] = max(0, dau)
            }
            for (a, ka) in remaining.enumerated() {
                for (b, kb) in remaining.enumerated() where b > a {
                    newD[a + 1][b + 1] = d[ka][kb]
                    newD[b + 1][a + 1] = d[ka][kb]
                }
            }
            nodes = newNodes
            d = newD
        }

        // Two nodes left — join them under a root with the remaining edge.
        let a = nodes[0]
        let b = nodes[1]
        let dist = d.count >= 2 ? d[0][1] : 0
        a.branchLength = dist / 2
        b.branchLength = dist / 2
        return PhyloNode(children: [a, b])
    }
}

// MARK: - UPGMA

enum UPGMA {
    static func build(distances input: [[Double]], names: [String]) -> PhyloNode {
        precondition(input.count == names.count, "Names count must match matrix size")
        guard !names.isEmpty else { return PhyloNode() }

        struct Cluster {
            var node: PhyloNode
            var height: Double
            var size: Int
        }

        var clusters: [Cluster] = names.map { Cluster(node: PhyloNode(name: $0), height: 0, size: 1) }
        var d: [[Double]] = input

        while clusters.count > 1 {
            let n = clusters.count
            var bestI = 0, bestJ = 1
            var bestD = Double.greatestFiniteMagnitude
            for i in 0..<n {
                for j in (i+1)..<n {
                    if d[i][j] < bestD {
                        bestD = d[i][j]
                        bestI = i
                        bestJ = j
                    }
                }
            }
            let i = bestI, j = bestJ
            let height = bestD / 2
            let ci = clusters[i], cj = clusters[j]
            ci.node.branchLength = max(0, height - ci.height)
            cj.node.branchLength = max(0, height - cj.height)
            let merged = Cluster(
                node: PhyloNode(children: [ci.node, cj.node]),
                height: height,
                size: ci.size + cj.size
            )

            // Build new distance matrix replacing i, j with merged at index 0.
            var newD = Array(repeating: Array(repeating: 0.0, count: n - 1), count: n - 1)
            let remaining = (0..<n).filter { $0 != i && $0 != j }
            var newClusters: [Cluster] = [merged]
            newClusters.append(contentsOf: remaining.map { clusters[$0] })

            for (a, ka) in remaining.enumerated() {
                let weight = (Double(ci.size) * d[i][ka] + Double(cj.size) * d[j][ka])
                    / Double(ci.size + cj.size)
                newD[0][a + 1] = weight
                newD[a + 1][0] = weight
            }
            for (a, ka) in remaining.enumerated() {
                for (b, kb) in remaining.enumerated() where b > a {
                    newD[a + 1][b + 1] = d[ka][kb]
                    newD[b + 1][a + 1] = d[ka][kb]
                }
            }
            clusters = newClusters
            d = newD
        }

        return clusters[0].node
    }
}

// MARK: - Newick

enum Newick {
    static func write(_ root: PhyloNode) -> String {
        formatNode(root) + ";"
    }

    private static func formatNode(_ node: PhyloNode) -> String {
        let label: String
        if node.isLeaf {
            label = escapeLabel(node.name)
        } else {
            let inner = node.children.map(formatNode).joined(separator: ",")
            label = "(\(inner))"
        }
        if node.branchLength > 0 {
            return "\(label):\(formatNumber(node.branchLength))"
        }
        return label
    }

    private static func escapeLabel(_ name: String) -> String {
        let needsQuotes = name.contains(where: { ":,;()[]'".contains($0) || $0.isWhitespace })
        if needsQuotes {
            return "'" + name.replacingOccurrences(of: "'", with: "''") + "'"
        }
        return name
    }

    private static func formatNumber(_ x: Double) -> String {
        String(format: "%.6f", x)
    }
}
