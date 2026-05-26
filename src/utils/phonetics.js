// Condrak ALINE-style phonetic similarity module

class PhoneticFeatureVector {
  constructor(init = {}) {
    this.syllabic = init.syllabic || 0;    // 1 = vowel, 0 = consonant
    this.voice = init.voice || 0;
    this.nasal = init.nasal || 0;
    this.continuant = init.continuant || 0; // stop=0, fricative/approximant=1, vowel=1
    this.lateral = init.lateral || 0;
    this.aspirated = init.aspirated || 0;
    this.place = init.place || 0;          // labial=0, dental=0.15, alveolar=0.3, postalveolar=0.45,
                                           // retroflex=0.5, palatal=0.65, velar=0.8, uvular=0.9, glottal=1
    this.manner = init.manner || 0;        // stop=0, fricative=0.5, approximant=0.75, vowel=1
    this.high = init.high || 0;            // vowel height: high=1, mid=0.5, low=0
    this.back = init.back || 0;            // vowel backness: front=0, central=0.5, back=1
    this.round = init.round || 0;
    this.long = init.long || 0;
  }
}

export const FeatureWeight = {
  syllabic: 5,
  voice: 10,
  nasal: 10,
  continuant: 8,
  lateral: 10,
  aspirated: 5,
  place: 40,
  manner: 50,
  high: 5,
  back: 5,
  round: 5,
  long: 1,
  
  get maxSubScore() {
    return this.syllabic + this.voice + this.nasal + this.continuant + this.lateral + this.aspirated +
           this.place + this.manner + this.high + this.back + this.round + this.long;
  },
  gapPenalty: -10
};

// Compile phonetic segments table
const table = {};

function vowel(s, high, back, round = 0, voice = 1) {
  table[s] = new PhoneticFeatureVector({
    syllabic: 1, continuant: 1, manner: 1,
    voice, high, back, round
  });
}

function cons(s, voice = 0, nasal = 0, continuant = 0, lateral = 0, place = 0, manner = 0) {
  table[s] = new PhoneticFeatureVector({
    voice, nasal, continuant, lateral, place, manner
  });
}

// Close (high) vowels
vowel("i", 1, 0);
vowel("y", 1, 0, 1);
vowel("ɨ", 1, 0.5);
vowel("ʉ", 1, 0.5, 1);
vowel("ɯ", 1, 1);
vowel("u", 1, 1, 1);
vowel("ɪ", 0.85, 0);
vowel("ʏ", 0.85, 0, 1);
vowel("ʊ", 0.85, 1, 1);
// Close-mid
vowel("e", 0.7, 0);
vowel("ø", 0.7, 0, 1);
vowel("ɘ", 0.7, 0.5);
vowel("ɵ", 0.7, 0.5, 1);
vowel("ɤ", 0.7, 1);
vowel("o", 0.7, 1, 1);
// Mid / schwa
vowel("ə", 0.5, 0.5);
// Open-mid
vowel("ɛ", 0.35, 0);
vowel("œ", 0.35, 0, 1);
vowel("ɜ", 0.35, 0.5);
vowel("ɞ", 0.35, 0.5, 1);
vowel("ʌ", 0.35, 1);
vowel("ɔ", 0.35, 1, 1);
// Near-open
vowel("æ", 0.2, 0);
vowel("ɐ", 0.2, 0.5);
// Open (low)
vowel("a", 0, 0);
vowel("ɶ", 0, 0, 1);
vowel("ä", 0, 0.5);
vowel("ɑ", 0, 1);
vowel("ɒ", 0, 1, 1);

// Plosives
cons("p", 0, 0, 0, 0, 0.0, 0);
cons("b", 1, 0, 0, 0, 0.0, 0);
cons("t", 0, 0, 0, 0, 0.3, 0);
cons("d", 1, 0, 0, 0, 0.3, 0);
cons("ʈ", 0, 0, 0, 0, 0.5, 0);
cons("ɖ", 1, 0, 0, 0, 0.5, 0);
cons("c", 0, 0, 0, 0, 0.65, 0);
cons("ɟ", 1, 0, 0, 0, 0.65, 0);
cons("k", 0, 0, 0, 0, 0.8, 0);
cons("ɡ", 1, 0, 0, 0, 0.8, 0);
cons("q", 0, 0, 0, 0, 0.9, 0);
cons("ɢ", 1, 0, 0, 0, 0.9, 0);
cons("ʔ", 0, 0, 0, 0, 1.0, 0);

