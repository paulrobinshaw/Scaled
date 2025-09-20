import SwiftUI

struct SoakerEditorRow: View {
    let soaker: Soaker
    let onUpdate: (Soaker) -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                TextField("Name", text: Binding(
                    get: { soaker.name },
                    set: { updateName($0) }
                ))
                .textFieldStyle(.roundedBorder)

                Button(role: .destructive, action: onRemove) {
                    Image(systemName: "trash")
                }
            }

            HStack(spacing: Spacing.md) {
                numericField(label: "Water", value: soaker.water) { updateWater($0) }
                numericOptionalField(label: "Salt", value: soaker.salt) { updateSalt($0) }
                numericField(label: "Soak Hours", value: soaker.soakHours) { updateSoakHours($0) }
            }

            Toggle("Use Boiling Water", isOn: Binding(
                get: { soaker.boilingWater },
                set: { updateBoiling($0) }
            ))
            .font(Typography.caption)
        }
        .padding()
        .background(Surface.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func updateName(_ value: String) {
        var updated = soaker
        updated.name = value
        onUpdate(updated)
    }

    private func updateWater(_ value: Double) {
        var updated = soaker
        updated.water = value
        onUpdate(updated)
    }

    private func updateSalt(_ value: Double?) {
        var updated = soaker
        updated.salt = value
        onUpdate(updated)
    }

    private func updateSoakHours(_ value: Double) {
        var updated = soaker
        updated.soakHours = value
        onUpdate(updated)
    }

    private func updateBoiling(_ value: Bool) {
        var updated = soaker
        updated.boilingWater = value
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
