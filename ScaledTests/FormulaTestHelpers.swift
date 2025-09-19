@testable import Scaled

struct FormulaTestFactory {
    static func baseFormula(
        flour: Double = 800,
        water: Double = 400,
        salt: Double = 16,
        prefermentFlour: Double = 200,
        prefermentWater: Double = 200,
        inclusions: [(name: String, weight: Double)] = []
    ) -> Formula {
        let formula = Formula(name: "Test Formula")

        formula.finalMix.flours.addFlour(type: .bread, weight: flour)
        formula.finalMix.water = water
        formula.finalMix.salt = salt

        if prefermentFlour > 0 || prefermentWater > 0 {
            let levain = Preferment(name: "Levain", type: .levain)
            levain.flourWeight = prefermentFlour
            levain.waterWeight = prefermentWater
            formula.preferments.append(levain)
        }

        for inclusion in inclusions {
            formula.finalMix.inclusions.append(
                Inclusion(name: inclusion.name, weight: inclusion.weight)
            )
        }

        return formula
    }
}
