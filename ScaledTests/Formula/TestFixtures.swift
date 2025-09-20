@testable import Scaled

enum TestFixtures {
    static func baseFormula(
        flour: Double = 800,
        water: Double = 400,
        salt: Double = 16,
        prefermentFlour: Double = 200,
        prefermentWater: Double = 200,
        soakerWater: Double = 0
    ) -> Formula {
        var finalMix = FinalMix(
            flours: [Flour(type: .bread, weight: flour)],
            water: water,
            salt: salt
        )
        let preferment = Preferment(
            name: "Levain",
            kind: .levain,
            flourWeight: prefermentFlour,
            waterWeight: prefermentWater
        )
        let soaker = soakerWater > 0 ? Soaker(name: "Soaker", water: soakerWater, soakHours: 6) : nil
        return Formula(
            name: "Test",
            yield: FormulaYield(pieces: 2, weightPerPiece: 900),
            preferments: prefermentFlour > 0 ? [preferment] : [],
            soakers: soaker.map { [$0] } ?? [],
            finalMix: finalMix
        )
    }
}
