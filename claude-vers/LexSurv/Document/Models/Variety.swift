import Foundation

struct Variety: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String = "Untitled Variety"
    var abbreviation: String = ""
    var isoCode: String = ""
    var alternateName: String = ""
    var transcriptions: [UUID: Transcription] = [:]
}

struct Transcription: Codable, Hashable {
    var transcription: String = ""
    var pluralFrame: String = ""
    var notes: String = ""
    var synonyms: [String] = []

    var isEmpty: Bool {
        transcription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
