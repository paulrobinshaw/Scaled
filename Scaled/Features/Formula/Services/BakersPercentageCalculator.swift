import Foundation

public protocol BakersPercentageCalculating {
    func table(for formula: Formula) -> BakersPercentageTable
}

public struct DefaultBakersPercentageCalculator: BakersPercentageCalculating {
    public init() {}

    public func table(for formula: Formula) -> BakersPercentageTable {
        let flour = totalFlour(in: formula)
        guard flour.isSignificant else { return BakersPercentageTable() }

        var table = BakersPercentageTable()
        table.totalFormula = totalFormulaRows(for: formula, totalFlour: flour)
        table.finalMix = finalMixRows(for: formula.finalMix, totalFlour: flour)
        table.preferments = formula.preferments.map { breakdown(for: $0, totalFlour: flour) }
        table.soakers = formula.soakers.map { breakdown(for: $0, totalFlour: flour) }
        return table
    }

    private func totalFormulaRows(for formula: Formula, totalFlour: Double) -> [BakersPercentageRow] {
        var rows: [BakersPercentageRow] = []

        for flour in formula.finalMix.flours {
            rows.append(
                BakersPercentageRow(
                    ingredient: flour.type.rawValue,
                    weight: flour.weight,
                    percentage: flour.weight / totalFlour * 100,
                    category: "Flour"
                )
            )
        }

        rows.append(
            BakersPercentageRow(
                ingredient: "Water",
                weight: totalWater(in: formula),
                percentage: hydration(for: formula),
                category: "Liquid"
            )
        )

        let salt = totalSalt(in: formula)
        if salt.isSignificant {
            rows.append(
                BakersPercentageRow(
                    ingredient: "Salt",
                    weight: salt,
                    percentage: saltPercentage(for: formula),
                    category: "Salt"
                )
            )
        }

        let yeast = formula.finalMix.yeast ?? 0 + formula.preferments.reduce(0) { $0 + ($1.yeast ?? 0) }
        if yeast.isSignificant {
            rows.append(
                BakersPercentageRow(
                    ingredient: "Yeast",
                    weight: yeast,
                    percentage: yeast / totalFlour * 100,
                    category: "Yeast"
                )
            )
        }

        for preferment in formula.preferments {
            rows.append(
                BakersPercentageRow(
                    ingredient: preferment.name.isEmpty ? "Preferment" : preferment.name,
                    weight: preferment.totalWeight,
                    percentage: preferment.totalWeight / totalFlour * 100,
                    category: "Preferment"
                )
            )
        }

        for soaker in formula.soakers {
            rows.append(
                BakersPercentageRow(
                    ingredient: soaker.name.isEmpty ? "Soaker" : soaker.name,
                    weight: soaker.totalWeight,
                    percentage: soaker.totalWeight / totalFlour * 100,
                    category: "Soaker"
                )
            )
        }

        for inclusion in formula.finalMix.inclusions {
            rows.append(
                BakersPercentageRow(
                    ingredient: inclusion.name,
                    weight: inclusion.weight,
                    percentage: inclusion.weight / totalFlour * 100,
                    category: "Inclusion"
                )
            )
        }

        for enrichment in formula.finalMix.enrichments {
            rows.append(
                BakersPercentageRow(
                    ingredient: enrichment.name,
                    weight: enrichment.weight,
                    percentage: enrichment.weight / totalFlour * 100,
                    category: enrichment.kind.category
                )
            )
        }

        return rows
    }

    private func finalMixRows(for finalMix: FinalMix, totalFlour: Double) -> [BakersPercentageRow] {
        var rows: [BakersPercentageRow] = []

        for flour in finalMix.flours {
            rows.append(
                BakersPercentageRow(
                    ingredient: flour.type.rawValue,
                    weight: flour.weight,
                    percentage: flour.weight / totalFlour * 100,
                    category: "Flour"
                )
            )
        }

        if finalMix.water.isSignificant {
            rows.append(
                BakersPercentageRow(
                    ingredient: "Water",
                    weight: finalMix.water,
                    percentage: finalMix.water / totalFlour * 100,
                    category: "Liquid"
                )
            )
        }

        if finalMix.salt.isSignificant {
            rows.append(
                BakersPercentageRow(
                    ingredient: "Salt",
                    weight: finalMix.salt,
                    percentage: finalMix.salt / totalFlour * 100,
                    category: "Salt"
                )
            )
        }

        if let yeast = finalMix.yeast, yeast.isSignificant {
            rows.append(
                BakersPercentageRow(
                    ingredient: "Yeast",
                    weight: yeast,
                    percentage: yeast / totalFlour * 100,
                    category: "Yeast"
                )
            )
        }

        return rows
    }

    private func breakdown(for preferment: Preferment, totalFlour: Double) -> PrefermentBreakdown {
        var rows: [BakersPercentageRow] = []
        rows.append(
            BakersPercentageRow(
                ingredient: "Flour",
                weight: preferment.flourWeight,
                percentage: preferment.flourWeight / totalFlour * 100,
                category: "Flour"
            )
        )
        rows.append(
            BakersPercentageRow(
                ingredient: "Water",
                weight: preferment.waterWeight,
                percentage: preferment.waterWeight / totalFlour * 100,
                category: "Liquid"
            )
        )
        if let starter = preferment.starter {
            rows.append(
                BakersPercentageRow(
                    ingredient: "Starter",
                    weight: starter.weight,
                    percentage: starter.weight / totalFlour * 100,
                    category: "Starter"
                )
            )
        }
        if let yeast = preferment.yeast, yeast.isSignificant {
            rows.append(
                BakersPercentageRow(
                    ingredient: "Yeast",
                    weight: yeast,
                    percentage: yeast / totalFlour * 100,
                    category: "Yeast"
                )
            )
        }
        return PrefermentBreakdown(id: preferment.id, name: preferment.name.isEmpty ? "Preferment" : preferment.name, rows: rows)
    }

    private func breakdown(for soaker: Soaker, totalFlour: Double) -> SoakerBreakdown {
        var rows: [BakersPercentageRow] = []
        for grain in soaker.grains {
            rows.append(
                BakersPercentageRow(
                    ingredient: grain.name,
                    weight: grain.weight,
                    percentage: grain.weight / totalFlour * 100,
                    category: "Grain"
                )
            )
        }
        if soaker.water.isSignificant {
            rows.append(
                BakersPercentageRow(
                    ingredient: "Water",
                    weight: soaker.water,
                    percentage: soaker.water / totalFlour * 100,
                    category: "Liquid"
                )
            )
        }
        if let salt = soaker.salt, salt.isSignificant {
            rows.append(
                BakersPercentageRow(
                    ingredient: "Salt",
                    weight: salt,
                    percentage: salt / totalFlour * 100,
                    category: "Salt"
                )
            )
        }
        return SoakerBreakdown(id: soaker.id, name: soaker.name.isEmpty ? "Soaker" : soaker.name, rows: rows)
    }
}
