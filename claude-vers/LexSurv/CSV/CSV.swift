import Foundation

/// Minimal RFC-4180 CSV parser and writer.
enum CSV {
    /// Parse a CSV document into rows of strings.
    /// Handles quoted fields, escaped quotes (""), and \n / \r\n line endings.
    static func parse(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var current: [String] = []
        var field = ""
        var inQuotes = false
        var i = text.startIndex

        while i < text.endIndex {
            let c = text[i]
            if inQuotes {
                if c == "\"" {
                    let next = text.index(after: i)
                    if next < text.endIndex, text[next] == "\"" {
                        field.append("\"")
                        i = text.index(after: next)
                        continue
                    } else {
                        inQuotes = false
                        i = next
                        continue
                    }
                } else {
                    field.append(c)
                }
            } else {
                switch c {
                case "\"":
                    inQuotes = true
                case ",":
                    current.append(field)
                    field = ""
                case "\r":
                    // Treat \r\n as one line ending; skip lone \r too
                    let next = text.index(after: i)
                    if next < text.endIndex, text[next] == "\n" {
                        i = next
                    }
                    current.append(field)
                    rows.append(current)
                    current = []
                    field = ""
                case "\n":
                    current.append(field)
                    rows.append(current)
                    current = []
                    field = ""
                default:
                    field.append(c)
                }
            }
            i = text.index(after: i)
        }

        if !field.isEmpty || !current.isEmpty {
            current.append(field)
            rows.append(current)
        }
        return rows
    }

    /// Serialize rows into a CSV document. All fields are quoted to be safe.
    static func encode(_ rows: [[String]]) -> String {
        rows.map { row in
            row.map { field in
                "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
            }.joined(separator: ",")
        }.joined(separator: "\n") + "\n"
    }
}
