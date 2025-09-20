import Foundation

public protocol FormulaAnalyzing {
    func analyze(_ formula: Formula) -> FormulaAnalysis
}

public struct FormulaAnalysis: Hashable {
    public let totalFlour: Double
    public let totalWater: Double
    public let totalWeight: Double
    public let hydration: Double
    public let saltPercentage: Double
    public let prefermentedFlourPercentage: Double
    public let warnings: [ValidationWarning]

    public init(
        totalFlour: Double,
        totalWater: Double,
        totalWeight: Double,
        hydration: Double,
        saltPercentage: Double,
        prefermentedFlourPercentage: Double,
        warnings: [ValidationWarning]
    ) {
        self.totalFlour = totalFlour
        self.totalWater = totalWater
        self.totalWeight = totalWeight
        self.hydration = hydration
        self.saltPercentage = saltPercentage
        self.prefermentedFlourPercentage = prefermentedFlourPercentage
        self.warnings = warnings
    }
}

public struct ValidationWarning: Identifiable, Hashable {
    public enum Level: String, Hashable {
        case info
        case warning
        case error

        public var icon: String {
            switch self {
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            }
        }
    }

    public let id: UUID
    public let level: Level
    public let category: String
    public let message: String
    public let value: Double?

    public init(level: Level, category: String, message: String, value: Double? = nil) {
        self.id = UUID()
        self.level = level
        self.category = category
        self.message = message
        self.value = value
    }
}

public struct ValidationSummary: Hashable {
    public let hasErrors: Bool
    public let errorCount: Int
    public let warningCount: Int
    public let infoCount: Int
    public var totalIssues: Int { errorCount + warningCount + infoCount }
}

public struct DefaultFormulaAnalyzer: FormulaAnalyzing {
    public struct Thresholds {
        public var minHydration: Double = 55
        public var lowHydration: Double = 60
        public var highHydration: Double = 85
        public var extremeHydration: Double = 110
        public var minSaltPercentage: Double = 1.5
        public var maxSaltPercentage: Double = 3.0
        public var maxPrefermentedFlour: Double = 50
    }

    private let thresholds: Thresholds

    public init(thresholds: Thresholds = .init()) {
        self.thresholds = thresholds
    }

    public func analyze(_ formula: Formula) -> FormulaAnalysis {
        let totals = computeTotals(for: formula)
        let warnings = validate(formula: formula, totals: totals)
        return FormulaAnalysis(
            totalFlour: totals.flour,
            totalWater: totals.water,
            totalWeight: totals.weight,
            hydration: totals.hydration,
            saltPercentage: totals.saltPercentage,
            prefermentedFlourPercentage: totals.prefermentedFlour,
            warnings: warnings
        )
    }

    private func computeTotals(for formula: Formula) -> (flour: Double, water: Double, weight: Double, hydration: Double, saltPercentage: Double, prefermentedFlour: Double) {
        let flour = totalFlour(in: formula)
        return (
            flour: flour,
            water: totalWater(in: formula),
            weight: totalWeight(of: formula),
            hydration: hydration(for: formula),
            saltPercentage: saltPercentage(for: formula),
            prefermentedFlour: preFermentedFlour(in: formula)
        )
    }

