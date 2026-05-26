import Foundation

struct SoundCorrespondencePair: Hashable {
    var a: String
    var b: String
}

struct SoundCorrespondenceResult: Identifiable {
    let pair: SoundCorrespondencePair
    let count: Int
    let examples: [String]   // gloss primaries

    var id: SoundCorrespondencePair { pair }
}

enum SoundCorrespondence {
    /// Detect recurring sound correspondences across all cognate sets in a comparison.
    /// Returns unordered (canonical) pairs sorted by descending frequency.
    static func detect(
        survey: Survey,
        dictionary: GlossDictionary,
        comparison: Comparison
    ) -> [SoundCorrespondenceResult] {
        var counts: [SoundCorrespondencePair: (count: Int, examples: Set<String>)] = [:]

        for gloss in dictionary.glosses {
            let row = comparison.judgments[gloss.id] ?? [:]
            var setsByCode: [String: [Variety]] = [:]
            for variety in survey.varieties {
                let j = row[variety.id] ?? Judgment()
                guard !j.excluded else { continue }
                for token in j.groupingTokens {
                    setsByCode[token, default: []].append(variety)
                }
            }
            for (_, vs) in setsByCode where vs.count >= 2 {
                for i in 0..<vs.count {
                    for k in (i + 1)..<vs.count {
                        let ta = vs[i].transcriptions[gloss.id]?.transcription ?? ""
                        let tb = vs[k].transcriptions[gloss.id]?.transcription ?? ""
                        guard !ta.isEmpty, !tb.isEmpty else { continue }
                        let aligned = PhoneticAlignment.align(ta, tb)
                        for (sa, sb) in zip(aligned.alignedA, aligned.alignedB) {
                            guard !(sa == "-" && sb == "-") else { continue }
                            let lo = min(sa, sb), hi = max(sa, sb)
                            let pair = SoundCorrespondencePair(a: lo, b: hi)
                            var entry = counts[pair] ?? (0, [])
                            entry.count += 1
                            entry.examples.insert(gloss.primary)
                            counts[pair] = entry
                        }
                    }
                }
            }
        }

        return counts
            .map { (pair, entry) in
                SoundCorrespondenceResult(
                    pair: pair,
                    count: entry.count,
                    examples: Array(entry.examples).sorted()
                )
            }
            .sorted { $0.count > $1.count }
    }
}
