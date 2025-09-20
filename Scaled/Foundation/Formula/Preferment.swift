import Foundation

public struct Preferment: Identifiable, Hashable, Codable {
    public enum Kind: String, Hashable, Codable, CaseIterable {
        case poolish = "Poolish"
        case biga = "Biga"
        case levain = "Levain"
        case pateFermentee = "Pâte Fermentée"
        case sponge = "Sponge"

        public var defaultHydration: Double {
            switch self {
            case .poolish, .levain, .sponge: return 100
            case .biga: return 55
            case .pateFermentee: return 65
            }
        }

        public var usesStarter: Bool {
            switch self {
            case .levain, .pateFermentee: return true
            default: return false
            }
        }

        public var usesYeast: Bool {
            switch self {
            case .poolish, .biga, .sponge: return true
            default: return false
            }
        }
    }

    public struct Starter: Hashable, Codable {
        public var weight: Double
        public var hydration: Double

        public init(weight: Double, hydration: Double = 100) {
            self.weight = weight
            self.hydration = hydration
        }

        public var flourContribution: Double {
            guard hydration > -100 else { return 0 }
            return weight / (1 + hydration / 100)
        }

        public var waterContribution: Double {
            weight - flourContribution
        }
    }

    public var id: UUID
    public var name: String
    public var kind: Kind
    public var flourWeight: Double
    public var waterWeight: Double
    public var starter: Starter?
    public var yeast: Double?
    public var buildHours: Double
    public var temperature: Double

    public var hydration: Double {
        guard flourWeight.isSignificant else { return 0 }
        return waterWeight / flourWeight * 100
    }

    public init(
        id: UUID = UUID(),
        name: String = "",
        kind: Kind = .levain,
        flourWeight: Double = 0,
        waterWeight: Double = 0,
        starter: Starter? = nil,
        yeast: Double? = nil,
        buildHours: Double = 12,
        temperature: Double = 21
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.flourWeight = flourWeight
        self.waterWeight = waterWeight
        self.starter = starter
        self.yeast = yeast
        self.buildHours = buildHours
        self.temperature = temperature
    }

    public var totalWeight: Double {
        flourWeight + waterWeight + (starter?.weight ?? 0) + (yeast ?? 0)
    }
}
