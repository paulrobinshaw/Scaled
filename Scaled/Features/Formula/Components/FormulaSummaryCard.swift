import SwiftUI

struct FormulaSummaryCard: View {
    @Bindable var model: FormulaEditorModel
    let analysis: FormulaAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.lg) {
                SummaryMetric(title: "Total Flour", value: formatted(analysis.totalFlour), systemImage: "bag")
                SummaryMetric(title: "Hydration", value: String(format: "%.1f%%", analysis.hydration), systemImage: "drop")
                SummaryMetric(title: "Salt", value: String(format: "%.1f%%", analysis.saltPercentage), systemImage: "leaf")
                SummaryMetric(title: "Prefermented", value: String(format: "%.1f%%", analysis.prefermentedFlourPercentage), systemImage: "chart.pie")
            }

            HStack(spacing: Spacing.lg) {
                Stepper("Pieces: \(model.draft.yield.pieces)", value: Binding(
                    get: { model.draft.yield.pieces },
                    set: { model.updateYield(pieces: $0) }
                ), in: 1...100)

                HStack(spacing: Spacing.xs) {
                    Text("Weight per piece")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.stone)
                    TextField("Weight", value: Binding(
                        get: { model.draft.yield.weightPerPiece },
                        set: { model.updateYield(weightPerPiece: $0) }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
                    Text("g")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.stone)
                }
            }
        }
        .padding()
        .background(Surface.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func formatted(_ value: Double) -> String {
        String(format: "%.0f g", value)
    }
}

private struct SummaryMetric: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label(title, systemImage: systemImage)
                .font(Typography.caption)
                .foregroundStyle(Palette.stone)
            Text(value)
                .font(Typography.body.weight(.semibold))
                .foregroundStyle(Palette.charcoal)
        }
    }
}
