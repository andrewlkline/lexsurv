import Foundation

struct PairSimilarity: Hashable {
    var tally: Int
    var total: Int

    var percent: Int {
        guard total > 0 else { return 0 }
        return Int((Double(tally) / Double(total) * 100).rounded())
    }
}

enum SimilarityCalculator {
    /// Compute pairwise similarity for every pair of varieties in the survey,
    /// using the comparison's groupings and exclusions.
    /// Returns a square matrix indexed by `survey.varieties` order. Diagonal is `total = countOfGlossesPresent, tally = same`.
    static func matrix(survey: Survey, dictionary: GlossDictionary, comparison: Comparison) -> [[PairSimilarity]] {
        let varieties = survey.varieties
        let n = varieties.count
        var result = Array(repeating: Array(repeating: PairSimilarity(tally: 0, total: 0), count: n), count: n)
        guard n > 0 else { return result }

        for i in 0..<n {
            for j in 0..<n {
                if i == j {
                    result[i][j] = PairSimilarity(tally: 0, total: 0)
                } else if j < i {
                    result[i][j] = result[j][i]
                } else {
                    result[i][j] = pair(
                        a: varieties[i],
                        b: varieties[j],
                        glosses: dictionary.glosses,
                        comparison: comparison
                    )
                }
            }
        }
        return result
    }

    static func pair(a: Variety, b: Variety, glosses: [Gloss], comparison: Comparison) -> PairSimilarity {
        var tally = 0
        var total = 0

        for gloss in glosses {
            let ja = comparison.judgment(gloss: gloss.id, variety: a.id)
            let jb = comparison.judgment(gloss: gloss.id, variety: b.id)

            if ja.excluded || jb.excluded { continue }

            let ta = a.transcriptions[gloss.id]
            let tb = b.transcriptions[gloss.id]

            let aHas = (ta?.isEmpty == false) || ja.hasGrouping
            let bHas = (tb?.isEmpty == false) || jb.hasGrouping
            guard aHas, bHas else { continue }

            total += 1

            let aTokens = Set(ja.groupingTokens)
            let bTokens = Set(jb.groupingTokens)
            if !aTokens.isEmpty && !bTokens.isEmpty && !aTokens.isDisjoint(with: bTokens) {
                tally += 1
            }
        }
        return PairSimilarity(tally: tally, total: total)
    }
}

extension Variety {
    /// Number of glosses with a non-empty transcription.
    func transcribedCount(in dict: GlossDictionary) -> Int {
        dict.glosses.reduce(0) { acc, g in
            acc + ((transcriptions[g.id]?.isEmpty == false) ? 1 : 0)
        }
    }
}
