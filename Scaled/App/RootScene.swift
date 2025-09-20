import SwiftUI

struct RootScene: View {
    private let dependencies: AppDependencies
    @State private var listModel: FormulaListModel
    @State private var editorModel: FormulaEditorModel?
    @State private var showingImportSheet = false
    @State private var importText: String = ""

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _listModel = State(initialValue: FormulaListModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .task { await listModel.load(); updateEditorModel() }
        .onChange(of: listModel.selection) { _, _ in
            updateEditorModel()
        }
        .toolbar { toolbar }
        .background(Surface.background)
        .sheet(isPresented: $showingImportSheet) {
            ImportExportSheet(
                importText: $importText,
                coder: dependencies.coder,
                formula: editorModel?.draft,
                onImport: handleImport
            )
            .presentationDetents([.medium, .large])
        }
    }

    private var sidebar: some View {
        List(selection: $listModel.selection) {
            ForEach(listModel.formulas) { formula in
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(formula.name.isEmpty ? "Untitled Formula" : formula.name)
                        .font(Typography.body.weight(.semibold))
                        .foregroundStyle(Palette.charcoal)
                    Text(summaryLine(for: formula))
                        .font(Typography.caption)
                        .foregroundStyle(Palette.stone)
                }
                .padding(.vertical, Spacing.xs)
                .tag(formula.id)
            }
            .onDelete { indexSet in
                Task { await listModel.delete(at: indexSet) }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Formulas")
        .toolbar { sidebarToolbar }
        .background(Surface.background)
    }

    private var detail: some View {
        Group {
            if let editorModel {
                FormulaDetailView(
                    model: editorModel,
                    analysis: listModel.analysis(for: editorModel.draft),
                    percentages: listModel.percentages(for: editorModel.draft),
                    onSave: { updated in
                        listModel.updateSelection(updated)
                        Task { try? await dependencies.formulaStore.save(formulas: listModel.formulas) }
                    }
                )
                .padding()
                .background(Surface.background)
            } else {
                ContentUnavailableView(
                    "Select a Formula",
                    systemImage: "doc.text",
                    description: Text("Choose a formula or create a new one")
                )
            }
        }
    }

    private func summaryLine(for formula: Formula) -> String {
        let hydrationValue = hydration(for: formula)
        return "Hydration \(Int(round(hydrationValue)))% • \(Int(totalWeight(of: formula)))g"
    }

    private func updateEditorModel() {
        guard let selectedID = listModel.selection,
              let selected = listModel.formulas.first(where: { $0.id == selectedID }) else {
            editorModel = nil
            return
        }
        editorModel = listModel.makeEditorModel(for: selected)
    }

    private func handleImport(_ formulas: [Formula]) {
        listModel.formulas.append(contentsOf: formulas)
        listModel.selection = listModel.formulas.last?.id
        updateEditorModel()
        Task { try? await dependencies.formulaStore.save(formulas: listModel.formulas) }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                Task {
                    let formula = await listModel.createFormula()
                    listModel.selection = formula.id
                    updateEditorModel()
                }
            } label: {
                Label("New Formula", systemImage: "plus")
            }

            Button {
                showingImportSheet = true
            } label: {
                Label("Import/Export", systemImage: "square.and.arrow.down.on.square")
            }
        }
    }

    @ToolbarContentBuilder
    private var sidebarToolbar: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            if listModel.isLoading {
                ProgressView().progressViewStyle(.circular)
            }
        }
    }
}
