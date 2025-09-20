import Testing
@testable import Scaled

struct FormulaAnalyzerTests {
    private let analyzer = DefaultFormulaAnalyzer()

    @Test
    func flagsExtremeHydration() {
        let formula = TestFixtures.baseFormula(water: 900, prefermentWater: 300)
        let analysis = analyzer.analyze(formula)
        #expect(analysis.warnings.contains { $0.category == "Hydration" && $0.level == .error })
    }

    @Test
    func detectsMissingSalt() {
        let formula = TestFixtures.baseFormula(salt: 0)
        let analysis = analyzer.analyze(formula)
        #expect(analysis.warnings.contains { $0.category == "Salt" && $0.level == .error })
    }

    @Test
    func reportsHighPrefermentedFlour() {
        let formula = TestFixtures.baseFormula(prefermentFlour: 600)
        let analysis = analyzer.analyze(formula)
        #expect(analysis.warnings.contains { $0.category == "Preferment" })
    }
}
