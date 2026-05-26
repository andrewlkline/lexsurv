import SwiftUI
import UniformTypeIdentifiers

struct PhylogenyView: View {
    @ObservedObject var document: LexSurvDocument
    @State private var selectedComparisonID: Comparison.ID?
    @State private var method: PhyloMethod = .neighborJoining

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("Comparison", selection: $selectedComparisonID) {
                    Text("Select…").tag(nil as Comparison.ID?)
                    ForEach(document.workspace.comparisons) { c in
                        Text(c.name).tag(c.id as Comparison.ID?)
                    }
                }
                .frame(maxWidth: 320)
                Picker("Method", selection: $method) {
                    ForEach(PhyloMethod.allCases) { m in
                        Text(m.displayName).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
                Spacer()
                Button("Export Newick…", action: exportNewick)
                    .disabled(buildTree() == nil)
            }
            .padding(8)
            Divider()
            tree
        }
        .navigationTitle("Phylogeny")
        .onAppear {
            if selectedComparisonID == nil {
                selectedComparisonID = document.workspace.comparisons.first?.id
            }
        }
    }

    @ViewBuilder
    private var tree: some View {
        if let root = buildTree() {
            ScrollView([.horizontal, .vertical]) {
                TreeView(root: root)
                    .padding(20)
            }
        } else {
            ContentUnavailableView {
                Label("No Tree Available", systemImage: "point.3.connected.trianglepath.dotted")
            } description: {
                Text("Pick a comparison with at least two varieties.")
            }
        }
    }

    private func buildTree() -> PhyloNode? {
        guard let cID = selectedComparisonID,
              let comp = document.workspace.comparison(id: cID),
              let sID = comp.surveyID,
              let survey = document.workspace.survey(id: sID),
              let dID = survey.dictionaryID,
              let dict = document.workspace.dictionary(id: dID) else { return nil }
        let varieties = survey.varieties
        guard varieties.count >= 2 else { return nil }
        let matrix = SimilarityCalculator.matrix(survey: survey, dictionary: dict, comparison: comp)
        let d = distanceMatrix(from: matrix)
        let names = varieties.map { $0.abbreviation.isEmpty ? $0.name : $0.abbreviation }
        switch method {
        case .neighborJoining: return NeighborJoining.build(distances: d, names: names)
        case .upgma: return UPGMA.build(distances: d, names: names)
        }
    }

    private func exportNewick() {
        guard let root = buildTree() else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "nwk") ?? .plainText, .plainText]
        panel.nameFieldStringValue = "tree.nwk"
        if panel.runModal() == .OK, let url = panel.url {
            try? Newick.write(root).write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

// MARK: - Tree rendering

struct TreeView: View {
    let root: PhyloNode

    var body: some View {
        let layout = TreeLayout(root: root)
        return Canvas { context, _ in
            for edge in layout.edges {
                var path = Path()
                path.move(to: edge.from)
                path.addLine(to: edge.to)
                context.stroke(path, with: .color(.primary), lineWidth: 1.2)
            }
            for label in layout.labels {
                let text = Text(label.text)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.primary)
                context.draw(text, at: label.position, anchor: .leading)
            }
        }
        .frame(width: layout.size.width, height: layout.size.height)
    }
}

struct TreeLayout {
    struct Edge { let from: CGPoint; let to: CGPoint }
    struct Label { let position: CGPoint; let text: String }

    let edges: [Edge]
    let labels: [Label]
    let size: CGSize

    init(root: PhyloNode, leafSpacing: CGFloat = 26, width: CGFloat = 520, leftPadding: CGFloat = 12, rightPadding: CGFloat = 140) {
        let leaves = root.leaves
        let totalDepth = max(0.001, root.depth)
        var leafY: CGFloat = leafSpacing
        var leafPositions: [UUID: CGFloat] = [:]
        for leaf in leaves {
            leafPositions[leaf.id] = leafY
            leafY += leafSpacing
        }

        var edges: [Edge] = []
        var labels: [Label] = []

        func place(_ node: PhyloNode, parentX: CGFloat, accumulatedDepth: Double) -> CGFloat {
            let nodeDepth = accumulatedDepth + node.branchLength
            let nodeX = leftPadding + width * CGFloat(nodeDepth / totalDepth)
            if node.isLeaf {
                let y = leafPositions[node.id] ?? leafSpacing
                edges.append(Edge(from: CGPoint(x: parentX, y: y), to: CGPoint(x: nodeX, y: y)))
                labels.append(Label(position: CGPoint(x: nodeX + 6, y: y), text: node.name))
                return y
            }
            let childYs = node.children.map { child in
                place(child, parentX: nodeX, accumulatedDepth: nodeDepth)
            }
            let minY = childYs.min() ?? 0
            let maxY = childYs.max() ?? 0
            // vertical connector at nodeX
            edges.append(Edge(from: CGPoint(x: nodeX, y: minY), to: CGPoint(x: nodeX, y: maxY)))
            // horizontal stub to parent (skip for root which has parentX == nodeX)
            let midY = (minY + maxY) / 2
            if parentX < nodeX {
                edges.append(Edge(from: CGPoint(x: parentX, y: midY), to: CGPoint(x: nodeX, y: midY)))
            }
            return midY
        }

        _ = place(root, parentX: leftPadding, accumulatedDepth: 0)

        self.edges = edges
        self.labels = labels
        self.size = CGSize(
            width: width + leftPadding + rightPadding,
            height: leafY + leafSpacing
        )
    }
}
