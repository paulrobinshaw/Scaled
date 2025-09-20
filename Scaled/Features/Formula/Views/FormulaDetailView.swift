import SwiftUI

struct FormulaDetailView: View {
    @Bindable var model: FormulaEditorModel
    let analysis: FormulaAnalysis
    let percentages: BakersPercentageTable
    let onSave: (Formula) -> Void

    @State private var selectedTab: Tab = .editor

    enum Tab: String, CaseIterable, Identifiable {
        case editor = "Edit"
        case analysis = "Analysis"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            header
            Picker("View", selection: $selectedTab) {
                ForEach(Tab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)

            switch selectedTab {
            case .editor:
                FormulaEditorContent(model: model, analysis: analysis)
            case .analysis:
                FormulaCalculationsView(model: model, analysis: analysis, percentages: percentages)
            }
        }
        .animation(.easeInOut, value: selectedTab)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(model.draft.name.isEmpty ? "Untitled Formula" : model.draft.name)
                    .font(Typography.title)
                    .foregroundStyle(Palette.charcoal)
                Text("Updated \(model.draft.lastModified.formatted(date: .abbreviated, time: .shortened))")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.stone)
            }
            Spacer()
            HStack(spacing: Spacing.sm) {
                Button(action: model.undo) {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .disabled(!model.canUndo)

                Button(action: model.redo) {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                }
                .disabled(!model.canRedo)

                Button {
                    onSave(model.draft)
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .tint(Palette.burntOrange)
        }
    }
}
