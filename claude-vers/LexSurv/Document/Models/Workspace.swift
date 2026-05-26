import Foundation

struct Workspace: Codable, Equatable {
    var schemaVersion: Int = 1
    var dictionaries: [GlossDictionary] = []
    var surveys: [Survey] = []
    var comparisons: [Comparison] = []

    func dictionary(id: UUID) -> GlossDictionary? {
        dictionaries.first(where: { $0.id == id })
    }

    func survey(id: UUID) -> Survey? {
        surveys.first(where: { $0.id == id })
    }

    func comparison(id: UUID) -> Comparison? {
        comparisons.first(where: { $0.id == id })
    }
}

struct WorkspaceMeta: Codable, Equatable {
    var schemaVersion: Int = 1
    var createdAt: Date = .now
    var updatedAt: Date = .now
    var appVersion: String = "0.1.0"
}
