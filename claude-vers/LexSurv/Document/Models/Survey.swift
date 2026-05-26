import Foundation

struct Survey: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String = "Untitled Survey"
    var dictionaryID: UUID?
    var fullTitle: String = ""
    var notes: String = ""
    var compiler: String = ""
    var consultant: String = ""
    var area: String = ""
    var location: String = ""
    var varieties: [Variety] = []
}
