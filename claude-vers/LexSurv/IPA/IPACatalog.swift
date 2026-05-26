import Foundation

enum IPACategory: String, CaseIterable, Identifiable {
    case vowels = "Vowels"
    case plosives = "Plosives"
    case fricatives = "Fricatives"
    case nasals = "Nasals"
    case other = "Other"

    var id: String { rawValue }

    var characters: [String] {
        switch self {
        case .vowels:
            return ["i", "y", "ɨ", "ʉ", "ɯ", "u", "ɪ", "ʏ", "ʊ",
                    "e", "ø", "ɘ", "ɵ", "ɤ", "o", "ə",
                    "ɛ", "œ", "ɜ", "ɞ", "ʌ", "ɔ",
                    "æ", "ɐ",
                    "a", "ɶ", "ä", "ɑ", "ɒ"]
        case .plosives:
            return ["p", "b", "t", "d", "ʈ", "ɖ", "c", "ɟ",
                    "k", "ɡ", "q", "ɢ", "ʔ"]
        case .fricatives:
            return ["ɸ", "β", "f", "v", "θ", "ð", "s", "z",
                    "ʃ", "ʒ", "ʂ", "ʐ", "ç", "ʝ",
                    "x", "ɣ", "χ", "ʁ", "ħ", "ʕ", "h", "ɦ"]
        case .nasals:
            return ["m", "ɱ", "n", "ɳ", "ɲ", "ŋ", "ɴ"]
        case .other:
            return ["ɾ", "r", "ʀ", "ʋ", "ɹ", "ɻ", "j", "ɰ",
                    "l", "ɭ", "ʎ", "ʟ", "w", "ɥ",
                    "ɓ", "ɗ", "ʄ", "ɠ", "ʛ",
                    "ʘ", "ǀ", "ǃ", "ǂ", "ǁ",
                    "ʰ", "ʷ", "ʲ", "ˠ", "ˤ", "ⁿ", "ˡ",
                    "ˈ", "ˌ", "ː", "ˑ", "˘",
                    ".", "|", "‖", "‿", "͡", "͜"]
        }
    }
}
