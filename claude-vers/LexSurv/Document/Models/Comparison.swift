import Foundation

enum ComparisonType: String, Codable, CaseIterable, Identifiable {
    case similarity
    case cognacy
    case identical

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .similarity: return "Similarity"
        case .cognacy: return "Cognacy"
        case .identical: return "Identical"
        }
    }

    var description: String {
        switch self {
        case .similarity: return "General lexicostatistical similarity"
        case .cognacy: return "Historical/etymological cognacy judgments"
        case .identical: return "Exact homophonous forms matching"
        }
    }
}

struct Comparison: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String = "Untitled Comparison"
    var surveyID: UUID?
    var type: ComparisonType = .similarity
    /// glossID -> varietyID -> Judgment
    var judgments: [UUID: [UUID: Judgment]] = [:]

    func judgment(gloss: UUID, variety: UUID) -> Judgment {
        judgments[gloss]?[variety] ?? Judgment()
    }

    mutating func setJudgment(_ j: Judgment, gloss: UUID, variety: UUID) {
        var row = judgments[gloss] ?? [:]
        row[variety] = j
        judgments[gloss] = row
    }
}

struct Judgment: Codable, Hashable {
    /// Space-separated single-character cognacy/similarity codes (e.g. "a", "a b")
    var groupingCode: String = ""
    /// Optional pre-aligned representation
    var aligned: String = ""
    var excluded: Bool = false
    var notes: String = ""

    var groupingTokens: [String] {
        groupingCode
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    var hasGrouping: Bool { !groupingTokens.isEmpty }
}
