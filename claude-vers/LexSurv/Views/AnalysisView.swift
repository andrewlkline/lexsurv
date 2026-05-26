import SwiftUI

enum MatrixDisplayMode: String, CaseIterable, Identifiable {
    case percent
    case tally
    case total

    var id: String { rawValue }
    var label: String {
        switch self {
        case .percent: return "Percent"
        case .tally: return "Tally"
        case .total: return "Total"
        }
    }
}

struct AnalysisView: View {
    @ObservedObject var document: LexSurvDocument
    @State private var selectedComparisonID: Comparison.ID?
    @State private var mode: MatrixDisplayMode = .percent

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
                Picker("View", selection: $mode) {
                    ForEach(MatrixDisplayMode.allCases) { m in
                        Text(m.label).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
            }
            .padding(8)
            Divider()
            matrix
            legend
                .padding(8)
        }
        .navigationTitle("Analysis")
        .onAppear {
            if selectedComparisonID == nil {
                selectedComparisonID = document.workspace.comparisons.first?.id
            }
        }
    }

    @ViewBuilder
    private var matrix: some View {
        if let comparisonID = selectedComparisonID,
           let comparison = document.workspace.comparison(id: comparisonID),
           let surveyID = comparison.surveyID,
           let survey = document.workspace.survey(id: surveyID),
           let dictID = survey.dictionaryID,
           let dict = document.workspace.dictionary(id: dictID) {
            let varieties = survey.varieties
            let matrix = SimilarityCalculator.matrix(survey: survey, dictionary: dict, comparison: comparison)
            ScrollView([.horizontal, .vertical]) {
                MatrixGrid(varieties: varieties, matrix: matrix, mode: mode)
                    .padding(8)
            }
        } else {
            ContentUnavailableView {
                Label("No Comparison", systemImage: "chart.bar")
            } description: {
                Text("Create a comparison to see the similarity matrix.")
            }
        }
    }

    private var legend: some View {
        HStack(spacing: 12) {
            legendChip(color: .green, label: "≥ 75%")
            legendChip(color: Color(red: 0.7, green: 0.85, blue: 0.4), label: "50–74%")
            legendChip(color: .yellow, label: "25–49%")
            legendChip(color: .red.opacity(0.6), label: "< 25%")
            Spacer()
        }
        .font(.caption)
    }

    private func legendChip(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
        }
    }
}

struct MatrixGrid: View {
    let varieties: [Variety]
    let matrix: [[PairSimilarity]]
    let mode: MatrixDisplayMode

    var body: some View {
        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            GridRow {
                Text("").frame(width: 80, height: 28)
                ForEach(varieties) { v in
                    Text(v.abbreviation.isEmpty ? v.name : v.abbreviation)
                        .font(.caption)
                        .bold()
                        .frame(width: 70, height: 28)
                        .background(Color.gray.opacity(0.15))
                }
            }
            ForEach(Array(varieties.enumerated()), id: \.element.id) { (i, rowVariety) in
                GridRow {
                    Text(rowVariety.abbreviation.isEmpty ? rowVariety.name : rowVariety.abbreviation)
                        .font(.caption)
                        .bold()
                        .frame(width: 80, height: 32, alignment: .trailing)
                        .padding(.trailing, 6)
                        .background(Color.gray.opacity(0.15))
                    ForEach(Array(varieties.enumerated()), id: \.element.id) { (j, _) in
                        cell(value: matrix[i][j], isDiagonal: i == j)
                    }
                }
            }
        }
    }

    private func cell(value: PairSimilarity, isDiagonal: Bool) -> some View {
        let text: String = {
            switch mode {
            case .percent: return isDiagonal ? "—" : "\(value.percent)"
            case .tally: return isDiagonal ? "—" : "\(value.tally)"
            case .total: return isDiagonal ? "—" : "\(value.total)"
            }
        }()
        let bg: Color = {
            if isDiagonal { return Color.gray.opacity(0.2) }
            switch mode {
            case .percent: return heatmapColor(value.percent)
            default: return Color.gray.opacity(0.08)
            }
        }()
        return Text(text)
            .font(.system(.body, design: .monospaced))
            .frame(width: 70, height: 32)
            .background(bg)
    }

    func heatmapColor(_ percent: Int) -> Color {
        switch percent {
        case 75...: return Color.green.opacity(0.55)
        case 50..<75: return Color(red: 0.7, green: 0.85, blue: 0.4).opacity(0.7)
        case 25..<50: return Color.yellow.opacity(0.65)
        default: return Color.red.opacity(0.45)
        }
    }
}
