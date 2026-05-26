#!/usr/bin/env swift
// Generates a sample `.lexsurv` FileWrapper package with a Romance-family dataset
// and **three** parallel comparisons: similarity, cognacy, identical.
//
// Usage:
//   swift scripts/generate_sample_data.swift [output_dir]

import Foundation

// MARK: - JSON-Codable model shapes (must mirror LexSurv on-disk schema)

struct GlossJSON: Codable {
    let id: String
    let primary: String
    let secondary: String
    let pos: String
    let fieldTip: String
}

struct DictJSON: Codable {
    let id: String
    let name: String
    let glosses: [GlossJSON]
}

struct TranscriptionJSON: Codable {
    let transcription: String
    let pluralFrame: String
    let notes: String
    let synonyms: [String]
}

struct VarietyJSON: Codable {
    let id: String
    let name: String
    let abbreviation: String
    let isoCode: String
    let alternateName: String
    let transcriptions: [String: TranscriptionJSON]
}

struct SurveyJSON: Codable {
    let id: String
    let name: String
    let dictionaryID: String?
    let fullTitle: String
    let notes: String
    let compiler: String
    let consultant: String
    let area: String
    let location: String
    let varieties: [VarietyJSON]
}

struct JudgmentJSON: Codable {
    let groupingCode: String
    let aligned: String
    let excluded: Bool
    let notes: String
}

struct ComparisonJSON: Codable {
    let id: String
    let name: String
    let surveyID: String?
    let type: String
    let judgments: [String: [String: JudgmentJSON]]
}

struct MetaJSON: Codable {
    let schemaVersion: Int
    let createdAt: String
    let updatedAt: String
    let appVersion: String
}

// MARK: - Deterministic UUIDs

func glossUUID(_ i: Int) -> String { String(format: "00000001-0000-0000-0000-%012X", i) }
func varietyUUID(_ i: Int) -> String { String(format: "00000002-0000-0000-0000-%012X", i) }

let dictionaryID  = "11111111-1111-1111-1111-111111111111"
let surveyID      = "22222222-2222-2222-2222-222222222222"
let similarityID  = "33333333-3333-3333-3333-333333333301"
let cognacyID     = "33333333-3333-3333-3333-333333333302"
let identicalID   = "33333333-3333-3333-3333-333333333303"

// MARK: - Dataset
//
// `cognacy` groups forms by Latin etymological source.
// `similarity` groups forms by phonetic surface similarity — same as cognacy where the
//     forms remain phonetically recognizable, with diverged forms (mostly heavily-reduced
//     French) split into their own group.
// `identical` is computed automatically below: same code iff IPA strings are literally equal.

let varietyNames: [(name: String, abbrev: String, iso: String)] = [
    ("Italian",    "ITA", "ita"),
    ("Spanish",    "SPA", "spa"),
    ("French",     "FRA", "fra"),
    ("Portuguese", "POR", "por"),
    ("Romanian",   "RON", "ron"),
]

struct Row {
    let gloss: String
    let pos: String
    let forms: [String]
    let cognacy: [String]
    let similarity: [String]
}

