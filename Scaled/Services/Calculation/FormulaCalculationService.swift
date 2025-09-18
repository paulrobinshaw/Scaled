import Foundation

/// Service for calculating baker's percentages and formula metrics
class FormulaCalculationService {

    // MARK: - Baker's Percentage Calculations

    /// Calculate complete baker's percentage table for a formula
    func calculateBakersPercentages(for formula: Formula) -> BakersPercentageTable {
        let totalFlour = formula.totalFlour

        guard totalFlour > 0 else {
            return BakersPercentageTable()
        }

        var table = BakersPercentageTable()

        // Calculate total formula percentages
        table.totalFormula = calculateTotalFormulaPercentages(formula: formula, totalFlour: totalFlour)

        // Calculate preferment breakdowns
        for preferment in formula.preferments {
            table.preferments[preferment.name] = calculatePrefermentPercentages(
                preferment: preferment,
                totalFlour: totalFlour
            )
        }

        // Calculate soaker breakdowns
        for soaker in formula.soakers {
            table.soakers[soaker.name] = calculateSoakerPercentages(
                soaker: soaker,
                totalFlour: totalFlour
            )
        }

        // Calculate final mix percentages
        table.finalMix = calculateFinalMixPercentages(
            finalMix: formula.finalMix,
            totalFlour: totalFlour
        )

        return table
    }

    // MARK: - Total Formula Calculations

    private func calculateTotalFormulaPercentages(formula: Formula, totalFlour: Double) -> [PercentageRow] {
        var rows: [PercentageRow] = []

        // All flours (should total 100%)
        let allFlours = collectAllFlours(formula: formula)
        for (flourType, weight) in allFlours {
            rows.append(PercentageRow(
                ingredient: flourType.rawValue,
                weight: weight,
                percentage: (weight / totalFlour) * 100,
                category: "Flour"
            ))
        }

        // Total water
        rows.append(PercentageRow(
            ingredient: "Water",
            weight: formula.totalWater,
            percentage: formula.overallHydration,
            category: "Liquid"
        ))

        // Total salt
        let totalSalt = formula.finalMix.salt + formula.soakers.reduce(0) { $0 + ($1.salt ?? 0) }
        if totalSalt > 0 {
            rows.append(PercentageRow(
                ingredient: "Salt",
                weight: totalSalt,
                percentage: formula.saltPercentage,
                category: "Salt"
            ))
        }

        // Total yeast (if any)
        let totalYeast = (formula.finalMix.yeast ?? 0) +
            formula.preferments.reduce(0) { $0 + ($1.yeast ?? 0) }
        if totalYeast > 0 {
            rows.append(PercentageRow(
                ingredient: "Yeast",
                weight: totalYeast,
                percentage: (totalYeast / totalFlour) * 100,
                category: "Yeast"
            ))
        }

        // Add preferments as complete units
        for preferment in formula.preferments {
            rows.append(PercentageRow(
                ingredient: preferment.name,
                weight: preferment.totalWeight,
                percentage: (preferment.totalWeight / totalFlour) * 100,
                category: "Preferment"
            ))
        }

        // Add soakers as complete units
        for soaker in formula.soakers {
            rows.append(PercentageRow(
                ingredient: soaker.name,
                weight: soaker.totalWeight,
                percentage: (soaker.totalWeight / totalFlour) * 100,
                category: "Soaker"
            ))
        }

        // Add inclusions
        for inclusion in formula.finalMix.inclusions {
            rows.append(PercentageRow(
                ingredient: inclusion.name,
                weight: inclusion.weight,
                percentage: (inclusion.weight / totalFlour) * 100,
                category: "Inclusion"
            ))
        }

        // Add enrichments
        for enrichment in formula.finalMix.enrichments {
            rows.append(PercentageRow(
                ingredient: enrichment.name,
                weight: enrichment.weight,
                percentage: (enrichment.weight / totalFlour) * 100,
                category: enrichment.type.category
            ))
        }

        return rows
    }

    // MARK: - Preferment Calculations

