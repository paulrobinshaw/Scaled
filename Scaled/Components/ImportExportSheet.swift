import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ImportExportSheet: View {
    @Binding var importText: String
    let coder: FormulaCoding
    let formula: Formula?
    let onImport: ([Formula]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Import JSON") {
                    TextEditor(text: $importText)
                        .frame(minHeight: 160)
                        .padding(.vertical, Spacing.xs)
                        .font(Typography.mono)
                        .background(Surface.tertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(Semantic.error)
                            .font(Typography.caption)
                    }
                    Button("Import Formulas") { importFormulas() }
                        .buttonStyle(.borderedProminent)
                        .tint(Palette.burntOrange)
                }

                if let formula {
                    Section("Export Selected") {
                        Button("Copy JSON to Clipboard") {
                            exportFormula(formula)
                        }
                    }
                }
            }
            .navigationTitle("Import / Export")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: { dismiss() })
                }
            }
            .padding(.top, Spacing.sm)
        }
    }

    private func importFormulas() {
        do {
            let data = Data(importText.utf8)
            let decoded = try coder.decodeCollection(data)
            onImport(decoded)
            importText = ""
            errorMessage = nil
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func exportFormula(_ formula: Formula) {
        do {
            let data = try coder.encode(formula)
            #if canImport(UIKit)
            UIPasteboard.general.string = String(decoding: data, as: UTF8.self)
            #endif
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