// Fricatives
cons("ɸ", 0, 0, 1, 0, 0.0, 0.5);
cons("β", 1, 0, 1, 0, 0.0, 0.5);
cons("f", 0, 0, 1, 0, 0.1, 0.5);
cons("v", 1, 0, 1, 0, 0.1, 0.5);
cons("θ", 0, 0, 1, 0, 0.2, 0.5);
cons("ð", 1, 0, 1, 0, 0.2, 0.5);
cons("s", 0, 0, 1, 0, 0.3, 0.5);
cons("z", 1, 0, 1, 0, 0.3, 0.5);
cons("ʃ", 0, 0, 1, 0, 0.45, 0.5);
cons("ʒ", 1, 0, 1, 0, 0.45, 0.5);
cons("ʂ", 0, 0, 1, 0, 0.5, 0.5);
cons("ʐ", 1, 0, 1, 0, 0.5, 0.5);
cons("ç", 0, 0, 1, 0, 0.65, 0.5);
cons("ʝ", 1, 0, 1, 0, 0.65, 0.5);
cons("x", 0, 0, 1, 0, 0.8, 0.5);
cons("ɣ", 1, 0, 1, 0, 0.8, 0.5);
cons("χ", 0, 0, 1, 0, 0.9, 0.5);
cons("ʁ", 1, 0, 1, 0, 0.9, 0.5);
cons("ħ", 0, 0, 1, 0, 0.95, 0.5);
cons("ʕ", 1, 0, 1, 0, 0.95, 0.5);
cons("h", 0, 0, 1, 0, 1.0, 0.5);
cons("ɦ", 1, 0, 1, 0, 1.0, 0.5);

// Nasals
cons("m", 1, 1, 1, 0, 0.0, 0.5);
cons("ɱ", 1, 1, 1, 0, 0.05, 0.5);
cons("n", 1, 1, 1, 0, 0.3, 0.5);
cons("ɳ", 1, 1, 1, 0, 0.5, 0.5);
cons("ɲ", 1, 1, 1, 0, 0.65, 0.5);
cons("ŋ", 1, 1, 1, 0, 0.8, 0.5);
cons("ɴ", 1, 1, 1, 0, 0.9, 0.5);

// Approximants / liquids / glides
cons("ɾ", 1, 0, 1, 0, 0.3, 0.75);
cons("r", 1, 0, 1, 0, 0.3, 0.75);
cons("ʀ", 1, 0, 1, 0, 0.9, 0.75);
cons("ʋ", 1, 0, 1, 0, 0.1, 0.75);
cons("ɹ", 1, 0, 1, 0, 0.3, 0.75);
cons("ɻ", 1, 0, 1, 0, 0.5, 0.75);
cons("j", 1, 0, 1, 0, 0.65, 0.75);
cons("ɰ", 1, 0, 1, 0, 0.8, 0.75);
cons("l", 1, 0, 1, 1, 0.3, 0.75);
cons("ɭ", 1, 0, 1, 1, 0.5, 0.75);
cons("ʎ", 1, 0, 1, 1, 0.65, 0.75);
cons("ʟ", 1, 0, 1, 1, 0.8, 0.75);
cons("w", 1, 0, 1, 0, 0.8, 0.75);
if (table["w"]) table["w"].round = 1;
cons("ɥ", 1, 0, 1, 0, 0.65, 0.75);
if (table["ɥ"]) table["ɥ"].round = 1;

export function tokenize(s) {
  const modifiers = new Set([
    "ʰ", "ʷ", "ʲ", "ˠ", "ˤ", "ː", "ˑ", "˘", "ⁿ", "ˡ",
    "̃", "̥", "̩", "̪", "̺", "̻", "̬", "̊", "͡", "͜"
  ]);
  const out = [];
  let current = "";
  for (const ch of s) {
    if (/\s/.test(ch)) continue;
    if (modifiers.has(ch)) {
      current += ch;
    } else {
      if (current) {
        out.push(current);
      }
      current = ch;
    }
  }
  if (current) out.push(current);
  return out;
}

export function getFeatures(symbol) {
  if (table[symbol]) return table[symbol];
  // Strip common diacritics for fallback
  let stripped = symbol;
  const diacritics = ["ʰ", "ʷ", "ʲ", "ˠ", "ˤ", "ː", "ˑ", "˘", "ⁿ", "ˡ", "̃", "̥", "̩"];
  for (const d of diacritics) {
    stripped = stripped.split(d).join("");
  }
  return table[stripped] || new PhoneticFeatureVector();
}

export function distance(a, b) {
  let d = 0;
  d += Math.abs(a.syllabic - b.syllabic) * FeatureWeight.syllabic;
  d += Math.abs(a.voice - b.voice) * FeatureWeight.voice;
  d += Math.abs(a.nasal - b.nasal) * FeatureWeight.nasal;
  d += Math.abs(a.continuant - b.continuant) * FeatureWeight.continuant;
  d += Math.abs(a.lateral - b.lateral) * FeatureWeight.lateral;
  d += Math.abs(a.aspirated - b.aspirated) * FeatureWeight.aspirated;
  d += Math.abs(a.place - b.place) * FeatureWeight.place;
  d += Math.abs(a.manner - b.manner) * FeatureWeight.manner;
  d += Math.abs(a.high - b.high) * FeatureWeight.high;
  d += Math.abs(a.back - b.back) * FeatureWeight.back;
  d += Math.abs(a.round - b.round) * FeatureWeight.round;
  d += Math.abs(a.long - b.long) * FeatureWeight.long;
  return d;
}

