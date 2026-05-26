import SwiftUI
import AppKit

struct IPAPaletteView: View {
    @State private var selectedCategory: IPACategory = .vowels

    private let columns = [GridItem(.adaptive(minimum: 36, maximum: 44), spacing: 4)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("IPA Palette")
                    .font(.headline)
                Spacer()
                Picker("Category", selection: $selectedCategory) {
                    ForEach(IPACategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(selectedCategory.characters, id: \.self) { char in
                    Button(action: { Self.insertIntoFirstResponder(char) }) {
                        Text(char)
                            .font(.system(size: 18, weight: .regular, design: .serif))
                            .frame(width: 36, height: 32)
                    }
                    .buttonStyle(.bordered)
                    .help(unicodeName(for: char))
                }
            }
        }
        .padding(12)
        .frame(width: 360)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.separator, lineWidth: 0.5)
        )
        .shadow(radius: 8)
    }

    private func unicodeName(for char: String) -> String {
        let scalar = char.unicodeScalars.first.map { $0.value } ?? 0
        return String(format: "U+%04X", scalar)
    }

    /// Insert text into the first responder of the key window.
    /// Works for both NSTextField (via field editor) and NSTextView.
    static func insertIntoFirstResponder(_ text: String) {
        guard let window = NSApp.keyWindow else { NSSound.beep(); return }
        let responder = window.firstResponder

        if let textView = responder as? NSTextView {
            textView.insertText(text, replacementRange: textView.selectedRange())
            return
        }

        if let editor = (responder as? NSTextField)?.currentEditor() as? NSTextView {
            editor.insertText(text, replacementRange: editor.selectedRange())
            return
        }

        // Fallback: send action up the responder chain
        NSApp.sendAction(#selector(NSText.insertText(_:)), to: nil, from: text as NSString)
    }
}
