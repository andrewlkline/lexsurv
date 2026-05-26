import SwiftUI

struct WordlistView: View {
    @ObservedObject var document: LexSurvDocument
    @State private var selectedSurveyID: Survey.ID?
    @State private var newSurveyName = ""
    @State private var newSurveyDictionaryID: GlossDictionary.ID?
    @State private var showingNewSurvey = false

    var body: some View {
        HSplitView {
            surveyList
                .frame(minWidth: 220, idealWidth: 240)
            surveyDetail
                .frame(minWidth: 500)
        }
        .navigationTitle("Wordlists")
        .sheet(isPresented: $showingNewSurvey) { newSurveySheet }
    }

    private var surveyList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Surveys").font(.headline)
                Spacer()
                Button(action: { showingNewSurvey = true }) {
                    Image(systemName: "plus")
                }
                .disabled(document.workspace.dictionaries.isEmpty)
                .help(document.workspace.dictionaries.isEmpty
                      ? "Create a gloss dictionary first"
                      : "Create new survey")
            }
            .padding(8)

            List(selection: $selectedSurveyID) {
                ForEach(document.workspace.surveys) { survey in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(survey.name)
                        Text("\(survey.varieties.count) varieties")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(survey.id as Survey.ID?)
                }
                .onDelete { offsets in
                    document.workspace.surveys.remove(atOffsets: offsets)
                }
            }
        }
    }

    @ViewBuilder
    private var surveyDetail: some View {
        if let id = selectedSurveyID,
           let index = document.workspace.surveys.firstIndex(where: { $0.id == id }) {
            SurveyEditor(
                survey: Binding(
                    get: { document.workspace.surveys[index] },
                    set: { document.workspace.surveys[index] = $0 }
                ),
                workspace: document.workspace
            )
        } else {
            ContentUnavailableView {
                Label("No Survey Selected", systemImage: "text.book.closed")
            } description: {
                Text(document.workspace.dictionaries.isEmpty
                     ? "Create a gloss dictionary first, then start a survey."
                     : "Create or select a survey from the sidebar.")
            }
        }
    }

    private var newSurveySheet: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New Survey").font(.title2).bold()
            Form {
                TextField("Survey name", text: $newSurveyName)
                Picker("Gloss Dictionary", selection: $newSurveyDictionaryID) {
                    Text("Select…").tag(nil as GlossDictionary.ID?)
                    ForEach(document.workspace.dictionaries) { d in
                        Text(d.name).tag(d.id as GlossDictionary.ID?)
                    }
                }
            }
            HStack {
                Spacer()
                Button("Cancel") {
                    showingNewSurvey = false
                    newSurveyName = ""
                    newSurveyDictionaryID = nil
                }
                Button("Create") {
                    var s = Survey()
                    s.name = newSurveyName.trimmingCharacters(in: .whitespaces)
                    s.dictionaryID = newSurveyDictionaryID
                    document.workspace.surveys.append(s)
                    selectedSurveyID = s.id

                    // Each survey gets the standard three comparisons up front.
                    let names: [(String, ComparisonType)] = [
                        ("Lexical similarity", .similarity),
                        ("Lexical cognacy",    .cognacy),
                        ("Identical words",    .identical),
                    ]
                    for (label, type) in names {
                        var c = Comparison()
                        c.name = label
                        c.surveyID = s.id
                        c.type = type
                        document.workspace.comparisons.append(c)
                    }

                    showingNewSurvey = false
                    newSurveyName = ""
                    newSurveyDictionaryID = nil
                }
                .keyboardShortcut(.defaultAction)
                .disabled(newSurveyName.trimmingCharacters(in: .whitespaces).isEmpty
                          || newSurveyDictionaryID == nil)
            }
        }
        .padding(20)
        .frame(width: 400)
    }
}

// MARK: - Survey Editor

private struct SurveyEditor: View {
    @Binding var survey: Survey
    let workspace: Workspace
    @State private var selectedVarietyID: Variety.ID?

    private var dictionary: GlossDictionary? {
        guard let id = survey.dictionaryID else { return nil }
        return workspace.dictionary(id: id)
    }

    var body: some View {
        VSplitView {
            varietyPanel
                .frame(minHeight: 160, idealHeight: 220)
            transcriptionPanel
                .frame(minHeight: 200)
        }
    }

