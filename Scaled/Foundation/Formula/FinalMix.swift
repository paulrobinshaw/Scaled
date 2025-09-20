import Foundation

public struct FinalMix: Hashable, Codable {
    public var flours: [Flour]
    public var water: Double
    public var salt: Double
    public var yeast: Double?
    public var inclusions: [Inclusion]
    public var enrichments: [Enrichment]
    public var mixMethod: MixMethod
    public var targetTemperature: Double

    public init(
        flours: [Flour] = [],
        water: Double = 0,
        salt: Double = 0,
        yeast: Double? = nil,
        inclusions: [Inclusion] = [],
        enrichments: [Enrichment] = [],
        mixMethod: MixMethod = .standard,
        targetTemperature: Double = 24
    ) {
        self.flours = flours
        self.water = water
        self.salt = salt
        self.yeast = yeast
        self.inclusions = inclusions
        self.enrichments = enrichments
        self.mixMethod = mixMethod
        self.targetTemperature = targetTemperature
    }
}

public struct Flour: Identifiable, Hashable, Codable {
    public var id: UUID
    public var type: FlourType
    public var weight: Double

    public init(id: UUID = UUID(), type: FlourType, weight: Double) {
        self.id = id
        self.type = type
        self.weight = weight
    }
}

public enum FlourType: String, Hashable, Codable, CaseIterable {
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

    public var proteinContent: Double {
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

public struct Inclusion: Identifiable, Hashable, Codable {
    public enum AdditionStage: String, Hashable, Codable, CaseIterable {
        case mixing = "During Mixing"
        case folding = "During Folding"
        case shaping = "During Shaping"
        case topping = "As Topping"
    }

    public var id: UUID
    public var name: String
    public var weight: Double
    public var additionStage: AdditionStage

    public init(
        id: UUID = UUID(),
        name: String,
        weight: Double,
        additionStage: AdditionStage = .mixing
    ) {
        self.id = id
        self.name = name
        self.weight = weight
        self.additionStage = additionStage
    }
}

public struct Enrichment: Identifiable, Hashable, Codable {
    public enum Kind: String, Hashable, Codable, CaseIterable {
        case butter = "Butter"
        case oil = "Oil"
        case sugar = "Sugar"
        case honey = "Honey"
        case milk = "Milk"
        case egg = "Egg"
        case other = "Other"

        public var category: String {
            switch self {
            case .butter, .oil: return "Fat"
            case .sugar, .honey: return "Sweetener"
            case .milk: return "Dairy"
            case .egg: return "Egg"
            case .other: return "Other"
            }
        }
    }

    public var id: UUID
    public var name: String
    public var weight: Double
    public var kind: Kind

    public init(id: UUID = UUID(), name: String, weight: Double, kind: Kind) {
        self.id = id
        self.name = name
        self.weight = weight
        self.kind = kind
    }
}

public enum MixMethod: String, Hashable, Codable, CaseIterable {
    case standard = "Standard"
    case autolyse = "Autolyse"
    case noKnead = "No-Knead"
    case intensive = "Intensive Mix"
    case gentle = "Gentle Mix"
}
