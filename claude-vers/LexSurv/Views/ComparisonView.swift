import SwiftUI

struct ComparisonView: View {
    @ObservedObject var document: LexSurvDocument
    @State private var selectedComparisonID: Comparison.ID?
    @State private var showingNew = false
    @State private var newName = ""
    @State private var newSurveyID: Survey.ID?
    @State private var newType: ComparisonType = .similarity

    var body: some View {
        HSplitView {
            comparisonList
                .frame(minWidth: 220, idealWidth: 240)
            detail
                .frame(minWidth: 600)
        }
        .navigationTitle("Comparisons")
        .sheet(isPresented: $showingNew) { newSheet }
    }

    private var comparisonList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Comparisons").font(.headline)
                Spacer()
                Button(action: { showingNew = true }) {
                    Image(systemName: "plus")
                }
                .disabled(document.workspace.surveys.isEmpty)
            }
            .padding(8)
            List(selection: $selectedComparisonID) {
                ForEach(document.workspace.comparisons) { c in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(c.name)
                        Text(c.type.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(c.id as Comparison.ID?)
                }
                .onDelete { offsets in
                    document.workspace.comparisons.remove(atOffsets: offsets)
                }
            }
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let id = selectedComparisonID,
           let index = document.workspace.comparisons.firstIndex(where: { $0.id == id }) {
            ComparisonEditor(
                comparison: Binding(
                    get: { document.workspace.comparisons[index] },
                    set: { document.workspace.comparisons[index] = $0 }
                ),
                workspace: document.workspace
            )
        } else {
            ContentUnavailableView {
                Label("No Comparison Selected", systemImage: "rectangle.split.3x1")
            } description: {
                Text(document.workspace.surveys.isEmpty
                     ? "Create a survey first."
                     : "Create or select a comparison.")
            }
        }
    }

    private var newSheet: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New Comparison").font(.title2).bold()
            Form {
                TextField("Comparison name", text: $newName)
                Picker("Survey", selection: $newSurveyID) {
                    Text("Select…").tag(nil as Survey.ID?)
                    ForEach(document.workspace.surveys) { s in
                        Text(s.name).tag(s.id as Survey.ID?)
                    }
                }
                Picker("Type", selection: $newType) {
                    ForEach(ComparisonType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            HStack {
                Spacer()
                Button("Cancel") {
                    showingNew = false; newName = ""; newSurveyID = nil
                }
                Button("Create") {
                    var c = Comparison()
                    c.name = newName.trimmingCharacters(in: .whitespaces)
                    c.surveyID = newSurveyID
                    c.type = newType
                    document.workspace.comparisons.append(c)
                    selectedComparisonID = c.id
                    showingNew = false; newName = ""; newSurveyID = nil
                }
                .keyboardShortcut(.defaultAction)
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty
                          || newSurveyID == nil)
            }
        }
        .padding(20)
        .frame(width: 420)
    }
}

// MARK: - Comparison Editor

private struct ComparisonEditor: View {
    @Binding var comparison: Comparison
    let workspace: Workspace
    @State private var selectedGlossID: Gloss.ID?
    @State private var magnifiedText: String = ""

    private var survey: Survey? {
        guard let id = comparison.surveyID else { return nil }
        return workspace.survey(id: id)
    }

    private var dictionary: GlossDictionary? {
        guard let s = survey, let id = s.dictionaryID else { return nil }
        return workspace.dictionary(id: id)
    }

