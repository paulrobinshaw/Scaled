import SwiftUI

struct IngredientGridView: View {
    @Bindable var model: FormulaEditorModel

    private var totalFlourWeight: Double {
        totalFlour(in: model.draft)
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            headerRow()
            Divider()
            ForEach(model.draft.finalMix.flours) { flour in
                flourRow(for: flour)
                Divider()
            }
            controlRow()
        }
        .padding(Spacing.lg)
        .background(Surface.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func headerRow() -> some View {
        Grid(horizontalSpacing: Spacing.lg, verticalSpacing: Spacing.sm) {
            GridRow {
                Text("Ingredient")
                    .font(Typography.caption.weight(.semibold))
                    .foregroundStyle(Palette.charcoal)
                Text("Weight (g)")
                    .font(Typography.caption.weight(.semibold))
                    .foregroundStyle(Palette.charcoal)
                Text("Baker's %")
                    .font(Typography.caption.weight(.semibold))
                    .foregroundStyle(Palette.charcoal)
            }
        }
    }

    private func flourRow(for flour: Flour) -> some View {
        Grid(horizontalSpacing: Spacing.lg, verticalSpacing: Spacing.sm) {
            GridRow {
                Menu {
                    ForEach(FlourType.allCases, id: \.self) { type in
                        Button(type.rawValue) { model.updateFlourType(id: flour.id, type: type) }
                    }
                } label: {
                    Text(flour.type.rawValue)
                        .font(Typography.body)
                        .foregroundStyle(Palette.charcoal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                TextField("Weight", value: Binding(
                    get: { flour.weight },
                    set: { model.updateFlour(id: flour.id, weight: $0) }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(maxWidth: 120)

                Text(formattedPercentage(for: flour.weight))
                    .font(Typography.mono)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .alignmentGuide(.leading) { $0[.leading] }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) { model.removeFlour(id: flour.id) } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func controlRow() -> some View {
        HStack {
            Button {
                model.addFlour(type: .bread)
            } label: {
                Label("Add Flour", systemImage: "plus")
            }
            Spacer()
            Text("Total: \(formattedWeight(totalFlourWeight))")
                .font(Typography.caption)
                .foregroundStyle(Palette.charcoal)
        }
    }

    private func formattedPercentage(for weight: Double) -> String {
        guard totalFlourWeight.isSignificant else { return "–" }
        let value = weight / totalFlourWeight * 100
        return String(format: "%.1f%%", value)
    }

    private func formattedWeight(_ weight: Double) -> String {
        String(format: "%.0f g", weight)
    }
}
