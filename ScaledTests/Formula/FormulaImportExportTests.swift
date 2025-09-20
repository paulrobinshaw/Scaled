import Testing
@testable import Scaled

struct FormulaImportExportTests {
    private let coder = FormulaJSONCoder()

    @Test
    func roundTripsFormulaJSON() throws {
        let formula = TestFixtures.baseFormula()
        let data = try coder.encode(formula)
        let decoded = try coder.decode(data)
        #expect(decoded.name == formula.name)
        #expect(Int(totalFlour(in: decoded)) == Int(totalFlour(in: formula)))
    }

    @Test
    func roundTripsFormulaCollection() throws {
        let formulas = [TestFixtures.baseFormula(), TestFixtures.baseFormula(flour: 500, water: 350)]
        let data = try coder.encodeCollection(formulas)
        let decoded = try coder.decodeCollection(data)
        #expect(decoded.count == formulas.count)
    }
}
