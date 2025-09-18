import Foundation
import Observation

/// Preferment component of a formula
@Observable
final class Preferment: Identifiable {
    let id = UUID()
    var name: String = ""
    var type: PrefermentType = .levain

    /// Core ingredients
    var flourWeight: Double = 0  // Total flour in preferment
    var waterWeight: Double = 0  // Total water in preferment

    /// Optional components
    var starter: StarterComponent?  // For sourdough preferments
    var yeast: Double?              // For yeasted preferments (grams)

    /// Build timing
    var buildHours: Double = 12    // Hours before mixing
    var temperature: Double = 21    // Target temperature (Celsius)

    // MARK: - Calculated Properties

    /// Total weight of the preferment
    var totalWeight: Double {
        flourWeight + waterWeight + (starter?.weight ?? 0) + (yeast ?? 0)
    }

    /// Hydration percentage of the preferment
    var hydration: Double {
        guard flourWeight > 0 else { return 0 }
        return (waterWeight / flourWeight) * 100
    }

    /// Net flour contribution (accounting for starter's flour)
    var netFlourContribution: Double {
        flourWeight - (starter?.flourContribution ?? 0)
    }

    /// Net water contribution (accounting for starter's water)
    var netWaterContribution: Double {
        waterWeight - (starter?.waterContribution ?? 0)
    }

    init() {}

    init(name: String, type: PrefermentType) {
        self.name = name
        self.type = type
    }
}

/// Types of preferments
enum PrefermentType: String, Codable, CaseIterable {
    case poolish = "Poolish"        // 100% hydration, yeasted
    case biga = "Biga"              // 50-60% hydration, yeasted
    case levain = "Levain"          // Sourdough starter-based
    case pateFemented = "Pâte Fermentée"  // Old dough
    case sponge = "Sponge"          // Generic preferment

    var defaultHydration: Double {
        switch self {
        case .poolish: return 100
        case .biga: return 55
        case .levain: return 100
        case .pateFemented: return 65
        case .sponge: return 100
        }
    }

    var usesStarter: Bool {
        switch self {
        case .levain, .pateFemented: return true
        default: return false
        }
    }

    var usesYeast: Bool {
        switch self {
        case .poolish, .biga, .sponge: return true
        default: return false
        }
    }
}

/// Starter component for sourdough preferments
struct StarterComponent: Codable {
    var weight: Double              // Total starter weight
    var hydration: Double = 100     // Starter's hydration percentage

    /// Calculate flour contribution from starter
    var flourContribution: Double {
        weight / (1 + hydration / 100)
    }

    /// Calculate water contribution from starter
    var waterContribution: Double {
        weight - flourContribution
    }
}

extension Preferment: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, type
        case flourWeight, waterWeight
        case starter, yeast
        case buildHours, temperature
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Note: id is auto-generated as UUID()
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(PrefermentType.self, forKey: .type)

        flourWeight = try container.decode(Double.self, forKey: .flourWeight)
        waterWeight = try container.decode(Double.self, forKey: .waterWeight)

        starter = try container.decodeIfPresent(StarterComponent.self, forKey: .starter)
        yeast = try container.decodeIfPresent(Double.self, forKey: .yeast)

        buildHours = try container.decode(Double.self, forKey: .buildHours)
        temperature = try container.decode(Double.self, forKey: .temperature)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)

        try container.encode(flourWeight, forKey: .flourWeight)
        try container.encode(waterWeight, forKey: .waterWeight)

        try container.encodeIfPresent(starter, forKey: .starter)
        try container.encodeIfPresent(yeast, forKey: .yeast)

        try container.encode(buildHours, forKey: .buildHours)
        try container.encode(temperature, forKey: .temperature)
    }
}