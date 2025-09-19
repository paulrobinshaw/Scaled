import Foundation
import Observation

/// Final mix components after preferments and soakers
@Observable
final class FinalMix: Identifiable {
    var id: UUID = UUID()

    /// Flour components
    var flours = FlourComponent()

    /// Basic ingredients
    var water: Double = 0
    var salt: Double = 0
    var yeast: Double?    // Optional if using only sourdough

    /// Additional components
    var inclusions: [Inclusion] = []
    var enrichments: [Enrichment] = []

    /// Mix parameters
    var mixMethod: MixMethod = .standard
    var targetTemperature: Double = 24  // Celsius

    // MARK: - Calculated Properties

    /// Total weight of the final mix (excluding preferments and soakers)
    var totalWeight: Double {
        flours.totalWeight +
        water +
        salt +
        (yeast ?? 0) +
        inclusions.reduce(0) { $0 + $1.weight } +
        enrichments.reduce(0) { $0 + $1.weight }
    }

    /// Hydration of just the final mix
    var finalMixHydration: Double {
        guard flours.totalWeight > 0 else { return 0 }
        return (water / flours.totalWeight) * 100
    }

    init() {}
}

/// Flour component containing multiple flour types
struct FlourComponent: Codable {
    var items: [FlourItem] = []

    var totalWeight: Double {
        items.reduce(0) { $0 + $1.weight }
    }

    /// Get weight of specific flour type
    func weight(for type: FlourType) -> Double {
        items.filter { $0.type == type }.reduce(0) { $0 + $1.weight }
    }

    /// Add or update flour item
    mutating func addFlour(type: FlourType, weight: Double) {
        if let index = items.firstIndex(where: { $0.type == type }) {
            items[index].weight += weight
        } else {
            items.append(FlourItem(type: type, weight: weight))
        }
    }
}

/// Individual flour item
struct FlourItem: Identifiable, Codable {
    let id = UUID()
    var type: FlourType
    var weight: Double
}

/// Types of flour
enum FlourType: String, Codable, CaseIterable {
    case bread = "Bread Flour"
    case allPurpose = "All-Purpose Flour"
    case wholeWheat = "Whole Wheat"
    case rye = "Rye"
    case spelt = "Spelt"
    case einkorn = "Einkorn"
    case kamut = "Kamut"
    case durum = "Durum"
    case semolina = "Semolina"
    case cake = "Cake Flour"
    case pastry = "Pastry Flour"
    case other = "Other"

    /// Typical protein content percentage
    var proteinContent: Double {
        switch self {
        case .bread: return 12.5
        case .allPurpose: return 10.5
        case .wholeWheat: return 14.0
        case .rye: return 9.0
        case .spelt: return 12.0
        case .einkorn: return 18.0
        case .kamut: return 14.0
        case .durum: return 13.0
        case .semolina: return 12.5
        case .cake: return 8.0
        case .pastry: return 9.0
        case .other: return 11.0
        }
    }
}

/// Inclusion - items added during mixing or folding
struct Inclusion: Identifiable, Codable {
    let id = UUID()
    var name: String
    var weight: Double
    var additionStage: AdditionStage = .mixing

    /// Common inclusion types
    static let commonTypes = [
        "Walnuts",
        "Pecans",
        "Hazelnuts",
        "Almonds",
        "Raisins",
        "Cranberries",
        "Dates",
        "Figs",
        "Olives",
        "Sun-dried Tomatoes",
        "Roasted Garlic",
        "Herbs",
        "Cheese"
    ]
}

/// Enrichment - fats, sugars, dairy, eggs
struct Enrichment: Identifiable, Codable {
    let id = UUID()
    var name: String
    var weight: Double
    var type: EnrichmentType
}

/// Types of enrichments
enum EnrichmentType: String, Codable, CaseIterable {
    case butter = "Butter"
    case oil = "Oil"
    case sugar = "Sugar"
    case honey = "Honey"
    case milk = "Milk"
    case egg = "Egg"
    case other = "Other"

    var category: String {
        switch self {
        case .butter, .oil: return "Fat"
        case .sugar, .honey: return "Sweetener"
        case .milk: return "Dairy"
        case .egg: return "Egg"
        case .other: return "Other"
        }
    }
}

/// When to add inclusions
enum AdditionStage: String, Codable, CaseIterable {
    case mixing = "During Mixing"
    case folding = "During Folding"
    case shaping = "During Shaping"
    case topping = "As Topping"
}

/// Mixing method
enum MixMethod: String, Codable, CaseIterable {
    case standard = "Standard"
    case autolyse = "Autolyse"
    case noKnead = "No-Knead"
    case intensive = "Intensive Mix"
    case gentle = "Gentle Mix"
}

extension FinalMix: Codable {
    enum CodingKeys: String, CodingKey {
        case id, flours, water, salt, yeast
        case inclusions, enrichments
        case mixMethod, targetTemperature
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let decodedId = try container.decodeIfPresent(UUID.self, forKey: .id) {
            id = decodedId
        }
        flours = try container.decode(FlourComponent.self, forKey: .flours)
        water = try container.decode(Double.self, forKey: .water)
        salt = try container.decode(Double.self, forKey: .salt)
        yeast = try container.decodeIfPresent(Double.self, forKey: .yeast)
        inclusions = try container.decode([Inclusion].self, forKey: .inclusions)
        enrichments = try container.decode([Enrichment].self, forKey: .enrichments)
        mixMethod = try container.decode(MixMethod.self, forKey: .mixMethod)
        targetTemperature = try container.decode(Double.self, forKey: .targetTemperature)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(flours, forKey: .flours)
        try container.encode(water, forKey: .water)
        try container.encode(salt, forKey: .salt)
        try container.encodeIfPresent(yeast, forKey: .yeast)
        try container.encode(inclusions, forKey: .inclusions)
        try container.encode(enrichments, forKey: .enrichments)
        try container.encode(mixMethod, forKey: .mixMethod)
        try container.encode(targetTemperature, forKey: .targetTemperature)
    }
}
