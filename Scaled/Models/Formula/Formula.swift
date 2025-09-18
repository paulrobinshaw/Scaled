import Foundation
import Observation

/// Professional formula structure - organized and calculated
@Observable
final class Formula: Identifiable, Hashable {
    let id = UUID()

    /// Link to source recipe if exists
    var recipeId: UUID?

    /// Formula identification
    var name: String = ""
    var version: Int = 1
    var notes: String = ""

    /// Yield configuration
    var yield: FormulaYield = FormulaYield()

    /// Organized components
    var preferments: [Preferment] = []
    var soakers: [Soaker] = []
    var finalMix = FinalMix()

    /// Display preferences
    var displayMode: DisplayMode = .both
    var roundingPrecision: RoundingPrecision = .wholeGram

    /// Timestamps
    var createdDate = Date()
    var lastModified = Date()

    // MARK: - Calculated Properties

    /// Total flour from all sources (preferments + final mix)
    var totalFlour: Double {
        let flourInFinalMix = finalMix.flours.totalWeight
        let flourInPreferments = preferments.reduce(0) { $0 + $1.flourWeight }
        // Note: Soakers don't contribute flour
        return flourInFinalMix + flourInPreferments
    }

    /// Total water from all sources
    var totalWater: Double {
        let waterInFinalMix = finalMix.water
        let waterInPreferments = preferments.reduce(0) { $0 + $1.waterWeight }
        let waterInSoakers = soakers.reduce(0) { $0 + $1.water }
        return waterInFinalMix + waterInPreferments + waterInSoakers
    }

    /// Total dough weight
    var totalWeight: Double {
        let prefermentWeight = preferments.reduce(0) { $0 + $1.totalWeight }
        let soakerWeight = soakers.reduce(0) { $0 + $1.totalWeight }
        let finalMixWeight = finalMix.totalWeight
        return prefermentWeight + soakerWeight + finalMixWeight
    }

    /// Overall hydration percentage
    var overallHydration: Double {
        guard totalFlour > 0 else { return 0 }
        return (totalWater / totalFlour) * 100
    }

    /// Salt percentage relative to total flour
    var saltPercentage: Double {
        guard totalFlour > 0 else { return 0 }
        let saltInFinalMix = finalMix.salt
        let saltInSoakers = soakers.reduce(0) { $0 + ($1.salt ?? 0) }
        return ((saltInFinalMix + saltInSoakers) / totalFlour) * 100
    }

    /// Percentage of flour that's prefermented
    var prefermentedFlourPercentage: Double {
        guard totalFlour > 0 else { return 0 }
        let flourInPreferments = preferments.reduce(0) { $0 + $1.flourWeight }
        return (flourInPreferments / totalFlour) * 100
    }

    init() {}

    init(name: String) {
        self.name = name
    }
}

/// Formula yield configuration
struct FormulaYield: Codable {
    var pieces: Int = 1
    var weightPerPiece: Double = 1000  // grams

    var totalWeight: Double {
        Double(pieces) * weightPerPiece
    }
}

/// Display mode for formula presentation
enum DisplayMode: String, Codable, CaseIterable {
    case bakersPercentage = "Baker's %"
    case weight = "Weight"
    case both = "Both"
}

/// Rounding precision for display
enum RoundingPrecision: String, Codable, CaseIterable {
    case wholeGram = "1g"
    case tenthGram = "0.1g"
    case hundredthGram = "0.01g"

    var decimalPlaces: Int {
        switch self {
        case .wholeGram: return 0
        case .tenthGram: return 1
        case .hundredthGram: return 2
        }
    }
}

// MARK: - Hashable Conformance
extension Formula {
    static func == (lhs: Formula, rhs: Formula) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Codable Conformance
extension Formula: Codable {
    enum CodingKeys: String, CodingKey {
        case id, recipeId, name, version, notes
        case yield, preferments, soakers, finalMix
        case displayMode, roundingPrecision
        case createdDate, lastModified
    }

   
    
    
    
    // MARK: - Decodable
    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Note: id is let constant, auto-generated as UUID()
        // We don't decode it, each instance gets a fresh ID

        recipeId = try container.decodeIfPresent(UUID.self, forKey: .recipeId)
        name = try container.decode(String.self, forKey: .name)
        version = try container.decode(Int.self, forKey: .version)
        notes = try container.decode(String.self, forKey: .notes)

        yield = try container.decode(FormulaYield.self, forKey: .yield)
        preferments = try container.decode([Preferment].self, forKey: .preferments)
        soakers = try container.decode([Soaker].self, forKey: .soakers)
        finalMix = try container.decode(FinalMix.self, forKey: .finalMix)

        displayMode = try container.decode(DisplayMode.self, forKey: .displayMode)
        roundingPrecision = try container.decode(RoundingPrecision.self, forKey: .roundingPrecision)

        createdDate = try container.decode(Date.self, forKey: .createdDate)
        lastModified = try container.decode(Date.self, forKey: .lastModified)
        
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(recipeId, forKey: .recipeId)
        try container.encode(name, forKey: .name)
        try container.encode(version, forKey: .version)
        try container.encode(notes, forKey: .notes)

        try container.encode(yield, forKey: .yield)
        try container.encode(preferments, forKey: .preferments)
        try container.encode(soakers, forKey: .soakers)
        try container.encode(finalMix, forKey: .finalMix)

        try container.encode(displayMode, forKey: .displayMode)
        try container.encode(roundingPrecision, forKey: .roundingPrecision)

        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastModified, forKey: .lastModified)
    }
}
