import Foundation
import Observation

/// Raw ingredient as entered by user - needs parsing
@Observable
final class RawIngredient: Identifiable {
    var id: UUID = UUID()

    /// Original text as entered (e.g., "2 cups bread flour" or "350ml warm water")
    var text: String = ""

    /// Parsed components (may be nil if not yet parsed or unparseable)
    var parsedAmount: Double?
    var parsedUnit: String?
    var parsedName: String?

    /// User or AI categorization
    var category: IngredientCategory?

    /// Special flags
    var isPreferment: Bool = false
    var isSoaker: Bool = false
    var isForWash: Bool = false  // Egg wash, toppings, etc.

    /// Notes specific to this ingredient
    var notes: String?

    init() {}

    init(text: String, id: UUID = UUID()) {
        self.id = id
        self.text = text
    }
}

/// Categories for ingredient classification
enum IngredientCategory: String, Codable, CaseIterable {
    case flour = "Flour"
    case liquid = "Liquid"
    case salt = "Salt"
    case yeast = "Yeast"
    case starter = "Starter"
    case preferment = "Preferment"
    case soaker = "Soaker"
    case inclusion = "Inclusion"      // Nuts, seeds, dried fruit
    case enrichment = "Enrichment"    // Eggs, butter, sugar
    case other = "Other"

    var icon: String {
        switch self {
        case .flour: return "🌾"
        case .liquid: return "💧"
        case .salt: return "🧂"
        case .yeast: return "🦠"
        case .starter: return "🥖"
        case .preferment: return "⏰"
        case .soaker: return "🌊"
        case .inclusion: return "🌰"
        case .enrichment: return "🧈"
        case .other: return "📦"
        }
    }
}

extension RawIngredient: Codable {
    enum CodingKeys: String, CodingKey {
        case id, text, parsedAmount, parsedUnit, parsedName
        case category, isPreferment, isSoaker, isForWash, notes
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let decodedId = try container.decodeIfPresent(UUID.self, forKey: .id) {
            id = decodedId
        }
        text = try container.decode(String.self, forKey: .text)

        parsedAmount = try container.decodeIfPresent(Double.self, forKey: .parsedAmount)
        parsedUnit = try container.decodeIfPresent(String.self, forKey: .parsedUnit)
        parsedName = try container.decodeIfPresent(String.self, forKey: .parsedName)

        category = try container.decodeIfPresent(IngredientCategory.self, forKey: .category)

        isPreferment = try container.decode(Bool.self, forKey: .isPreferment)
        isSoaker = try container.decode(Bool.self, forKey: .isSoaker)
        isForWash = try container.decode(Bool.self, forKey: .isForWash)

        notes = try container.decodeIfPresent(String.self, forKey: .notes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)

        try container.encodeIfPresent(parsedAmount, forKey: .parsedAmount)
        try container.encodeIfPresent(parsedUnit, forKey: .parsedUnit)
        try container.encodeIfPresent(parsedName, forKey: .parsedName)

        try container.encodeIfPresent(category, forKey: .category)

        try container.encode(isPreferment, forKey: .isPreferment)
        try container.encode(isSoaker, forKey: .isSoaker)
        try container.encode(isForWash, forKey: .isForWash)

        try container.encodeIfPresent(notes, forKey: .notes)
    }
}
