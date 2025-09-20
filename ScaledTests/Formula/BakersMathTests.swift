import Testing
@testable import Scaled

struct BakersMathTests {
    @Test
    func computesTotalsWithPrefermentAndSoaker() {
        let formula = TestFixtures.baseFormula(soakerWater: 50)
        #expect(Int(totalFlour(in: formula)) == 1000)
        #expect(Int(totalWater(in: formula)) == 650)
        #expect(Int(totalWeight(of: formula)) == 1666)
        #expect(Int(hydration(for: formula).rounded()) == 65)
        #expect(Int(preFermentedFlour(in: formula).rounded()) == 20)
    }

    @Test
    func scalesByYieldMaintainsPercentages() {
        let formula = TestFixtures.baseFormula()
        let scaled = scaleByYield(formula: formula, targetPieces: 4, weightPerPiece: 700)
        let scaleFactor = totalWeight(of: scaled) / totalWeight(of: formula)
        #expect(Int(totalWeight(of: scaled)) == 2800)
        #expect(abs(totalFlour(in: scaled) / totalFlour(in: formula) - scaleFactor) < 0.0001)
        #expect(Int(hydration(for: scaled).rounded()) == Int(hydration(for: formula).rounded()))
    }

    @Test
    func scalesByIngredientForSpecificFlour() {
        var formula = TestFixtures.baseFormula()
        let flourID = formula.finalMix.flours[0].id
        let scaled = scaleByIngredient(formula: formula, ingredient: .finalFlour(flourID), targetWeight: 1200)
        let newFlour = scaled.finalMix.flours.first { $0.id == flourID }?.weight ?? 0
        #expect(Int(newFlour) == 1200)
        #expect(Int(hydration(for: scaled).rounded()) == Int(hydration(for: formula).rounded()))
    }

    @Test
    func correctsMisweighByScalingOthers() {
        let formula = TestFixtures.baseFormula()
        let flourID = formula.finalMix.flours[0].id
        let result = correctMisweigh(formula: formula, measuredWeights: [.finalFlour(flourID): 1000])
        #expect(result.correctedFormula.finalMix.flours[0].weight.rounded() == 1000)
        #expect(Int(hydration(for: result.correctedFormula).rounded()) == Int(hydration(for: formula).rounded()))
    }
}
