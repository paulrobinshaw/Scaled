import Foundation
import Observation

@MainActor
@Observable
final class FormulaListModel {
    var formulas: [Formula] = []
    var selection: Formula.ID?
    var isLoading = false
    var error: String?

    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            formulas = try await dependencies.formulaStore.loadFormulas()
            if selection == nil {
                selection = formulas.first?.id
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func select(_ formula: Formula) {
        selection = formula.id
    }

    func selectFirstIfNeeded() {
        if selection == nil { selection = formulas.first?.id }
    }

    func createFormula() async -> Formula {
        var newFormula = Formula(name: "New Formula", yield: FormulaYield(pieces: 2, weightPerPiece: 900))
        newFormula.finalMix.flours = [Flour(type: .bread, weight: 1000)]
        newFormula.finalMix.water = 600
        newFormula.finalMix.salt = 20
        formulas.append(newFormula)
        selection = newFormula.id
        await persist()
        return newFormula
    }

    func delete(at offsets: IndexSet) async {
        formulas.remove(atOffsets: offsets)
        if let selection, !formulas.contains(where: { $0.id == selection }) {
            self.selection = formulas.first?.id
        }
        await persist()
    }

    func updateSelection(_ formula: Formula) {
        guard let index = formulas.firstIndex(where: { $0.id == formula.id }) else { return }
        formulas[index] = formula
    }

    func makeEditorModel(for formula: Formula) -> FormulaEditorModel {
        FormulaEditorModel(formula: formula)
    }

    func analysis(for formula: Formula) -> FormulaAnalysis {
        dependencies.analyzer.analyze(formula)
    }

    func percentages(for formula: Formula) -> BakersPercentageTable {
        dependencies.percentageCalculator.table(for: formula)
    }

    func coder() -> FormulaCoding { dependencies.coder }

    private func persist() async {
        try? await dependencies.formulaStore.save(formulas: formulas)
    }
}