    private var varietyPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TextField("Survey name", text: $survey.name)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                Spacer()
                Button("+ New Variety") {
                    let v = Variety()
                    survey.varieties.append(v)
                    selectedVarietyID = v.id
                }
                Menu("Wordlist…") {
                    Button("Export CSV…", action: exportCSV)
                    Button("Import CSV…", action: importCSV)
                }
            }
            .padding(8)

            if survey.varieties.isEmpty {
                Spacer()
                Text("No varieties yet — click ‘+ New Variety’ to add one.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                Table($survey.varieties, selection: $selectedVarietyID) {
                    TableColumn("Name") { (v: Binding<Variety>) in
                        TextField("Variety", text: v.name)
                    }
                    TableColumn("Abbrev") { (v: Binding<Variety>) in
                        TextField("ABV", text: v.abbreviation)
                    }
                    .width(min: 60, ideal: 80, max: 100)
                    TableColumn("ISO 639-3") { (v: Binding<Variety>) in
                        TextField("xxx", text: v.isoCode)
                    }
                    .width(min: 70, ideal: 80, max: 100)
                    TableColumn("Progress") { (v: Binding<Variety>) in
                        if let dict = dictionary {
                            let done = v.wrappedValue.transcribedCount(in: dict)
                            ProgressView(value: dict.glosses.isEmpty ? 0
                                         : Double(done) / Double(dict.glosses.count))
                                .progressViewStyle(.linear)
                                .help("\(done)/\(dict.glosses.count) transcribed")
                        }
                    }
                }
                .onDeleteCommand {
                    if let id = selectedVarietyID {
                        survey.varieties.removeAll { $0.id == id }
                        selectedVarietyID = nil
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var transcriptionPanel: some View {
        if let varietyID = selectedVarietyID,
           let varietyIndex = survey.varieties.firstIndex(where: { $0.id == varietyID }),
           let dict = dictionary {
            TranscriptionGrid(
                variety: Binding(
                    get: { survey.varieties[varietyIndex] },
                    set: { survey.varieties[varietyIndex] = $0 }
                ),
                dictionary: dict
            )
        } else {
            ContentUnavailableView {
                Label("Select a variety", systemImage: "rectangle.split.3x1")
            } description: {
                Text("Click a variety above to enter transcriptions.")
            }
        }
    }

    // MARK: - CSV

    private func exportCSV() {
        guard let dict = dictionary else { return }
        let header: [String] = ["Gloss"] + survey.varieties.map { $0.name }
        var rows: [[String]] = [header]
        for g in dict.glosses {
            var row = [g.primary]
            for v in survey.varieties {
                row.append(v.transcriptions[g.id]?.transcription ?? "")
            }
            rows.append(row)
        }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "\(survey.name).csv"
        if panel.runModal() == .OK, let url = panel.url {
            try? CSV.encode(rows).write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private func importCSV() {
        guard let dict = dictionary else { return }
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.commaSeparatedText, .plainText]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return }
        let rows = CSV.parse(text)
        guard rows.count >= 2 else { return }
        let header = rows[0]
        // header[0] = "Gloss"; header[1...] = variety names
        let varietyColumns = Array(header.dropFirst())
        // Ensure varieties exist; map column -> variety index
        var columnVariety: [Int: Int] = [:]
        for (col, name) in varietyColumns.enumerated() {
            let absoluteCol = col + 1
            if let idx = survey.varieties.firstIndex(where: { $0.name == name }) {
                columnVariety[absoluteCol] = idx
            } else {
                var v = Variety()
                v.name = name
                survey.varieties.append(v)
                columnVariety[absoluteCol] = survey.varieties.count - 1
            }
        }
        // Map gloss column 0 -> Gloss IDs
        let glossByPrimary = Dictionary(uniqueKeysWithValues: dict.glosses.map { ($0.primary.lowercased(), $0.id) })
        for row in rows.dropFirst() {
            guard let glossID = glossByPrimary[row[0].lowercased()] else { continue }
            for (col, idx) in columnVariety {
                guard col < row.count else { continue }
                let value = row[col]
                guard !value.isEmpty else { continue }
                var t = survey.varieties[idx].transcriptions[glossID] ?? Transcription()
                t.transcription = value
                survey.varieties[idx].transcriptions[glossID] = t
            }
        }
    }
}

// MARK: - Transcription Grid

private struct TranscriptionGrid: View {
    @Binding var variety: Variety
    let dictionary: GlossDictionary
    @FocusState private var focusedGloss: Gloss.ID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Transcriptions — \(variety.name)").font(.headline)
                Spacer()
                Text("\(variety.transcribedCount(in: dictionary))/\(dictionary.glosses.count)")
                    .foregroundStyle(.secondary)
            }
            .padding(8)
            Divider()
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(dictionary.glosses) { gloss in
                        TranscriptionRow(
                            gloss: gloss,
                            transcription: Binding(
                                get: { variety.transcriptions[gloss.id] ?? Transcription() },
                                set: { variety.transcriptions[gloss.id] = $0 }
                            ),
                            focused: $focusedGloss,
                            onSubmit: { advance(after: gloss.id) }
                        )
                        Divider()
                    }
                }
            }
        }
    }

    private func advance(after id: Gloss.ID) {
        guard let idx = dictionary.glosses.firstIndex(where: { $0.id == id }),
              idx + 1 < dictionary.glosses.count else { return }
        focusedGloss = dictionary.glosses[idx + 1].id
    }
}

private struct TranscriptionRow: View {
    let gloss: Gloss
    @Binding var transcription: Transcription
    @FocusState.Binding var focused: Gloss.ID?
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text(gloss.primary).font(.body)
                if !gloss.secondary.isEmpty {
                    Text(gloss.secondary).font(.caption).foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, alignment: .leading)
            TextField("Transcription", text: $transcription.transcription)
                .font(.system(size: 16, design: .serif))
                .textFieldStyle(.roundedBorder)
                .focused($focused, equals: gloss.id)
                .onSubmit { onSubmit() }
            TextField("Notes", text: $transcription.notes)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 220)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
