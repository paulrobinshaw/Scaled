import Foundation
import Observation

/// Raw recipe as entered by user - unstructured and messy
@Observable
final class Recipe: Identifiable {
    let id = UUID()
    var name: String = ""
    var source: RecipeSource?
    var notes: String = ""
    var rawIngredients: [RawIngredient] = []
    var instructions: String = ""
    var tags: [String] = []
    var createdDate = Date()
    var lastModified = Date()

    /// Optional link to a formula if one has been created
    var formulaId: UUID?

    init() {}

    init(name: String) {
        self.name = name
    }
}

/// Source of the recipe
struct RecipeSource: Codable {
    enum SourceType: String, Codable, CaseIterable {
        case url = "URL"
        case book = "Book"
        case personal = "Personal"
        case other = "Other"
    }

    var type: SourceType
    var reference: String  // URL, book title, person's name, etc.
    var page: String?      // Page number if from a book
    var notes: String?     // Additional source notes
}

extension Recipe: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, source, notes, rawIngredients, instructions
        case tags, createdDate, lastModified, formulaId
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Note: id is auto-generated as UUID()
        name = try container.decode(String.self, forKey: .name)
        source = try container.decodeIfPresent(RecipeSource.self, forKey: .source)
        notes = try container.decode(String.self, forKey: .notes)
        rawIngredients = try container.decode([RawIngredient].self, forKey: .rawIngredients)
        instructions = try container.decode(String.self, forKey: .instructions)
        tags = try container.decode([String].self, forKey: .tags)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        lastModified = try container.decode(Date.self, forKey: .lastModified)
        formulaId = try container.decodeIfPresent(UUID.self, forKey: .formulaId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encode(notes, forKey: .notes)
        try container.encode(rawIngredients, forKey: .rawIngredients)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(tags, forKey: .tags)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastModified, forKey: .lastModified)
        try container.encodeIfPresent(formulaId, forKey: .formulaId)
    }
}