    private func calculatePrefermentPercentages(preferment: Preferment, totalFlour: Double) -> [PercentageRow] {
        var rows: [PercentageRow] = []

        // Flour in preferment
        rows.append(PercentageRow(
            ingredient: "Flour",
            weight: preferment.flourWeight,
            percentage: (preferment.flourWeight / totalFlour) * 100,
            category: "Flour"
        ))

        // Water in preferment
        rows.append(PercentageRow(
            ingredient: "Water",
            weight: preferment.waterWeight,
            percentage: (preferment.waterWeight / totalFlour) * 100,
            category: "Liquid"
        ))

        // Starter if present
        if let starter = preferment.starter {
            rows.append(PercentageRow(
                ingredient: "Starter (\(Int(starter.hydration))% hydration)",
                weight: starter.weight,
                percentage: (starter.weight / totalFlour) * 100,
                category: "Starter"
            ))
        }

        // Yeast if present
        if let yeast = preferment.yeast, yeast > 0 {
            rows.append(PercentageRow(
                ingredient: "Yeast",
                weight: yeast,
                percentage: (yeast / totalFlour) * 100,
                category: "Yeast"
            ))
        }

        return rows
    }

    // MARK: - Soaker Calculations

    private func calculateSoakerPercentages(soaker: Soaker, totalFlour: Double) -> [PercentageRow] {
        var rows: [PercentageRow] = []

        // Individual grains
        for grain in soaker.grains {
            rows.append(PercentageRow(
                ingredient: grain.name,
                weight: grain.weight,
                percentage: (grain.weight / totalFlour) * 100,
                category: "Grain"
            ))
        }

        // Water in soaker
        rows.append(PercentageRow(
            ingredient: "Water",
            weight: soaker.water,
            percentage: (soaker.water / totalFlour) * 100,
            category: "Liquid"
        ))

        // Salt if present
        if let salt = soaker.salt, salt > 0 {
            rows.append(PercentageRow(
                ingredient: "Salt",
                weight: salt,
                percentage: (salt / totalFlour) * 100,
                category: "Salt"
            ))
        }

        return rows
    }

    // MARK: - Final Mix Calculations

    private func calculateFinalMixPercentages(finalMix: FinalMix, totalFlour: Double) -> [PercentageRow] {
        var rows: [PercentageRow] = []

        // Flours in final mix
        for flourItem in finalMix.flours.items {
            rows.append(PercentageRow(
                ingredient: flourItem.type.rawValue,
                weight: flourItem.weight,
                percentage: (flourItem.weight / totalFlour) * 100,
                category: "Flour"
            ))
        }

        // Water in final mix
        if finalMix.water > 0 {
            rows.append(PercentageRow(
                ingredient: "Water",
                weight: finalMix.water,
                percentage: (finalMix.water / totalFlour) * 100,
                category: "Liquid"
            ))
        }

        // Salt in final mix
        if finalMix.salt > 0 {
            rows.append(PercentageRow(
                ingredient: "Salt",
                weight: finalMix.salt,
                percentage: (finalMix.salt / totalFlour) * 100,
                category: "Salt"
            ))
        }

        // Yeast in final mix
        if let yeast = finalMix.yeast, yeast > 0 {
            rows.append(PercentageRow(
                ingredient: "Yeast",
                weight: yeast,
                percentage: (yeast / totalFlour) * 100,
                category: "Yeast"
            ))
        }

        return rows
    }

    // MARK: - Helper Methods

    /// Collect all flour types and their total weights
    private func collectAllFlours(formula: Formula) -> [(FlourType, Double)] {
        var flourTotals: [FlourType: Double] = [:]

        // Flours from final mix
        for item in formula.finalMix.flours.items {
            flourTotals[item.type, default: 0] += item.weight
        }

        // For preferments, we could track flour types if needed
        // For now, preferment flour is generic

        return flourTotals.sorted { $0.value > $1.value }
    }
}

// MARK: - Data Structures

/// Complete baker's percentage table
struct BakersPercentageTable {
    var totalFormula: [PercentageRow] = []
    var preferments: [String: [PercentageRow]] = [:]
    var soakers: [String: [PercentageRow]] = [:]
    var finalMix: [PercentageRow] = []
}

/// Single row in a percentage table
struct PercentageRow: Identifiable {
    let id = UUID()
    let ingredient: String
    let weight: Double
    let percentage: Double
    let category: String
}

/// Formula validation result
struct FormulaAnalysis {
    var totalFlour: Double
    var totalWater: Double
    var totalWeight: Double
    var hydration: Double
    var saltPercentage: Double
    var prefermentedFlourPercentage: Double
    var warnings: [ValidationWarning] = []
}

/// Validation warning
struct ValidationWarning: Identifiable {
    let id = UUID()
    let level: WarningLevel
    let category: String
    let message: String
    let value: Double?
}

/// Warning severity levels
enum WarningLevel: String {
    case info = "Info"
    case warning = "Warning"
    case error = "Error"

    var icon: String {
        switch self {
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}