    private func validate(formula: Formula, totals: (flour: Double, water: Double, weight: Double, hydration: Double, saltPercentage: Double, prefermentedFlour: Double)) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []
        warnings.append(contentsOf: criticalChecks(formula: formula, totals: totals))
        if warnings.contains(where: { $0.level == .error }) {
            return warnings
        }
        warnings.append(contentsOf: hydrationChecks(totals.hydration))
        warnings.append(contentsOf: saltChecks(totals.saltPercentage))
        warnings.append(contentsOf: prefermentedFlourChecks(totals.prefermentedFlour))
        warnings.append(contentsOf: yeastChecks(formula: formula, totals: totals))
        warnings.append(contentsOf: prefermentChecks(formula.preferments))
        warnings.append(contentsOf: soakerChecks(formula.soakers))
        warnings.append(contentsOf: inclusionChecks(formula: formula, totals: totals))
        return warnings
    }

    private func criticalChecks(
        formula: Formula,
        totals: (flour: Double, water: Double, weight: Double, hydration: Double, saltPercentage: Double, prefermentedFlour: Double)
    ) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []
        if !totals.flour.isSignificant {
            warnings.append(ValidationWarning(level: .error, category: "Flour", message: "Formula must contain flour", value: totals.flour))
        }
        if !totals.water.isSignificant {
            warnings.append(ValidationWarning(level: .error, category: "Water", message: "Formula must contain water", value: totals.water))
        }
        let hasYeast = (formula.finalMix.yeast ?? 0).isSignificant || formula.preferments.contains { ($0.yeast ?? 0).isSignificant }
        let hasStarter = formula.preferments.contains { $0.starter != nil }
        if !hasYeast && !hasStarter {
            warnings.append(ValidationWarning(level: .warning, category: "Leavening", message: "No yeast or starter detected"))
        }
        return warnings
    }

    private func hydrationChecks(_ hydration: Double) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []
        switch hydration {
        case ..<45:
            warnings.append(ValidationWarning(level: .error, category: "Hydration", message: "Extremely low hydration", value: hydration))
        case 45..<thresholds.minHydration:
            warnings.append(ValidationWarning(level: .warning, category: "Hydration", message: "Very dry dough", value: hydration))
        case thresholds.highHydration..<thresholds.extremeHydration:
            warnings.append(ValidationWarning(level: .warning, category: "Hydration", message: "Very high hydration", value: hydration))
        case thresholds.extremeHydration...:
            warnings.append(ValidationWarning(level: .error, category: "Hydration", message: "Extremely high hydration", value: hydration))
        default:
            break
        }
        return warnings
    }

    private func saltChecks(_ saltPercentage: Double) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []
        switch saltPercentage {
        case 0:
            warnings.append(ValidationWarning(level: .error, category: "Salt", message: "No salt in formula", value: 0))
        case 0..<1.0:
            warnings.append(ValidationWarning(level: .warning, category: "Salt", message: "Very low salt", value: saltPercentage))
        case 1.0..<thresholds.minSaltPercentage:
            warnings.append(ValidationWarning(level: .info, category: "Salt", message: "Low salt", value: saltPercentage))
        case thresholds.maxSaltPercentage..<3.5:
            warnings.append(ValidationWarning(level: .info, category: "Salt", message: "High salt", value: saltPercentage))
        case 3.5...:
            warnings.append(ValidationWarning(level: .warning, category: "Salt", message: "Very high salt", value: saltPercentage))
        default:
            break
        }
        return warnings
    }

    private func prefermentedFlourChecks(_ percentage: Double) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []
        switch percentage {
        case thresholds.maxPrefermentedFlour..<60:
            warnings.append(ValidationWarning(level: .info, category: "Preferment", message: "High prefermented flour", value: percentage))
        case 60...:
            warnings.append(ValidationWarning(level: .warning, category: "Preferment", message: "Prefermented flour very high", value: percentage))
        default:
            break
        }
        return warnings
    }

    private func yeastChecks(
        formula: Formula,
        totals: (flour: Double, water: Double, weight: Double, hydration: Double, saltPercentage: Double, prefermentedFlour: Double)
    ) -> [ValidationWarning] {
        guard totals.flour.isSignificant else { return [] }
        let totalYeast = (formula.finalMix.yeast ?? 0) + formula.preferments.reduce(0) { $0 + ($1.yeast ?? 0) }
        let yeastPercentage = totalYeast / totals.flour * 100
        if yeastPercentage >= 3 {
            return [ValidationWarning(level: .warning, category: "Yeast", message: "High yeast content", value: yeastPercentage)]
        }
        if yeastPercentage < 0.2 && !formula.preferments.contains(where: { $0.starter != nil }) {
            return [ValidationWarning(level: .info, category: "Yeast", message: "Low yeast content", value: yeastPercentage)]
        }
        return []
    }

    private func prefermentChecks(_ preferments: [Preferment]) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []
        for preferment in preferments {
            switch preferment.kind {
            case .poolish:
                if abs(preferment.hydration - 100) > 5 {
                    warnings.append(ValidationWarning(level: .info, category: "Preferment", message: "\(preferment.name) hydration deviates from typical poolish", value: preferment.hydration))
                }
            case .biga:
                if preferment.hydration < 45 || preferment.hydration > 65 {
                    warnings.append(ValidationWarning(level: .info, category: "Preferment", message: "\(preferment.name) hydration atypical for biga", value: preferment.hydration))
                }
            default:
                break
            }
            if preferment.buildHours < 4 {
                warnings.append(ValidationWarning(level: .warning, category: "Timing", message: "\(preferment.name) build time is short", value: preferment.buildHours))
            } else if preferment.buildHours > 24 {
                warnings.append(ValidationWarning(level: .info, category: "Timing", message: "\(preferment.name) build time is long", value: preferment.buildHours))
            }
        }
        return warnings
    }

    private func soakerChecks(_ soakers: [Soaker]) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []
        for soaker in soakers {
            let hydration = soaker.totalGrainWeight.isSignificant ? soaker.water / soaker.totalGrainWeight * 100 : 0
            if hydration < 50 {
                warnings.append(ValidationWarning(level: .warning, category: "Soaker", message: "\(soaker.name) hydration is low", value: hydration))
            } else if hydration > 200 {
                warnings.append(ValidationWarning(level: .info, category: "Soaker", message: "\(soaker.name) hydration is high", value: hydration))
            }
            if soaker.soakHours < 2 && !soaker.boilingWater {
                warnings.append(ValidationWarning(level: .warning, category: "Soaker", message: "\(soaker.name) soak time is short", value: soaker.soakHours))
            }
        }
        return warnings
    }

    private func inclusionChecks(
        formula: Formula,
        totals: (flour: Double, water: Double, weight: Double, hydration: Double, saltPercentage: Double, prefermentedFlour: Double)
    ) -> [ValidationWarning] {
        guard totals.flour.isSignificant else { return [] }
        var warnings: [ValidationWarning] = []
        let inclusionWeight = formula.finalMix.inclusions.reduce(0) { $0 + $1.weight }
        let inclusionPercentage = inclusionWeight / totals.flour * 100
        if inclusionPercentage > 30 {
            warnings.append(ValidationWarning(level: .warning, category: "Inclusions", message: "High inclusion percentage", value: inclusionPercentage))
        }
        let enrichmentWeight = formula.finalMix.enrichments.reduce(0) { $0 + $1.weight }
        let enrichmentPercentage = enrichmentWeight / totals.flour * 100
        if enrichmentPercentage > 20 {
            warnings.append(ValidationWarning(level: .info, category: "Enrichments", message: "Enriched dough detected", value: enrichmentPercentage))
        }
        return warnings
    }
}
