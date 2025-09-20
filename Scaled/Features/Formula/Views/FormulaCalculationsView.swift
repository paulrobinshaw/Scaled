import SwiftUI

struct FormulaCalculationsView: View {
    @Bindable var model: FormulaEditorModel
    let analysis: FormulaAnalysis
    let percentages: BakersPercentageTable

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                FormulaSummaryCard(model: model, analysis: analysis)
                warningSection
                percentageSection
            }
            .padding(.bottom, Spacing.xxl)
        }
    }

    private var warningSection: some View {
        CollapsibleSection(initiallyExpanded: false) {
            Text("Validation")
        } content: {
            if analysis.warnings.isEmpty {
                Text("No issues detected")
                    .font(Typography.body)
                    .foregroundStyle(Semantic.success)
            } else {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ForEach(analysis.warnings) { warning in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Text(warning.level.icon)
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text(warning.message)
                                    .font(Typography.body)
                                    .foregroundStyle(color(for: warning.level))
                                if let value = warning.value {
                                    Text(String(format: "%.1f", value))
                                        .font(Typography.caption)
                                        .foregroundStyle(Palette.stone)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Surface.tertiary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var percentageSection: some View {
        CollapsibleSection {
            Text("Baker's Percentages")
        } content: {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                PercentageTable(title: "Total Formula", rows: percentages.totalFormula)
                if !percentages.finalMix.isEmpty {
                    PercentageTable(title: "Final Mix", rows: percentages.finalMix)
                }
                if !percentages.preferments.isEmpty {
                    ForEach(percentages.preferments) { breakdown in
                        PercentageTable(title: breakdown.name, rows: breakdown.rows)
                    }
                }
                if !percentages.soakers.isEmpty {
                    ForEach(percentages.soakers) { breakdown in
                        PercentageTable(title: breakdown.name, rows: breakdown.rows)
                    }
                }
            }
        }
    }

    private func color(for level: ValidationWarning.Level) -> Color {
        switch level {
        case .info: return Palette.stone
        case .warning: return Semantic.warning
        case .error: return Semantic.error
        }
    }
}

private struct PercentageTable: View {
    let title: String
    let rows: [BakersPercentageRow]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(Typography.heading)
            Grid(horizontalSpacing: Spacing.md, verticalSpacing: Spacing.xs) {
                GridRow {
                    Text("Ingredient")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.stone)
                    Text("Weight")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.stone)
                    Text("%")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.stone)
                }
                ForEach(rows) { row in
                    GridRow {
                        Text(row.ingredient)
                            .font(Typography.body)
                        Text(String(format: "%.0f g", row.weight))
                            .font(Typography.caption)
                            .foregroundStyle(Palette.stone)
                        Text(String(format: "%.1f%%", row.percentage))
                            .font(Typography.body)
                            .foregroundStyle(Palette.charcoal)
                    }
                }
            }
        }
        .padding()
        .background(Surface.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