    var body: some View {
        HSplitView {
            glossList
                .frame(minWidth: 180, idealWidth: 200)
            judgmentTable
                .frame(minWidth: 480)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Suggest (ALINE)", action: suggestGroupings)
                    .help("Use feature-weighted phonetic alignment to propose grouping codes")
                Button("Next Gloss (⌘↩)", action: nextGloss)
                    .keyboardShortcut(.return, modifiers: .command)
                Button("Next Ungrouped (⌘G)", action: nextUngrouped)
                    .keyboardShortcut("g", modifiers: .command)
                Button("Exclude All (⌘E)", action: excludeAll)
                    .keyboardShortcut("e", modifiers: .command)
            }
        }
    }

    private func suggestGroupings() {
        guard let s = survey, let glossID = selectedGlossID else { return }
        // Only consider varieties with a non-empty transcription and not excluded.
        var indexedForms: [(Variety.ID, String)] = []
        for v in s.varieties {
            let j = comparison.judgment(gloss: glossID, variety: v.id)
            guard !j.excluded else { continue }
            let trans = v.transcriptions[glossID]?.transcription ?? ""
            guard !trans.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            indexedForms.append((v.id, trans))
        }
        guard !indexedForms.isEmpty else { return }
        let labels = PhoneticAlignment.suggestGroupings(forms: indexedForms.map { $0.1 })
        for (i, (varietyID, _)) in indexedForms.enumerated() {
            var j = comparison.judgment(gloss: glossID, variety: varietyID)
            j.groupingCode = labels[i]
            comparison.setJudgment(j, gloss: glossID, variety: varietyID)
        }
    }

    @ViewBuilder
    private var glossList: some View {
        if let dict = dictionary {
            List(dict.glosses, selection: $selectedGlossID) { gloss in
                HStack {
                    Text(gloss.primary)
                    Spacer()
                    if hasJudgments(for: gloss.id) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }
                .tag(gloss.id as Gloss.ID?)
            }
        } else {
            Text("No dictionary linked to survey.").foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var judgmentTable: some View {
        if let s = survey,
           let glossID = selectedGlossID,
           let gloss = dictionary?.glosses.first(where: { $0.id == glossID }) {
            VStack(alignment: .leading, spacing: 0) {
                magnifier
                    .padding(8)
                Divider()
                HStack {
                    Text(gloss.primary).font(.title3).bold()
                    if !gloss.secondary.isEmpty {
                        Text(gloss.secondary).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(8)
                Divider()
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(s.varieties) { variety in
                            JudgmentRow(
                                variety: variety,
                                transcription: variety.transcriptions[glossID]?.transcription ?? "",
                                judgment: Binding(
                                    get: { comparison.judgment(gloss: glossID, variety: variety.id) },
                                    set: { comparison.setJudgment($0, gloss: glossID, variety: variety.id) }
                                ),
                                onFocusTranscription: { magnifiedText = $0 }
                            )
                            Divider()
                        }
                    }
                }
            }
        } else {
            ContentUnavailableView {
                Label("Pick a gloss", systemImage: "list.bullet.indent")
            } description: {
                Text("Select a gloss from the sidebar to start judging.")
            }
        }
    }

    private var magnifier: some View {
        HStack {
            Text("Magnifier:")
                .foregroundStyle(.secondary)
            Text(magnifiedText.isEmpty ? "—" : magnifiedText)
                .font(.system(size: 32, weight: .regular, design: .serif))
                .frame(minHeight: 44)
            Spacer()
        }
    }

    private func hasJudgments(for glossID: Gloss.ID) -> Bool {
        guard let row = comparison.judgments[glossID] else { return false }
        return row.values.contains(where: { $0.hasGrouping || $0.excluded })
    }

    private func nextGloss() {
        guard let dict = dictionary,
              let currentID = selectedGlossID,
              let idx = dict.glosses.firstIndex(where: { $0.id == currentID }),
              idx + 1 < dict.glosses.count else { return }
        selectedGlossID = dict.glosses[idx + 1].id
    }

    private func nextUngrouped() {
        guard let dict = dictionary, let s = survey else { return }
        let startIndex = selectedGlossID
            .flatMap { id in dict.glosses.firstIndex(where: { $0.id == id }) } ?? -1
        for offset in 1...dict.glosses.count {
            let i = (startIndex + offset) % dict.glosses.count
            let g = dict.glosses[i]
            let row = comparison.judgments[g.id] ?? [:]
            let needsJudgment = s.varieties.contains { v in
                let j = row[v.id] ?? Judgment()
                let hasTranscription = !(v.transcriptions[g.id]?.transcription.isEmpty ?? true)
                return hasTranscription && !j.excluded && !j.hasGrouping
            }
            if needsJudgment {
                selectedGlossID = g.id
                return
            }
        }
    }

    private func excludeAll() {
        guard let s = survey, let glossID = selectedGlossID else { return }
        for variety in s.varieties {
            var j = comparison.judgment(gloss: glossID, variety: variety.id)
            j.excluded = true
            comparison.setJudgment(j, gloss: glossID, variety: variety.id)
        }
    }
}

private struct JudgmentRow: View {
    let variety: Variety
    let transcription: String
    @Binding var judgment: Judgment
    let onFocusTranscription: (String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(variety.abbreviation.isEmpty ? variety.name : variety.abbreviation)
                .font(.body)
                .frame(width: 90, alignment: .leading)
            Button {
                onFocusTranscription(transcription)
            } label: {
                Text(transcription.isEmpty ? "—" : transcription)
                    .font(.system(size: 18, design: .serif))
                    .frame(minWidth: 100, alignment: .leading)
                    .padding(.vertical, 2)
            }
            .buttonStyle(.plain)
            TextField("a", text: $judgment.groupingCode)
                .frame(width: 100)
                .font(.system(.body, design: .monospaced))
                .disabled(judgment.excluded)
            Toggle("Exclude", isOn: $judgment.excluded)
                .toggleStyle(.checkbox)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .opacity(judgment.excluded ? 0.55 : 1.0)
    }
}
