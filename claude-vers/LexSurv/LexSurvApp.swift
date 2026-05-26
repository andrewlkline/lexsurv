import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let lexsurvSurvey = UTType(exportedAs: "com.lexsurv.survey")
}

@main
struct LexSurvApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { LexSurvDocument() }) { config in
            ContentView(document: config.document)
        }
        .commands {
            CommandGroup(replacing: .help) {
                Button("LexSurv Help") {
                    if let url = URL(string: "https://github.com/anthropics/claude-code") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            SidebarCommands()
            ToolbarCommands()
        }
    }
}
