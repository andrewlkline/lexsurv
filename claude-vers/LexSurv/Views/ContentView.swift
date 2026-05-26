import SwiftUI

enum WorkflowPhase: String, CaseIterable, Identifiable, Hashable {
    case glossDictionary = "Gloss Dictionary"
    case wordlists = "Wordlists"
    case comparisons = "Comparisons"
    case analysis = "Analysis"
    case resultsMatrix = "Results Matrix"
    case phylogeny = "Phylogeny"
    case soundCorrespondences = "Sound Correspondences"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .glossDictionary: return "book.closed"
        case .wordlists: return "text.book.closed"
        case .comparisons: return "rectangle.split.3x1"
        case .analysis: return "chart.bar"
        case .resultsMatrix: return "tablecells"
        case .phylogeny: return "point.3.connected.trianglepath.dotted"
        case .soundCorrespondences: return "waveform"
        }
    }
}

struct ContentView: View {
    @ObservedObject var document: LexSurvDocument
    @State private var selectedPhase: WorkflowPhase? = .glossDictionary
    @State private var ipaPaletteVisible = false

    var body: some View {
        NavigationSplitView {
            List(WorkflowPhase.allCases, selection: $selectedPhase) { phase in
                NavigationLink(value: phase) {
                    Label(phase.rawValue, systemImage: phase.systemImage)
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 260)
            .listStyle(.sidebar)
        } detail: {
            phaseView
                .frame(minWidth: 600, minHeight: 400)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Toggle(isOn: $ipaPaletteVisible) {
                            Label("IPA Palette", systemImage: "keyboard")
                        }
                    }
                }
        }
        .overlay(alignment: .bottomTrailing) {
            if ipaPaletteVisible {
                IPAPaletteView()
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: ipaPaletteVisible)
    }

    @ViewBuilder
    private var phaseView: some View {
        switch selectedPhase ?? .glossDictionary {
        case .glossDictionary: GlossDictionaryView(document: document)
        case .wordlists: WordlistView(document: document)
        case .comparisons: ComparisonView(document: document)
        case .analysis: AnalysisView(document: document)
        case .resultsMatrix: ResultsMatrixView(document: document)
        case .phylogeny: PhylogenyView(document: document)
        case .soundCorrespondences: SoundCorrespondenceView(document: document)
        }
    }
}