let rows: [Row] = [
    Row(gloss: "water",  pos: "N", forms: ["akkwa",   "aɡwa",    "o",       "aɡwɐ",     "apə"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","a","c"]),
    Row(gloss: "fire",   pos: "N", forms: ["fwɔko",   "fweɡo",   "fø",      "foɡu",     "fok"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","a","a"]),
    Row(gloss: "sun",    pos: "N", forms: ["sole",    "sol",     "sɔlɛj",   "sɔl",      "soare"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
    Row(gloss: "moon",   pos: "N", forms: ["luna",    "luna",    "lyn",     "luɐ",      "lunə"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
    Row(gloss: "star",   pos: "N", forms: ["stella",  "estreʎa", "etwal",   "iʃtrelɐ",  "ste̯a"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
    Row(gloss: "head",   pos: "N", forms: ["testa",   "kaβesa",  "tɛt",     "kɐβesɐ",   "kap"],
        cognacy:    ["a","b","a","b","b"],
        similarity: ["a","b","a","b","b"]),
    Row(gloss: "eye",    pos: "N", forms: ["ɔkkjo",   "oxo",     "œj",      "oʎu",      "okʲ"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
    Row(gloss: "ear",    pos: "N", forms: ["orɛkkjo", "oreha",   "oʁɛj",    "oɾeɐ",    "ureke"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
    Row(gloss: "nose",   pos: "N", forms: ["nazo",    "naɾiθ",   "ne",      "nɐɾis",    "nas"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","a","a"]),
    Row(gloss: "mouth",  pos: "N", forms: ["bokka",   "boka",    "buʃ",     "bokɐ",     "gurə"],
        cognacy:    ["a","a","a","a","b"],
        similarity: ["a","a","a","a","b"]),
    Row(gloss: "tooth",  pos: "N", forms: ["dente",   "djente",  "dɑ̃",    "dẽtʃi",    "dinte"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","a","a"]),
    Row(gloss: "tongue", pos: "N", forms: ["liŋɡwa",  "leŋɡwa",  "lɑ̃ɡ",   "lĩɡwɐ",    "limbə"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
    Row(gloss: "hand",   pos: "N", forms: ["mano",    "mano",    "mɛ̃",    "mɐ̃w",     "mɨnə"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","a","a"]),
    Row(gloss: "foot",   pos: "N", forms: ["pjɛde",   "pje",     "pje",     "pɛ",       "pitʃor"],
        cognacy:    ["a","a","a","a","b"],
        similarity: ["a","a","a","a","b"]),
    Row(gloss: "heart",  pos: "N", forms: ["kwɔre",   "koɾaθon", "kœʁ",     "koɾɐsɐ̃w", "inimə"],
        cognacy:    ["a","a","a","a","b"],
        similarity: ["a","a","a","a","b"]),
    Row(gloss: "blood",  pos: "N", forms: ["saŋɡwe",  "saŋɡre",  "sɑ̃",    "sɐ̃ɡi",    "sɨnʤe"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","a","c"]),
    Row(gloss: "bone",   pos: "N", forms: ["ɔsso",    "weso",    "ɔs",      "ɔsu",      "os"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","b","a","a","a"]),
    Row(gloss: "skin",   pos: "N", forms: ["pɛlle",   "pjel",    "po",      "pelɨ",     "pjele"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","a","a"]),
    Row(gloss: "dog",    pos: "N", forms: ["kane",    "pero",    "ʃjɛ̃",   "kɐ̃w",     "kɨjne"],
        cognacy:    ["a","b","a","a","a"],
        similarity: ["a","b","c","a","a"]),
    Row(gloss: "bird",   pos: "N", forms: ["utʃɛllo", "paxaro",  "wazo",    "pasɐɾu",   "pasəre"],
        cognacy:    ["a","b","c","b","b"],
        similarity: ["a","b","c","b","b"]),
    Row(gloss: "fish",   pos: "N", forms: ["peʃe",    "peθ",     "pwasɔ̃", "pejʃɨ",    "peʃte"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","a","a"]),
    Row(gloss: "tree",   pos: "N", forms: ["albero",  "aɾβol",   "aʁbʁ",    "aɾvuɾɨ",   "arbore"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
    Row(gloss: "stone",  pos: "N", forms: ["pjɛtra",  "pjedra",  "pjɛʁ",    "pɛdɾɐ",    "pjatrə"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
    Row(gloss: "night",  pos: "N", forms: ["nɔtte",   "notʃe",   "nɥi",     "nojtʃi",   "noapte"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","a","a"]),
    Row(gloss: "rain",   pos: "N", forms: ["pjɔʤa",   "ʎuβja",   "plɥi",    "ʃuvɐ",     "ploaje"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","b","a","c","a"]),
    Row(gloss: "good",   pos: "A", forms: ["bwɔno",   "bweno",   "bɔ̃",    "bõ",       "bun"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","a","a"]),
    Row(gloss: "new",    pos: "A", forms: ["nwɔvo",   "nweβo",   "nuvo",    "novu",     "nou"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
    Row(gloss: "one",    pos: "Q", forms: ["uno",     "uno",     "œ̃",     "ũ",        "unu"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","b","c","a"]),
    Row(gloss: "two",    pos: "Q", forms: ["due",     "dos",     "dø",      "dojʃ",     "doj"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
    Row(gloss: "three",  pos: "Q", forms: ["tre",     "tres",    "tʁwa",    "trejʃ",    "trej"],
        cognacy:    ["a","a","a","a","a"],
        similarity: ["a","a","a","a","a"]),
]

precondition(varietyNames.count == 5, "Variety count mismatch")
for r in rows {
    precondition(r.forms.count == 5 && r.cognacy.count == 5 && r.similarity.count == 5,
                 "Row \"\(r.gloss)\" has wrong column count")
}

// MARK: - Compute identical-comparison codes from the form list.

/// Returns codes such that two indices share a code iff their forms are byte-equal,
/// and singletons get an empty code (so they don't contribute to the tally).
func identicalCodes(forms: [String]) -> [String] {
    var codes = Array(repeating: "", count: forms.count)
    var counter = 0
    func nextLabel() -> String {
        // a, b, c, …, z, aa, ab …
        var n = counter
        counter += 1
        var s = ""
        repeat {
            let r = n % 26
            s = String(UnicodeScalar(UInt8(97 + r))) + s
            n = n / 26 - 1
        } while n >= 0
        return s
    }
    var assigned: [String: String] = [:]
    var matchedIndices = Set<Int>()
    for i in 0..<forms.count {
        guard !forms[i].isEmpty else { continue }
        for j in (i + 1)..<forms.count {
            guard forms[i] == forms[j] else { continue }
            let label = assigned[forms[i]] ?? nextLabel()
            assigned[forms[i]] = label
            codes[i] = label
            codes[j] = label
            matchedIndices.insert(i)
            matchedIndices.insert(j)
        }
    }
    _ = matchedIndices
    return codes
}

// MARK: - Build encoded entities

let glosses: [GlossJSON] = rows.enumerated().map { (i, row) in
    GlossJSON(id: glossUUID(i + 1), primary: row.gloss, secondary: "", pos: row.pos, fieldTip: "")
}

let dict = DictJSON(
    id: dictionaryID,
    name: "Romance basic vocabulary",
    glosses: glosses
)

let varieties: [VarietyJSON] = varietyNames.enumerated().map { (vi, info) in
    var trans: [String: TranscriptionJSON] = [:]
    for (gi, row) in rows.enumerated() {
        let id = glossUUID(gi + 1)
        let form = row.forms[vi]
        if !form.isEmpty {
            trans[id] = TranscriptionJSON(
                transcription: form,
                pluralFrame: "",
                notes: "",
                synonyms: []
            )
        }
    }
    return VarietyJSON(
        id: varietyUUID(vi + 1),
        name: info.name,
        abbreviation: info.abbrev,
        isoCode: info.iso,
        alternateName: "",
        transcriptions: trans
    )
}

let survey = SurveyJSON(
    id: surveyID,
    name: "Romance languages",
    dictionaryID: dictionaryID,
    fullTitle: "Romance basic-vocabulary survey",
    notes: "Sample dataset bundled with LexSurv. Transcriptions are simplified IPA.",
    compiler: "LexSurv sample",
    consultant: "",
    area: "Europe",
    location: "",
    varieties: varieties
)

func makeComparison(
    id: String,
    name: String,
    type: String,
    codeRowSelector: (Row) -> [String]
) -> ComparisonJSON {
    var judgments: [String: [String: JudgmentJSON]] = [:]
    for (gi, row) in rows.enumerated() {
        let glossID = glossUUID(gi + 1)
        var perVariety: [String: JudgmentJSON] = [:]
        let codes = codeRowSelector(row)
        for (vi, _) in varietyNames.enumerated() {
            let vID = varietyUUID(vi + 1)
            perVariety[vID] = JudgmentJSON(
                groupingCode: codes[vi],
                aligned: "",
                excluded: false,
                notes: ""
            )
        }
        judgments[glossID] = perVariety
    }
    return ComparisonJSON(
        id: id, name: name, surveyID: surveyID, type: type, judgments: judgments
    )
}

let similarityComparison = makeComparison(
    id: similarityID,
    name: "Lexical similarity",
    type: "similarity",
    codeRowSelector: { $0.similarity }
)

let cognacyComparison = makeComparison(
    id: cognacyID,
    name: "Lexical cognacy",
    type: "cognacy",
    codeRowSelector: { $0.cognacy }
)

let identicalComparison = makeComparison(
    id: identicalID,
    name: "Identical words",
    type: "identical",
    codeRowSelector: { identicalCodes(forms: $0.forms) }
)

let isoFormatter = ISO8601DateFormatter()
let now = isoFormatter.string(from: Date())
let meta = MetaJSON(
    schemaVersion: 1,
    createdAt: now,
    updatedAt: now,
    appVersion: "0.1.0"
)

// MARK: - Write package

let outputDir = URL(fileURLWithPath: CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "SampleData")
let packageURL = outputDir.appendingPathComponent("Romance.lexsurv", isDirectory: true)

let fm = FileManager.default
if fm.fileExists(atPath: packageURL.path) {
    try? fm.removeItem(at: packageURL)
}
try fm.createDirectory(at: packageURL, withIntermediateDirectories: true)
try fm.createDirectory(at: packageURL.appendingPathComponent("dictionaries"), withIntermediateDirectories: true)
try fm.createDirectory(at: packageURL.appendingPathComponent("surveys"), withIntermediateDirectories: true)
try fm.createDirectory(at: packageURL.appendingPathComponent("comparisons"), withIntermediateDirectories: true)

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

func write<T: Encodable>(_ value: T, to url: URL) throws {
    let data = try encoder.encode(value)
    try data.write(to: url)
}

try write(meta, to: packageURL.appendingPathComponent("meta.json"))
try write(dict, to: packageURL.appendingPathComponent("dictionaries/\(dictionaryID).json"))
try write(survey, to: packageURL.appendingPathComponent("surveys/\(surveyID).json"))
try write(similarityComparison, to: packageURL.appendingPathComponent("comparisons/\(similarityID).json"))
try write(cognacyComparison,    to: packageURL.appendingPathComponent("comparisons/\(cognacyID).json"))
try write(identicalComparison,  to: packageURL.appendingPathComponent("comparisons/\(identicalID).json"))

print("Wrote sample package: \(packageURL.path)")
print("  • Dictionary: \(rows.count) glosses")
print("  • Survey: \(varietyNames.count) varieties (\(varietyNames.map { $0.abbrev }.joined(separator: ", ")))")
print("  • Comparisons: similarity, cognacy, identical")
