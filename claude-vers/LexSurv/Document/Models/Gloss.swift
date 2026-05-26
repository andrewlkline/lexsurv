import Foundation

struct Gloss: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var primary: String = ""
    var secondary: String = ""
    var partOfSpeech: String = ""
    var fieldTip: String = ""

    enum CodingKeys: String, CodingKey {
        case id, primary, secondary
        case partOfSpeech = "pos"
        case fieldTip
    }
}
