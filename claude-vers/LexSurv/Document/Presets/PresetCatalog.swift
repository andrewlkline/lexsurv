import Foundation

enum PresetCatalog {
    case swadesh100
    case swadesh207
    case leipzigJakarta100

    var glosses: [Gloss] {
        switch self {
        case .swadesh100: return Self.swadesh100List.map { Gloss(primary: $0) }
        case .swadesh207: return Self.swadesh207List.map { Gloss(primary: $0) }
        case .leipzigJakarta100: return Self.leipzigJakarta100List.map { Gloss(primary: $0) }
        }
    }

    static let swadesh100List: [String] = [
        "I", "you (singular)", "we", "this", "that", "who", "what", "not", "all", "many",
        "one", "two", "big", "long", "small", "woman", "man", "person", "fish", "bird",
        "dog", "louse", "tree", "seed", "leaf", "root", "bark", "skin", "flesh", "blood",
        "bone", "grease", "egg", "horn", "tail", "feather", "hair", "head", "ear", "eye",
        "nose", "mouth", "tooth", "tongue", "fingernail", "foot", "knee", "hand", "belly", "neck",
        "breast", "heart", "liver", "drink", "eat", "bite", "see", "hear", "know", "sleep",
        "die", "kill", "swim", "fly", "walk", "come", "lie", "sit", "stand", "give",
        "say", "sun", "moon", "star", "water", "rain", "stone", "sand", "earth", "cloud",
        "smoke", "fire", "ash", "burn", "path", "mountain", "red", "green", "yellow", "white",
        "black", "night", "hot", "cold", "full", "new", "good", "round", "dry", "name"
    ]

    static let swadesh207List: [String] = swadesh100List + [
        "he", "she", "they", "thou", "ye", "here", "there", "where", "when", "how",
        "other", "some", "few", "three", "four", "five", "heavy", "short", "narrow", "wide",
        "thick", "thin", "child", "wife", "husband", "mother", "father", "animal", "snake", "worm",
        "forest", "stick", "fruit", "flower", "grass", "rope", "meat", "leg", "back", "navel",
        "intestines", "spit", "vomit", "blow", "breathe", "laugh", "cry", "fear", "think", "smell",
        "fall", "turn", "wash", "wipe", "pull", "push", "throw", "tie", "sew", "count",
        "sing", "play", "float", "flow", "freeze", "swell", "split", "scratch", "dig", "squeeze",
        "wring", "rub", "dirty", "straight", "wet", "right", "left", "at", "in", "with",
        "and", "if", "because", "near", "far", "smooth", "sharp", "dull", "warm", "old",
        "bad", "crooked", "year", "day", "dust", "ice", "salt"
    ]

    static let leipzigJakarta100List: [String] = [
        "fire", "water", "run", "eye", "bitter", "leg/foot", "blood", "bone", "name", "dog",
        "tooth", "hear", "you (sg.)", "knee", "leaf", "know", "meat/flesh", "come", "louse", "hair",
        "liver", "breast", "sun", "night", "eat", "moon", "go", "thigh", "stone", "tongue",
        "I", "ash", "he/she/it", "drink", "laugh", "path/road", "sand", "bite", "wing", "fly",
        "star", "egg", "hide", "tail", "earth/soil", "navel", "root", "fish", "see", "tree",
        "hand", "neck", "wind", "child", "skin", "stand", "we", "give", "house", "who",
        "smoke", "ant", "mouth", "take", "tear", "burn", "wood", "spit", "tie",
        "salt", "rain", "yesterday", "die", "two", "blow", "kill", "one", "what", "weep/cry",
        "this", "not", "say", "where", "big", "bird", "do/make", "person/human",
        "good", "long", "new", "black", "head", "heavy", "shadow", "all", "old", "white",
        "navel", "carry"
    ]
}
