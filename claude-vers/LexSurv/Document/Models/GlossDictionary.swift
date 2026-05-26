import Foundation

struct GlossDictionary: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String = "Untitled Dictionary"
    var glosses: [Gloss] = []
}
