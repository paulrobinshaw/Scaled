import Foundation
import Observation

/// Soaker component - hydrated grains/seeds without fermentation
@Observable
final class Soaker: Identifiable {
    let id = UUID()
    var name: String = ""

    /// Grains or seeds being soaked
    var grains: [GrainItem] = []

    /// Liquid components
    var water: Double = 0
    var salt: Double?    // Optional salt in soaker

    /// Soaking parameters
    var soakHours: Double = 8      // Hours to soak
    var temperature: Double = 21    // Temperature (Celsius)
    var boilingWater: Bool = false // Use boiling water for soaking

    // MARK: - Calculated Properties

    /// Total weight of grains/seeds
    var totalGrainWeight: Double {
        grains.reduce(0) { $0 + $1.weight }
    }

    /// Total weight of the soaker
    var totalWeight: Double {
        totalGrainWeight + water + (salt ?? 0)
    }

    /// Hydration percentage of the soaker
    var hydration: Double {
        guard totalGrainWeight > 0 else { return 0 }
        return (water / totalGrainWeight) * 100
    }

    init() {}

    init(name: String) {
        self.name = name
    }

    /// Add a grain/seed item
    func addGrain(name: String, weight: Double) {
        grains.append(GrainItem(name: name, weight: weight))
    }
}

/// Individual grain or seed item in a soaker
struct GrainItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var weight: Double

    /// Common grain types for quick selection
    static let commonTypes = [
        "Sunflower Seeds",
        "Pumpkin Seeds",
        "Flax Seeds",
        "Sesame Seeds",
        "Rolled Oats",
        "Steel Cut Oats",
        "Cracked Wheat",
        "Bulgur",
        "Quinoa",
        "Millet",
        "Chia Seeds",
        "Hemp Hearts",
        "Poppy Seeds"
    ]
}

extension Soaker: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, grains
        case water, salt
        case soakHours, temperature, boilingWater
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Note: id is auto-generated as UUID()
        name = try container.decode(String.self, forKey: .name)
        grains = try container.decode([GrainItem].self, forKey: .grains)

        water = try container.decode(Double.self, forKey: .water)
        salt = try container.decodeIfPresent(Double.self, forKey: .salt)

        soakHours = try container.decode(Double.self, forKey: .soakHours)
        temperature = try container.decode(Double.self, forKey: .temperature)
        boilingWater = try container.decode(Bool.self, forKey: .boilingWater)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(grains, forKey: .grains)

        try container.encode(water, forKey: .water)
        try container.encodeIfPresent(salt, forKey: .salt)

        try container.encode(soakHours, forKey: .soakHours)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(boilingWater, forKey: .boilingWater)
    }
}