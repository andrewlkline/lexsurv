import Foundation

/// A bundle of phonetic features for a single IPA segment.
/// Values are normalized to [0, 1] so feature-weighted distance is well-defined.
struct PhoneticFeatureVector: Equatable {
    var syllabic: Double = 0     // 1 = vowel, 0 = consonant
    var voice: Double = 0
    var nasal: Double = 0
    var continuant: Double = 0   // stop=0, fricative/approximant=1, vowel=1
    var lateral: Double = 0
    var aspirated: Double = 0
    var place: Double = 0        // labial=0, dental=0.15, alveolar=0.3, postalveolar=0.45,
                                 // retroflex=0.5, palatal=0.65, velar=0.8, uvular=0.9, glottal=1
    var manner: Double = 0       // stop=0, fricative=0.5, approximant=0.75, vowel=1
    var high: Double = 0         // vowel height: high=1, mid=0.5, low=0
    var back: Double = 0         // vowel backness: front=0, central=0.5, back=1
    var round: Double = 0
    var long: Double = 0

    static let gap = PhoneticFeatureVector()
}

/// Weights for ALINE-style feature-weighted distance, loosely following Kondrak (2000).
enum FeatureWeight {
    static let syllabic: Double = 5
    static let voice: Double = 10
    static let nasal: Double = 10
    static let continuant: Double = 8
    static let lateral: Double = 10
    static let aspirated: Double = 5
    static let place: Double = 40
    static let manner: Double = 50
    static let high: Double = 5
    static let back: Double = 5
    static let round: Double = 5
    static let long: Double = 1

    static let maxSubScore: Double =
        syllabic + voice + nasal + continuant + lateral + aspirated +
        place + manner + high + back + round + long

    static let gapPenalty: Double = -10
    static let openGapPenalty: Double = -15
}

enum PhoneticFeatures {
    /// Strip common IPA diacritics and length marks to a base segment for table lookup.
    static func segment(_ s: String) -> String {
        s
    }

    /// Look up the feature vector for a single IPA character/segment.
    /// Unknown segments return a zero vector so they only "match" themselves at exact equality.
    static func features(for symbol: String) -> PhoneticFeatureVector {
        if let v = table[symbol] { return v }
        // Strip common diacritics for fallback
        var stripped = symbol
        for d in ["ʰ", "ʷ", "ʲ", "ˠ", "ˤ", "ː", "ˑ", "˘", "ⁿ", "ˡ", "̃", "̥", "̩"] {
            stripped = stripped.replacingOccurrences(of: d, with: "")
        }
        return table[stripped] ?? PhoneticFeatureVector()
    }

    /// Distance between two segments in [0, maxSubScore].
    /// 0 = identical features, maxSubScore = maximally different.
    static func distance(_ a: PhoneticFeatureVector, _ b: PhoneticFeatureVector) -> Double {
        var d: Double = 0
        d += abs(a.syllabic - b.syllabic) * FeatureWeight.syllabic
        d += abs(a.voice - b.voice) * FeatureWeight.voice
        d += abs(a.nasal - b.nasal) * FeatureWeight.nasal
        d += abs(a.continuant - b.continuant) * FeatureWeight.continuant
        d += abs(a.lateral - b.lateral) * FeatureWeight.lateral
        d += abs(a.aspirated - b.aspirated) * FeatureWeight.aspirated
        d += abs(a.place - b.place) * FeatureWeight.place
        d += abs(a.manner - b.manner) * FeatureWeight.manner
        d += abs(a.high - b.high) * FeatureWeight.high
        d += abs(a.back - b.back) * FeatureWeight.back
        d += abs(a.round - b.round) * FeatureWeight.round
        d += abs(a.long - b.long) * FeatureWeight.long
        return d
    }

    /// Similarity in [-maxSubScore, +maxSubScore]: positive favors a match.
    static func similarity(_ a: String, _ b: String) -> Double {
        if a == b { return FeatureWeight.maxSubScore }
        let fa = features(for: a)
        let fb = features(for: b)
        return FeatureWeight.maxSubScore - 2 * distance(fa, fb)
    }

