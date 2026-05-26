import SwiftUI
import UniformTypeIdentifiers
import Combine

/// A document-backed model representing one `.lexsurv` package file.
///
/// Layout on disk (FileWrapper package):
///
///     MySurvey.lexsurv/
///       meta.json
///       dictionaries/<uuid>.json
///       surveys/<uuid>.json          (survey metadata + varieties + transcriptions)
///       comparisons/<uuid>.json
///       matrix.json                  (optional cached similarity matrix)
///
final class LexSurvDocument: ReferenceFileDocument {
    typealias Snapshot = Workspace

    static var readableContentTypes: [UTType] { [.lexsurvSurvey] }
    static var writableContentTypes: [UTType] { [.lexsurvSurvey] }

    @Published var workspace: Workspace
    @Published var meta: WorkspaceMeta

    init() {
        self.workspace = Workspace()
        self.meta = WorkspaceMeta()
    }

    init(configuration: ReadConfiguration) throws {
        let root = configuration.file
        guard root.isDirectory, let children = root.fileWrappers else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let meta: WorkspaceMeta = {
            if let data = children["meta.json"]?.regularFileContents,
               let m = try? decoder.decode(WorkspaceMeta.self, from: data) {
                return m
            }
            return WorkspaceMeta()
        }()

        var ws = Workspace()
        ws.dictionaries = Self.decodeChildren(children["dictionaries"], as: GlossDictionary.self, with: decoder)
        ws.surveys = Self.decodeChildren(children["surveys"], as: Survey.self, with: decoder)
        ws.comparisons = Self.decodeChildren(children["comparisons"], as: Comparison.self, with: decoder)

        self.workspace = ws
        self.meta = meta
    }

    func snapshot(contentType: UTType) throws -> Workspace {
        workspace
    }

    func fileWrapper(snapshot: Workspace, configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        var updatedMeta = meta
        updatedMeta.updatedAt = .now
        updatedMeta.schemaVersion = 1

        let metaData = try encoder.encode(updatedMeta)
        let metaWrapper = FileWrapper(regularFileWithContents: metaData)
        metaWrapper.preferredFilename = "meta.json"

        let dictionariesWrapper = try Self.encodeChildren(
            snapshot.dictionaries,
            preferredName: "dictionaries",
            encoder: encoder,
            idKeyPath: \.id
        )
        let surveysWrapper = try Self.encodeChildren(
            snapshot.surveys,
            preferredName: "surveys",
            encoder: encoder,
            idKeyPath: \.id
        )
        let comparisonsWrapper = try Self.encodeChildren(
            snapshot.comparisons,
            preferredName: "comparisons",
            encoder: encoder,
            idKeyPath: \.id
        )

        let root = FileWrapper(directoryWithFileWrappers: [
            "meta.json": metaWrapper,
            "dictionaries": dictionariesWrapper,
            "surveys": surveysWrapper,
            "comparisons": comparisonsWrapper
        ])
        return root
    }

    private static func decodeChildren<T: Decodable>(
        _ wrapper: FileWrapper?,
        as type: T.Type,
        with decoder: JSONDecoder
    ) -> [T] {
        guard let wrapper, wrapper.isDirectory, let children = wrapper.fileWrappers else {
            return []
        }
        return children.values.compactMap { child in
            guard let data = child.regularFileContents else { return nil }
            return try? decoder.decode(T.self, from: data)
        }
    }

    private static func encodeChildren<T: Encodable & Identifiable>(
        _ items: [T],
        preferredName: String,
        encoder: JSONEncoder,
        idKeyPath: KeyPath<T, UUID>
    ) throws -> FileWrapper where T.ID == UUID {
        var children: [String: FileWrapper] = [:]
        for item in items {
            let data = try encoder.encode(item)
            let file = FileWrapper(regularFileWithContents: data)
            let name = "\(item[keyPath: idKeyPath].uuidString).json"
            file.preferredFilename = name
            children[name] = file
        }
        let dir = FileWrapper(directoryWithFileWrappers: children)
        dir.preferredFilename = preferredName
        return dir
    }
}

private extension FileWrapper {
    var isDirectory: Bool { fileWrappers != nil }
}
