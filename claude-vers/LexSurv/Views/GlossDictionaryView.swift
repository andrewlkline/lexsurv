import SwiftUI
import UniformTypeIdentifiers

struct GlossDictionaryView: View {
    @ObservedObject var document: LexSurvDocument
    @State private var selectedDictionaryID: GlossDictionary.ID?
    @State private var newDictionaryName: String = ""
    @State private var showingPresetMenu = false

    var body: some View {
        HSplitView {
            sidebar
                .frame(minWidth: 220, idealWidth: 240)
            detail
                .frame(minWidth: 400)
        }
        .navigationTitle("Gloss Dictionary")
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("New dictionary name", text: $newDictionaryName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addDictionary)
                Button(action: addDictionary) {
                    Image(systemName: "plus")
                }
                .disabled(newDictionaryName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(8)

            List(selection: $selectedDictionaryID) {
                ForEach(document.workspace.dictionaries) { dict in
                    HStack {
                        Image(systemName: "book.closed")
                        VStack(alignment: .leading) {
                            Text(dict.name).font(.body)
                            Text("\(dict.glosses.count) gloss\(dict.glosses.count == 1 ? "" : "es")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tag(dict.id as GlossDictionary.ID?)
                }
                .onDelete(perform: deleteDictionaries)
            }
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let id = selectedDictionaryID,
           let index = document.workspace.dictionaries.firstIndex(where: { $0.id == id }) {
            DictionaryEditor(
                dictionary: Binding(
                    get: { document.workspace.dictionaries[index] },
                    set: { document.workspace.dictionaries[index] = $0 }
                )
            )
        } else {
            ContentUnavailableView {
                Label("No Dictionary Selected", systemImage: "book.closed")
            } description: {
                Text("Create or select a gloss dictionary from the sidebar to begin.")
            }
        }
    }

    private func addDictionary() {
        let name = newDictionaryName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        var d = GlossDictionary()
        d.name = name
        document.workspace.dictionaries.append(d)
        selectedDictionaryID = d.id
        newDictionaryName = ""
    }

    private func deleteDictionaries(at offsets: IndexSet) {
        document.workspace.dictionaries.remove(atOffsets: offsets)
    }
}

private struct DictionaryEditor: View {
    @Binding var dictionary: GlossDictionary
    @State private var selectedGlossID: Gloss.ID?
    @State private var showingImporter = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Dictionary name", text: $dictionary.name)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                Spacer()
                Button("Add Gloss") {
                    let g = Gloss()
                    dictionary.glosses.append(g)
                    selectedGlossID = g.id
                }
                Menu("Load Preset…") {
                    Button("Swadesh 100") { loadPreset(.swadesh100) }
                    Button("Swadesh 207") { loadPreset(.swadesh207) }
                    Button("Leipzig-Jakarta 100") { loadPreset(.leipzigJakarta100) }
                }
                Button("Import CSV…") { showingImporter = true }
            }
            .padding(8)
            Divider()
            Table($dictionary.glosses, selection: $selectedGlossID) {
                TableColumn("Primary Gloss") { (g: Binding<Gloss>) in
                    TextField("eye", text: g.primary)
                }
                TableColumn("Secondary") { (g: Binding<Gloss>) in
                    TextField("organ", text: g.secondary)
                }
                .width(min: 80, ideal: 120)
                TableColumn("POS") { (g: Binding<Gloss>) in
                    TextField("N", text: g.partOfSpeech)
                }
                .width(min: 50, ideal: 60, max: 80)
                TableColumn("Field Tip") { (g: Binding<Gloss>) in
                    TextField("human only", text: g.fieldTip)
                }
                .width(min: 100, ideal: 160)
            }
            .contextMenu(forSelectionType: Gloss.ID.self) { ids in
                Button("Delete", role: .destructive) {
                    dictionary.glosses.removeAll { ids.contains($0.id) }
                }
            } primaryAction: { _ in }
            .onDeleteCommand {
                if let id = selectedGlossID {
                    dictionary.glosses.removeAll { $0.id == id }
                    selectedGlossID = nil
                }
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                importCSV(from: url)
            }
        }
    }

    private func loadPreset(_ preset: PresetCatalog) {
        let glosses = preset.glosses
        dictionary.glosses.append(contentsOf: glosses)
    }

    private func importCSV(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url),
              let text = String(data: data, encoding: .utf8) else { return }
        let parsed = CSV.parse(text)
        guard parsed.count > 1 else { return }
        // Expect headers: primary, secondary, pos, fieldTip
        let header = parsed[0].map { $0.lowercased() }
        let pi = header.firstIndex(of: "primary") ?? header.firstIndex(of: "primary gloss") ?? 0
        let si = header.firstIndex(of: "secondary") ?? header.firstIndex(of: "secondary gloss")
        let pos = header.firstIndex(of: "pos") ?? header.firstIndex(of: "part of speech")
        let ft = header.firstIndex(of: "fieldtip") ?? header.firstIndex(of: "field tip")
        for row in parsed.dropFirst() {
            guard pi < row.count else { continue }
            var g = Gloss()
            g.primary = row[pi]
            if let si, si < row.count { g.secondary = row[si] }
            if let pos, pos < row.count { g.partOfSpeech = row[pos] }
            if let ft, ft < row.count { g.fieldTip = row[ft] }
            if !g.primary.isEmpty {
                dictionary.glosses.append(g)
            }
        }
    }
}
