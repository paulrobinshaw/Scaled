import SwiftUI

struct FinalMixFields: View {
    @Bindable var model: FormulaEditorModel

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.lg) {
                NumericInputField(
                    title: "Water",
                    systemImage: "drop.fill",
                    value: model.draft.finalMix.water,
                    onCommit: model.updateFinalWater
                )
                NumericInputField(
                    title: "Salt",
                    systemImage: "leaf",
                    value: model.draft.finalMix.salt,
                    onCommit: model.updateFinalSalt
                )
                OptionalNumericInputField(
                    title: "Yeast",
                    systemImage: "sparkles",
                    value: model.draft.finalMix.yeast,
                    onCommit: model.updateYeast
                )
            }
        }
    }
}