export function similarity(a, b) {
  if (a === b) return FeatureWeight.maxSubScore;
  const fa = getFeatures(a);
  const fb = getFeatures(b);
  return FeatureWeight.maxSubScore - 2 * distance(fa, fb);
}

export function align(a, b) {
  const A = tokenize(a);
  const B = tokenize(b);
  const n = A.count || A.length;
  const m = B.count || B.length;

  if (n === 0 && m === 0) {
    return { alignedA: [], alignedB: [], score: 0, normalizedSimilarity: 0 };
  }

  // Create DP matrix
  const dp = Array.from({ length: n + 1 }, () => Array(m + 1).fill(0));
  const trace = Array.from({ length: n + 1 }, () => Array(m + 1).fill(0));

  for (let i = 1; i <= n; i++) {
    dp[i][0] = dp[i - 1][0] + FeatureWeight.gapPenalty;
    trace[i][0] = 1;
  }
  for (let j = 1; j <= m; j++) {
    dp[0][j] = dp[0][j - 1] + FeatureWeight.gapPenalty;
    trace[0][j] = 2;
  }

  for (let i = 1; i <= n; i++) {
    for (let j = 1; j <= m; j++) {
      const subScore = similarity(A[i - 1], B[j - 1]);
      const diag = dp[i - 1][j - 1] + subScore;
      const up = dp[i - 1][j] + FeatureWeight.gapPenalty;
      const left = dp[i][j - 1] + FeatureWeight.gapPenalty;

      if (diag >= up && diag >= left) {
        dp[i][j] = diag;
        trace[i][j] = 0; // diagonal
      } else if (up >= left) {
        dp[i][j] = up;
        trace[i][j] = 1; // up
      } else {
        dp[i][j] = left;
        trace[i][j] = 2; // left
      }
    }
  }

  let i = n, j = m;
  const outA = [];
  const outB = [];

  while (i > 0 || j > 0) {
    const t = trace[i][j];
    if (i > 0 && j > 0 && t === 0) {
      outA.push(A[i - 1]);
      outB.push(B[j - 1]);
      i--; j--;
    } else if (i > 0 && (j === 0 || t === 1)) {
      outA.push(A[i - 1]);
      outB.push("-");
      i--;
    } else {
      outA.push("-");
      outB.push(B[j - 1]);
      j--;
    }
  }

  outA.reverse();
  outB.reverse();

  const score = dp[n][m];
  const maxLen = Math.max(outA.length, 1);
  const normalizedSimilarity = score / (FeatureWeight.maxSubScore * maxLen);

  return {
    alignedA: outA,
    alignedB: outB,
    score,
    normalizedSimilarity
  };
}

// Agglomerative single-linkage clustering using Union-Find
export function suggestGroupings(forms, type = 'similarity') {
  const n = forms.length;
  if (n === 0) return [];

  // Initialize Union-Find
  const parent = Array.from({ length: n }, (_, idx) => idx);
  function find(x) {
    let r = x;
    while (parent[r] !== r) {
      parent[r] = parent[parent[r]];
      r = parent[r];
    }
    return r;
  }
  function union(a, b) {
    const ra = find(a);
    const rb = find(b);
    if (ra !== rb) {
      parent[ra] = rb;
    }
  }

  // Determine comparison logic and threshold
  if (type === 'identical') {
    // Exact match grouping
    for (let i = 0; i < n; i++) {
      const cleanI = forms[i].replace(/\s+/g, '');
      for (let j = i + 1; j < n; j++) {
        const cleanJ = forms[j].replace(/\s+/g, '');
        if (cleanI && cleanJ && cleanI === cleanJ) {
          union(i, j);
        }
      }
    }
  } else {
    // Phonetic alignment grouping
    const threshold = type === 'similarity' ? 0.50 : 0.40;
    for (let i = 0; i < n; i++) {
      for (let j = i + 1; j < n; j++) {
        const formI = forms[i];
        const formJ = forms[j];
        if (formI && formJ) {
          const alignment = align(formI, formJ);
          if (alignment.normalizedSimilarity >= threshold) {
            union(i, j);
          }
        }
      }
    }
  }

  // Map each root cluster representation to a letter label (a, b, c, ..., aa, ab, ...)
  const rootLabel = {};
  let counter = 0;
  const labels = [];

  for (let i = 0; i < n; i++) {
    const r = find(i);
    if (rootLabel[r] !== undefined) {
      labels.push(rootLabel[r]);
    } else {
      const lbl = getClusterLabel(counter);
      counter++;
      rootLabel[r] = lbl;
      labels.push(lbl);
    }
  }

  return labels;
}

function getClusterLabel(num) {
  let n = num;
  let s = "";
  do {
    const r = n % 26;
    s = String.fromCharCode(97 + r) + s;
    n = Math.floor(n / 26) - 1;
  } while (n >= 0);
  return s;
}
