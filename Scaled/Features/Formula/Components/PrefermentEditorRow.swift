import SwiftUI

struct PrefermentEditorRow: View {
    let preferment: Preferment
    let onUpdate: (Preferment) -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                TextField("Name", text: Binding(
                    get: { preferment.name },
                    set: { updateName($0) }
                ))
                .textFieldStyle(.roundedBorder)

                Picker("Type", selection: Binding(
                    get: { preferment.kind },
                    set: { updateKind($0) }
                )) {
                    ForEach(Preferment.Kind.allCases, id: \.self) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.menu)

                Button(role: .destructive, action: onRemove) {
                    Image(systemName: "trash")
                }
            }

            HStack(spacing: Spacing.md) {
                numericField(label: "Flour", value: preferment.flourWeight) { updateFlour($0) }
                numericField(label: "Water", value: preferment.waterWeight) { updateWater($0) }
                numericOptionalField(label: "Yeast", value: preferment.yeast) { updateYeast($0) }
            }

            HStack(spacing: Spacing.md) {
                numericField(label: "Build Hours", value: preferment.buildHours) { updateBuildHours($0) }
                numericOptionalField(label: "Starter", value: preferment.starter?.weight) { updateStarterWeight($0) }
                numericOptionalField(label: "Starter Hydration", value: preferment.starter?.hydration) { updateStarterHydration($0) }
            }
        }
        .padding()
        .background(Surface.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func updateName(_ value: String) {
        var updated = preferment
        updated.name = value
        onUpdate(updated)
    }

    private func updateKind(_ kind: Preferment.Kind) {
        var updated = preferment
        updated.kind = kind
        onUpdate(updated)
    }

    private func updateFlour(_ value: Double) {
        var updated = preferment
        updated.flourWeight = value
        onUpdate(updated)
    }

    private func updateWater(_ value: Double) {
        var updated = preferment
        updated.waterWeight = value
        onUpdate(updated)
    }

    private func updateYeast(_ value: Double?) {
        var updated = preferment
        updated.yeast = value
        onUpdate(updated)
    }

    private func updateBuildHours(_ value: Double) {
        var updated = preferment
        updated.buildHours = value
        onUpdate(updated)
    }

    private func updateStarterWeight(_ value: Double?) {
        var updated = preferment
        if var starter = updated.starter {
            starter.weight = value ?? 0
            updated.starter = starter
        } else if let value {
            updated.starter = Preferment.Starter(weight: value)
        } else {
            updated.starter = nil
        }
        onUpdate(updated)
    }

    private func updateStarterHydration(_ value: Double?) {
        guard var starter = preferment.starter else { return }
        if let value { starter.hydration = value }
        var updated = preferment
        updated.starter = starter
        onUpdate(updated)
    }

    private func numericField(label: String, value: Double, onCommit: @escaping (Double) -> Void) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Palette.stone)
            TextField("0", value: Binding(
                get: { value },
                set: { onCommit($0) }
            ), format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
            .frame(width: 100)
        }
    }

    private func numericOptionalField(label: String, value: Double?, onCommit: @escaping (Double?) -> Void) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Palette.stone)
            TextField("–", text: Binding(
                get: { value.map { String(format: "%.0f", $0) } ?? "" },
                set: { input in onCommit(Double(input)) }
            ))
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
            .frame(width: 100)
        }
    }
}
