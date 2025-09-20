import Foundation

public struct BakersPercentageTable: Hashable {
    public var totalFormula: [BakersPercentageRow]
    public var finalMix: [BakersPercentageRow]
    public var preferments: [PrefermentBreakdown]
    public var soakers: [SoakerBreakdown]

    public init(
        totalFormula: [BakersPercentageRow] = [],
        finalMix: [BakersPercentageRow] = [],
        preferments: [PrefermentBreakdown] = [],
        soakers: [SoakerBreakdown] = []
    ) {
        self.totalFormula = totalFormula
        self.finalMix = finalMix
        self.preferments = preferments
        self.soakers = soakers
    }
}

public struct BakersPercentageRow: Identifiable, Hashable {
    public let id: UUID
    public let ingredient: String
    public let weight: Double
    public let percentage: Double
    public let category: String

    public init(ingredient: String, weight: Double, percentage: Double, category: String) {
        self.id = UUID()
        self.ingredient = ingredient
        self.weight = weight
        self.percentage = percentage
        self.category = category
    }
}

public struct PrefermentBreakdown: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let rows: [BakersPercentageRow]

    public init(id: UUID = UUID(), name: String, rows: [BakersPercentageRow]) {
        self.id = id
        self.name = name
        self.rows = rows
    }
}

public struct SoakerBreakdown: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let rows: [BakersPercentageRow]

    public init(id: UUID = UUID(), name: String, rows: [BakersPercentageRow]) {
        self.id = id
        self.name = name
        self.rows = rows
    }
}
