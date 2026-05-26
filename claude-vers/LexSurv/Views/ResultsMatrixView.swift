import SwiftUI
import UniformTypeIdentifiers

struct ResultsMatrixView: View {
    @ObservedObject var document: LexSurvDocument
    @State private var selectedComparisonID: Comparison.ID?

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
                Spacer()
                Button("Export to CSV…", action: exportCSV)
                    .disabled(selectedComparisonID == nil)
            }
            .padding(8)
            Divider()
            staircase
        }
        .navigationTitle("Results Matrix")
        .onAppear {
            if selectedComparisonID == nil {
                selectedComparisonID = document.workspace.comparisons.first?.id
            }
        }
    }

    @ViewBuilder
    private var staircase: some View {
        if let resolved = resolveContext() {
            ScrollView([.horizontal, .vertical]) {
                StaircaseGrid(varieties: resolved.varieties, matrix: resolved.matrix)
                    .padding(12)
            }
        } else {
            ContentUnavailableView {
                Label("No Comparison Selected", systemImage: "tablecells")
            } description: {
                Text("Pick a comparison to see its staircase results matrix.")
            }
        }
    }

    private struct ResolvedContext {
        let varieties: [Variety]
        let matrix: [[PairSimilarity]]
    }

    private func resolveContext() -> ResolvedContext? {
        guard let cID = selectedComparisonID,
              let comp = document.workspace.comparison(id: cID),
              let sID = comp.surveyID,
              let survey = document.workspace.survey(id: sID),
              let dID = survey.dictionaryID,
              let dict = document.workspace.dictionary(id: dID) else { return nil }
        return ResolvedContext(
            varieties: survey.varieties,
            matrix: SimilarityCalculator.matrix(survey: survey, dictionary: dict, comparison: comp)
        )
    }

    private func exportCSV() {
        guard let ctx = resolveContext() else { return }
        var rows: [[String]] = []
        let names = ctx.varieties.map { $0.abbreviation.isEmpty ? $0.name : $0.abbreviation }
        rows.append([""] + names)
        for i in 0..<ctx.varieties.count {
            var row: [String] = [names[i]]
            for j in 0..<ctx.varieties.count {
                if i == j {
                    row.append("—")
                } else if j < i {
                    row.append("\(ctx.matrix[i][j].percent)")
                } else {
                    row.append("")
                }
            }
            rows.append(row)
        }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "similarity_matrix.csv"
        if panel.runModal() == .OK, let url = panel.url {
            try? CSV.encode(rows).write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

private struct StaircaseGrid: View {
    let varieties: [Variety]
    let matrix: [[PairSimilarity]]

    var body: some View {
        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            ForEach(0..<varieties.count, id: \.self) { i in
                GridRow {
                    Text(displayName(varieties[i]))
                        .font(.caption).bold()
                        .frame(width: 90, height: 32, alignment: .trailing)
                        .padding(.trailing, 6)
                        .background(Color.gray.opacity(0.15))
                    ForEach(0..<i, id: \.self) { j in
                        cell(matrix[i][j].percent)
                    }
                }
            }
            GridRow {
                Text("").frame(width: 90, height: 28)
                ForEach(0..<max(0, varieties.count - 1), id: \.self) { j in
                    Text(displayName(varieties[j]))
                        .font(.caption).bold()
                        .frame(width: 70, height: 28)
                        .background(Color.gray.opacity(0.15))
                }
            }
        }
    }

    private func displayName(_ v: Variety) -> String {
        v.abbreviation.isEmpty ? v.name : v.abbreviation
    }

    private func cell(_ percent: Int) -> some View {
        let bg: Color = {
            switch percent {
            case 75...: return .green.opacity(0.55)
            case 50..<75: return Color(red: 0.7, green: 0.85, blue: 0.4).opacity(0.7)
            case 25..<50: return .yellow.opacity(0.65)
            default: return .red.opacity(0.45)
            }
        }()
        return Text("\(percent)")
            .font(.system(.body, design: .monospaced))
            .frame(width: 70, height: 32)
            .background(bg)
    }
}
