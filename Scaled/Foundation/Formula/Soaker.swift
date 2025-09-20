import Foundation

public struct Soaker: Identifiable, Hashable, Codable {
    public struct Grain: Identifiable, Hashable, Codable {
        public var id: UUID
        public var name: String
        public var weight: Double

        public init(id: UUID = UUID(), name: String, weight: Double) {
            self.id = id
            self.name = name
            self.weight = weight
        }
    }

    public var id: UUID
    public var name: String
    public var grains: [Grain]
    public var water: Double
    public var salt: Double?
    public var soakHours: Double
    public var temperature: Double
    public var boilingWater: Bool

    public init(
        id: UUID = UUID(),
        name: String = "",
        grains: [Grain] = [],
        water: Double = 0,
        salt: Double? = nil,
        soakHours: Double = 8,
        temperature: Double = 21,
        boilingWater: Bool = false
    ) {
        self.id = id
        self.name = name
        self.grains = grains
        self.water = water
        self.salt = salt
        self.soakHours = soakHours
        self.temperature = temperature
        self.boilingWater = boilingWater
    }

    public var totalGrainWeight: Double {
        grains.reduce(into: 0) { $0 += $1.weight }
    }

    public var totalWeight: Double {
        totalGrainWeight + water + (salt ?? 0)
    }
}
