import SwiftUI

struct FormulaEditorContent: View {
    @Bindable var model: FormulaEditorModel
    let analysis: FormulaAnalysis

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                FormulaSummaryCard(model: model, analysis: analysis)
                FinalMixSection(model: model)
                PrefermentSoakerSection(model: model)
            }
            .padding(.bottom, Spacing.xxl)
        }
    }
}

private struct FinalMixSection: View {
    @Bindable var model: FormulaEditorModel

    var body: some View {
        CollapsibleSection {
            Text("Final Dough")
        } content: {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                IngredientGridView(model: model)
                FinalMixFields(model: model)
            }
        }
    }
}

private struct PrefermentSoakerSection: View {
    @Bindable var model: FormulaEditorModel

    var body: some View {
        CollapsibleSection {
            Text("Preferments & Soakers")
        } content: {
            VStack(spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        Text("Preferments")
                            .font(Typography.heading)
                        Spacer()
                        Button { model.addPreferment() } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                    ForEach(model.draft.preferments) { preferment in
                        PrefermentEditorRow(
                            preferment: preferment,
                            onUpdate: model.updatePreferment,
                            onRemove: { model.removePreferment(id: preferment.id) }
                        )
                    }
                }

                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        Text("Soakers")
                            .font(Typography.heading)
                        Spacer()
                        Button { model.addSoaker() } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                    ForEach(model.draft.soakers) { soaker in
                        SoakerEditorRow(
                            soaker: soaker,
                            onUpdate: model.updateSoaker,
                            onRemove: { model.removeSoaker(id: soaker.id) }
                        )
                    }
                }
            }
        }
    }
}