    // MARK: - Table

    /// Feature vectors for the IPA segments in the palette. This is a working
    /// subset — extend by appending entries here.
    static let table: [String: PhoneticFeatureVector] = {
        var t: [String: PhoneticFeatureVector] = [:]

        // Vowels: syllabic=1, continuant=1, manner=1
        func vowel(_ s: String, high: Double, back: Double, round: Double = 0, voice: Double = 1) {
            var v = PhoneticFeatureVector()
            v.syllabic = 1; v.continuant = 1; v.manner = 1
            v.voice = voice; v.high = high; v.back = back; v.round = round
            t[s] = v
        }
        // Close (high)
        vowel("i", high: 1, back: 0)
        vowel("y", high: 1, back: 0, round: 1)
        vowel("ɨ", high: 1, back: 0.5)
        vowel("ʉ", high: 1, back: 0.5, round: 1)
        vowel("ɯ", high: 1, back: 1)
        vowel("u", high: 1, back: 1, round: 1)
        vowel("ɪ", high: 0.85, back: 0)
        vowel("ʏ", high: 0.85, back: 0, round: 1)
        vowel("ʊ", high: 0.85, back: 1, round: 1)
        // Close-mid
        vowel("e", high: 0.7, back: 0)
        vowel("ø", high: 0.7, back: 0, round: 1)
        vowel("ɘ", high: 0.7, back: 0.5)
        vowel("ɵ", high: 0.7, back: 0.5, round: 1)
        vowel("ɤ", high: 0.7, back: 1)
        vowel("o", high: 0.7, back: 1, round: 1)
        // Mid / schwa
        vowel("ə", high: 0.5, back: 0.5)
        // Open-mid
        vowel("ɛ", high: 0.35, back: 0)
        vowel("œ", high: 0.35, back: 0, round: 1)
        vowel("ɜ", high: 0.35, back: 0.5)
        vowel("ɞ", high: 0.35, back: 0.5, round: 1)
        vowel("ʌ", high: 0.35, back: 1)
        vowel("ɔ", high: 0.35, back: 1, round: 1)
        // Near-open
        vowel("æ", high: 0.2, back: 0)
        vowel("ɐ", high: 0.2, back: 0.5)
        // Open (low)
        vowel("a", high: 0, back: 0)
        vowel("ɶ", high: 0, back: 0, round: 1)
        vowel("ä", high: 0, back: 0.5)
        vowel("ɑ", high: 0, back: 1)
        vowel("ɒ", high: 0, back: 1, round: 1)

        // Consonants
        func cons(_ s: String, voice: Double = 0, nasal: Double = 0, continuant: Double = 0,
                  lateral: Double = 0, place: Double, manner: Double) {
            var v = PhoneticFeatureVector()
            v.voice = voice; v.nasal = nasal; v.continuant = continuant; v.lateral = lateral
            v.place = place; v.manner = manner
            t[s] = v
        }

        // Plosives
        cons("p", place: 0.0, manner: 0)
        cons("b", voice: 1, place: 0.0, manner: 0)
        cons("t", place: 0.3, manner: 0)
        cons("d", voice: 1, place: 0.3, manner: 0)
        cons("ʈ", place: 0.5, manner: 0)
        cons("ɖ", voice: 1, place: 0.5, manner: 0)
        cons("c", place: 0.65, manner: 0)
        cons("ɟ", voice: 1, place: 0.65, manner: 0)
        cons("k", place: 0.8, manner: 0)
        cons("ɡ", voice: 1, place: 0.8, manner: 0)
        cons("q", place: 0.9, manner: 0)
        cons("ɢ", voice: 1, place: 0.9, manner: 0)
        cons("ʔ", place: 1.0, manner: 0)

        // Fricatives
        cons("ɸ", continuant: 1, place: 0.0, manner: 0.5)
        cons("β", voice: 1, continuant: 1, place: 0.0, manner: 0.5)
        cons("f", continuant: 1, place: 0.1, manner: 0.5)
        cons("v", voice: 1, continuant: 1, place: 0.1, manner: 0.5)
        cons("θ", continuant: 1, place: 0.2, manner: 0.5)
        cons("ð", voice: 1, continuant: 1, place: 0.2, manner: 0.5)
        cons("s", continuant: 1, place: 0.3, manner: 0.5)
        cons("z", voice: 1, continuant: 1, place: 0.3, manner: 0.5)
        cons("ʃ", continuant: 1, place: 0.45, manner: 0.5)
        cons("ʒ", voice: 1, continuant: 1, place: 0.45, manner: 0.5)
        cons("ʂ", continuant: 1, place: 0.5, manner: 0.5)
        cons("ʐ", voice: 1, continuant: 1, place: 0.5, manner: 0.5)
        cons("ç", continuant: 1, place: 0.65, manner: 0.5)
        cons("ʝ", voice: 1, continuant: 1, place: 0.65, manner: 0.5)
        cons("x", continuant: 1, place: 0.8, manner: 0.5)
        cons("ɣ", voice: 1, continuant: 1, place: 0.8, manner: 0.5)
        cons("χ", continuant: 1, place: 0.9, manner: 0.5)
        cons("ʁ", voice: 1, continuant: 1, place: 0.9, manner: 0.5)
        cons("ħ", continuant: 1, place: 0.95, manner: 0.5)
        cons("ʕ", voice: 1, continuant: 1, place: 0.95, manner: 0.5)
        cons("h", continuant: 1, place: 1.0, manner: 0.5)
        cons("ɦ", voice: 1, continuant: 1, place: 1.0, manner: 0.5)

        // Nasals
        cons("m", voice: 1, nasal: 1, continuant: 1, place: 0.0, manner: 0.5)
        cons("ɱ", voice: 1, nasal: 1, continuant: 1, place: 0.05, manner: 0.5)
        cons("n", voice: 1, nasal: 1, continuant: 1, place: 0.3, manner: 0.5)
        cons("ɳ", voice: 1, nasal: 1, continuant: 1, place: 0.5, manner: 0.5)
        cons("ɲ", voice: 1, nasal: 1, continuant: 1, place: 0.65, manner: 0.5)
        cons("ŋ", voice: 1, nasal: 1, continuant: 1, place: 0.8, manner: 0.5)
        cons("ɴ", voice: 1, nasal: 1, continuant: 1, place: 0.9, manner: 0.5)

        // Approximants / liquids / glides
        cons("ɾ", voice: 1, continuant: 1, place: 0.3, manner: 0.75)
        cons("r", voice: 1, continuant: 1, place: 0.3, manner: 0.75)
        cons("ʀ", voice: 1, continuant: 1, place: 0.9, manner: 0.75)
        cons("ʋ", voice: 1, continuant: 1, place: 0.1, manner: 0.75)
        cons("ɹ", voice: 1, continuant: 1, place: 0.3, manner: 0.75)
        cons("ɻ", voice: 1, continuant: 1, place: 0.5, manner: 0.75)
        cons("j", voice: 1, continuant: 1, place: 0.65, manner: 0.75)
        cons("ɰ", voice: 1, continuant: 1, place: 0.8, manner: 0.75)
        cons("l", voice: 1, continuant: 1, lateral: 1, place: 0.3, manner: 0.75)
        cons("ɭ", voice: 1, continuant: 1, lateral: 1, place: 0.5, manner: 0.75)
        cons("ʎ", voice: 1, continuant: 1, lateral: 1, place: 0.65, manner: 0.75)
        cons("ʟ", voice: 1, continuant: 1, lateral: 1, place: 0.8, manner: 0.75)
        cons("w", voice: 1, continuant: 1, place: 0.8, manner: 0.75); t["w"]?.round = 1
        cons("ɥ", voice: 1, continuant: 1, place: 0.65, manner: 0.75); t["ɥ"]?.round = 1

        return t
    }()
}
