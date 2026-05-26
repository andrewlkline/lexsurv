// Phylogenetic tree builder (UPGMA and Neighbor-Joining)

export class PhyloNode {
  constructor(name = "", branchLength = 0, children = []) {
    this.id = Math.random().toString(36).substring(2, 11);
    this.name = name;
    this.branchLength = branchLength;
    this.children = children;
  }

  get isLeaf() {
    return this.children.length === 0;
  }

  get depth() {
    if (this.isLeaf) return 0;
    return Math.max(...this.children.map(c => c.branchLength + c.depth));
  }

  get leaves() {
    if (this.isLeaf) return [this];
    const leavesList = [];
    for (const child of this.children) {
      leavesList.push(...child.leaves);
    }
    return leavesList;
  }
}

// Convert similarity percentages into distances in [0, 1]
export function getDistanceMatrix(similarityPercentages) {
  return similarityPercentages.map(row => 
    row.map(val => Math.max(0.0, Math.min(1.0, (100 - val) / 100.0)))
  );
}

// Saitou & Nei 1987 Neighbor-Joining
export function buildNeighborJoining(distances, names) {
  const n0 = distances.length;
  if (n0 === 0) return null;
  if (n0 === 1) return new PhyloNode(names[0]);

  // Make deep copies of names and distances
  let nodes = names.map(name => new PhyloNode(name));
  let d = distances.map(row => [...row]);

  while (nodes.length > 2) {
    const n = nodes.length;
    // Compute row sums r[i] = sum(d[i][k] for k != i)
    const r = Array(n).fill(0);
    for (let i = 0; i < n; i++) {
      for (let j = 0; j < n; j++) {
        if (i !== j) {
          r[i] += d[i][j];
        }
      }
    }

    // Find pair (i,j) minimizing Q(i,j) = (n-2) d(i,j) - r_i - r_j
    let bestI = 0, bestJ = 1;
    let bestQ = Infinity;
    for (let i = 0; i < n; i++) {
      for (let j = i + 1; j < n; j++) {
        const q = (n - 2) * d[i][j] - r[i] - r[j];
        if (q < bestQ) {
          bestQ = q;
          bestI = i;
          bestJ = j;
        }
      }
    }

    const i = bestI;
    const j = bestJ;
    const dij = d[i][j];
    const denom = 2 * Math.max(1, n - 2);
    const diu = 0.5 * dij + (r[i] - r[j]) / denom;
    const dju = dij - diu;

    const nodeI = nodes[i];
    const nodeJ = nodes[j];
    nodeI.branchLength = Math.max(0, diu);
    nodeJ.branchLength = Math.max(0, dju);
    const u = new PhyloNode("", 0, [nodeI, nodeJ]);

    // Rebuild distance matrix, replacing i and j with u at index 0
    const newD = Array.from({ length: n - 1 }, () => Array(n - 1).fill(0));
    const newNodes = [u];
    const remaining = [];
    for (let k = 0; k < n; k++) {
      if (k !== i && k !== j) {
        remaining.push(k);
        newNodes.push(nodes[k]);
      }
    }

    for (let a = 0; a < remaining.length; a++) {
      const ka = remaining[a];
      const dau = 0.5 * (d[i][ka] + d[j][ka] - dij);
      newD[0][a + 1] = Math.max(0, dau);
      newD[a + 1][0] = Math.max(0, dau);
    }

    for (let a = 0; a < remaining.length; a++) {
      const ka = remaining[a];
      for (let b = a + 1; b < remaining.length; b++) {
        const kb = remaining[b];
        newD[a + 1][b + 1] = d[ka][kb];
        newD[b + 1][a + 1] = d[ka][kb];
      }
    }

    nodes = newNodes;
    d = newD;
  }

  // Join the last two remaining nodes
  const a = nodes[0];
  const b = nodes[1];
  const dist = d.length >= 2 ? d[0][1] : 0;
  a.branchLength = dist / 2;
  b.branchLength = dist / 2;

  return new PhyloNode("", 0, [a, b]);
}

// UPGMA Tree building
export function buildUPGMA(distances, names) {
  const n0 = distances.length;
  if (n0 === 0) return null;
  if (n0 === 1) return new PhyloNode(names[0]);

  let clusters = names.map(name => ({
    node: new PhyloNode(name),
    height: 0,
    size: 1
  }));
  let d = distances.map(row => [...row]);

  while (clusters.length > 1) {
    const n = clusters.length;
    let bestI = 0, bestJ = 1;
    let bestD = Infinity;

    for (let i = 0; i < n; i++) {
      for (let j = i + 1; j < n; j++) {
        if (d[i][j] < bestD) {
          bestD = d[i][j];
          bestI = i;
          bestJ = j;
        }
      }
    }

    const i = bestI;
    const j = bestJ;
    const height = bestD / 2;
    const ci = clusters[i];
    const cj = clusters[j];

    ci.node.branchLength = Math.max(0, height - ci.height);
    cj.node.branchLength = Math.max(0, height - cj.height);

    const mergedNode = new PhyloNode("", 0, [ci.node, cj.node]);
    const mergedCluster = {
      node: mergedNode,
      height: height,
      size: ci.size + cj.size
    };

    // Rebuild distance matrix, replacing i and j with merged at index 0
    const newD = Array.from({ length: n - 1 }, () => Array(n - 1).fill(0));
    const remaining = [];
    for (let k = 0; k < n; k++) {
      if (k !== i && k !== j) remaining.push(k);
    }

    const newClusters = [mergedCluster];
    for (const rIndex of remaining) {
      newClusters.push(clusters[rIndex]);
    }

    for (let a = 0; a < remaining.length; a++) {
      const ka = remaining[a];
      const weight = (ci.size * d[i][ka] + cj.size * d[j][ka]) / (ci.size + cj.size);
      newD[0][a + 1] = weight;
      newD[a + 1][0] = weight;
    }

    for (let a = 0; a < remaining.length; a++) {
      const ka = remaining[a];
      for (let b = a + 1; b < remaining.length; b++) {
        const kb = remaining[b];
        newD[a + 1][b + 1] = d[ka][kb];
        newD[b + 1][a + 1] = d[ka][kb];
      }
    }

    clusters = newClusters;
    d = newD;
  }

  return clusters[0].node;
}

// Convert node tree structure into Newick tree format string
export function writeNewick(root) {
  if (!root) return "";
  return formatNode(root) + ";";
}

function formatNode(node) {
  let label = "";
  if (node.isLeaf) {
    label = escapeLabel(node.name);
  } else {
    const inner = node.children.map(formatNode).join(",");
    label = `(${inner})`;
  }
  if (node.branchLength > 0) {
    return `${label}:${node.branchLength.toFixed(6)}`;
  }
  return label;
}

function escapeLabel(name) {
  const needsQuotes = /[:;,\(\)\[\]']/.test(name) || /\s/.test(name);
  if (needsQuotes) {
    return "'" + name.replace(/'/g, "''") + "'";
  }
  return name;
}
