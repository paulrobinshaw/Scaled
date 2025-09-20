import SwiftUI

struct NumericInputField: View {
    let title: String
    let systemImage: String
    let value: Double
    let onCommit: (Double) -> Void
    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label(title, systemImage: systemImage)
                .font(Typography.caption)
                .foregroundStyle(Palette.stone)
            TextField("0", text: binding)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 120)
        }
        .onAppear { text = formatted }
    }

    private var formatted: String { String(format: "%.0f", value) }

    private var binding: Binding<String> {
        Binding(
            get: { text.isEmpty ? formatted : text },
            set: { newValue in
                text = newValue
                if let double = Double(newValue) {
                    onCommit(double)
                }
            }
        )
    }
}

struct OptionalNumericInputField: View {
    let title: String
    let systemImage: String
    let value: Double?
    let onCommit: (Double?) -> Void
    @State private var isActive: Bool = false
    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label(title, systemImage: systemImage)
                .font(Typography.caption)
                .foregroundStyle(Palette.stone)
            TextField("0", text: binding)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 120)
                .disabled(!isActive)
            Toggle("Include", isOn: $isActive)
                .font(Typography.caption)
        }
        .onAppear {
            isActive = value != nil
            text = value.map { String(format: "%.0f", $0) } ?? ""
        }
        .onChange(of: isActive) { _, include in
            if include {
                if let double = Double(text) {
                    onCommit(double)
                } else {
                    onCommit(1)
                    text = "1"
                }
            } else {
                onCommit(nil)
                text = ""
            }
        }
    }

    private var binding: Binding<String> {
        Binding(
            get: { text },
            set: { newValue in
                text = newValue
                if let double = Double(newValue) {
                    onCommit(double)
                }
            }
        )
    }
}
