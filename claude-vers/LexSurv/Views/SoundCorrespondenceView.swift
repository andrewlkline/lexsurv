import SwiftUI

struct SoundCorrespondenceView: View {
    @ObservedObject var document: LexSurvDocument
    @State private var selectedComparisonID: Comparison.ID?
    @State private var hideIdentity: Bool = true
    @State private var minCount: Int = 2

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("Comparison", selection: $selectedComparisonID) {
                    Text("Select…").tag(nil as Comparison.ID?)
                    ForEach(document.workspace.comparisons) { c in
                        Text(c.name).tag(c.id as Comparison.ID?)
                    }
                }
                .frame(maxWidth: 320)
                Toggle("Hide identities (a:a)", isOn: $hideIdentity)
                Stepper(value: $minCount, in: 1...20) {
                    Text("Min count: \(minCount)")
                }
                Spacer()
            }
            .padding(8)
            Divider()
            content
        }
        .navigationTitle("Sound Correspondences")
        .onAppear {
            if selectedComparisonID == nil {
                selectedComparisonID = document.workspace.comparisons.first?.id
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let results = detect() {
            let filtered = results
                .filter { !hideIdentity || $0.pair.a != $0.pair.b }
                .filter { $0.count >= minCount }
            if filtered.isEmpty {
                ContentUnavailableView {
                    Label("No Correspondences", systemImage: "waveform")
                } description: {
                    Text("No correspondences passed the filters. Lower the minimum count or include identities.")
                }
            } else {
                Table(filtered) {
                    TableColumn("Sound A") { r in
                        Text(r.pair.a)
                            .font(.system(size: 18, design: .serif))
                    }
                    .width(min: 60, ideal: 70, max: 100)
                    TableColumn("Sound B") { r in
                        Text(r.pair.b)
                            .font(.system(size: 18, design: .serif))
                    }
                    .width(min: 60, ideal: 70, max: 100)
                    TableColumn("Count") { r in
                        Text("\(r.count)")
                            .font(.system(.body, design: .monospaced))
                    }
                    .width(min: 60, ideal: 80, max: 100)
                    TableColumn("Example glosses") { r in
                        Text(r.examples.prefix(6).joined(separator: ", ")
                             + (r.examples.count > 6 ? ", …" : ""))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
        } else {
            ContentUnavailableView {
                Label("No Comparison", systemImage: "waveform")
            } description: {
                Text("Pick a comparison to detect recurring sound correspondences.")
            }
        }
    }

    private func detect() -> [SoundCorrespondenceResult]? {
        guard let cID = selectedComparisonID,
              let comp = document.workspace.comparison(id: cID),
              let sID = comp.surveyID,
              let survey = document.workspace.survey(id: sID),
              let dID = survey.dictionaryID,
              let dict = document.workspace.dictionary(id: dID) else { return nil }
        return SoundCorrespondence.detect(survey: survey, dictionary: dict, comparison: comp)
    }
}
