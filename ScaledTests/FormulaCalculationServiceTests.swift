import Testing
@testable import Scaled

struct FormulaCalculationServiceTests {
    private let service = FormulaCalculationService()

    @Test
    func calculatesBakersPercentagesForBaselineFormula() throws {
        let formula = FormulaTestFactory.baseFormula(
            flour: 800,
            water: 400,
            salt: 16,
            prefermentFlour: 200,
            prefermentWater: 200
        )

        let table = service.calculateBakersPercentages(for: formula)

        #expect(Int(formula.totalFlour) == 1000)
        #expect(Int(formula.totalWater) == 600)
        #expect(Int(formula.overallHydration.rounded()) == 60)

        let waterRow = try #require(table.totalFormula.first { $0.ingredient == "Water" })
        #expect(Int(waterRow.weight) == 600)
        #expect(abs(waterRow.percentage - 60).isLess(than: 0.0001))

        let levainRow = try #require(table.totalFormula.first { $0.ingredient == "Levain" })
        #expect(Int(levainRow.weight) == 400)
        #expect(abs(levainRow.percentage - 40).isLess(than: 0.0001))

        let flourRows = table.finalMix.filter { $0.category == "Flour" }
        #expect(flourRows.count == 1)
        #expect(Int(flourRows[0].weight) == 800)
    }

    @Test
    func handlesFormulasWithoutFlourGracefully() {
        let formula = Formula(name: "No Flour")
        formula.finalMix.water = 100

        let table = service.calculateBakersPercentages(for: formula)

        #expect(table.totalFormula.isEmpty)
    }
}
