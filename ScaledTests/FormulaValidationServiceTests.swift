import Testing
@testable import Scaled

struct FormulaValidationServiceTests {
    private let service = FormulaValidationService()

    @Test
    func flagsExtremelyHighHydration() {
        let formula = FormulaTestFactory.baseFormula(
            flour: 600,
            water: 500,
            prefermentFlour: 200,
            prefermentWater: 400
        )

        let warnings = service.validate(formula: formula)

        let hydrationWarning = warnings.first { $0.category == "Hydration" && $0.level == .error }
        #expect(hydrationWarning != nil)
        #expect((hydrationWarning?.value ?? 0) > 110)
    }

    @Test
    func flagsMissingSalt() {
        let formula = FormulaTestFactory.baseFormula(salt: 0)

        let warnings = service.validate(formula: formula)

        let saltWarning = warnings.first { $0.category == "Salt" && $0.level == .error }
        #expect(saltWarning != nil)
        #expect(saltWarning?.message == "No salt in formula")
    }

    @Test
    func providesNoWarningsForBalancedFormula() {
        let formula = FormulaTestFactory.baseFormula(
            flour: 800,
            water: 480,
            salt: 18,
            prefermentFlour: 200,
            prefermentWater: 200
        )

        let warnings = service.validate(formula: formula)
        #expect(warnings.allSatisfy { $0.level != .error })
    }
}
