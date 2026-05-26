import { align } from './phonetics.js';

/**
 * Automatically mine recurring sound correspondences from a comparison dataset.
 * It identifies varieties grouped under the same cognate/similarity code for each gloss,
 * aligns their transcriptions pairwise, and logs aligned phone segment correspondences.
 */
export function detectCorrespondences(survey, dictionary, comparison) {
  const counts = {}; // key: "sa|sb" -> { pair: {a, b}, count, examples: Set }

  for (const gloss of dictionary.glosses) {
    const row = comparison.judgments[gloss.id] || {};
    const setsByCode = {};

    // Group varieties by their grouping characters for this gloss
    for (const variety of survey.varieties) {
      const j = row[variety.id] || {};
      if (j.excluded) continue;

      const groupingStr = j.groupingChar || '';
      const tokens = groupingStr.split(/\s+/).filter(x => x);
      for (const token of tokens) {
        if (!setsByCode[token]) {
          setsByCode[token] = [];
        }
        setsByCode[token].push(variety);
      }
    }

    // Perform pairwise alignments within each grouping set
    for (const code in setsByCode) {
      const vs = setsByCode[code];
      if (vs.length < 2) continue;

      for (let i = 0; i < vs.length; i++) {
        for (let k = i + 1; k < vs.length; k++) {
          const ta = vs[i].transcriptions[gloss.id]?.transcription || '';
          const tb = vs[k].transcriptions[gloss.id]?.transcription || '';
          if (!ta || !tb) continue;

          const aligned = align(ta, tb);
          const len = aligned.alignedA.length;
          for (let m = 0; m < len; m++) {
            const sa = aligned.alignedA[m];
            const sb = aligned.alignedB[m];
            if (sa === '-' && sb === '-') continue;

            // Establish a canonical unordered pair (lexicographically sorted)
            const lo = sa < sb ? sa : sb;
            const hi = sa < sb ? sb : sa;
            const key = `${lo}|${hi}`;

            if (!counts[key]) {
              counts[key] = {
                pair: { a: lo, b: hi },
                count: 0,
                examples: new Set()
              };
            }
            counts[key].count += 1;
            counts[key].examples.add(gloss.primary);
          }
        }
      }
    }
  }

  // Convert the count map to a sorted list of correspondence objects
  return Object.values(counts)
    .map(entry => ({
      pair: entry.pair,
      count: entry.count,
      examples: Array.from(entry.examples).sort()
    }))
    .sort((a, b) => b.count - a.count);
}
