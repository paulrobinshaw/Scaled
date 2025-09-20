import Foundation

public func totalFlour(in formula: Formula) -> Double {
    let finalMixFlour = formula.finalMix.flours.reduce(into: 0) { $0 += $1.weight }
    let prefermentFlour = formula.preferments.reduce(into: 0) { partialResult, preferment in
        partialResult += preferment.flourWeight + (preferment.starter?.flourContribution ?? 0)
    }
    return finalMixFlour + prefermentFlour
}

public func totalWater(in formula: Formula) -> Double {
    let finalMixWater = formula.finalMix.water
    let prefermentWater = formula.preferments.reduce(into: 0) { partialResult, preferment in
        partialResult += preferment.waterWeight + (preferment.starter?.waterContribution ?? 0)
    }
    let soakerWater = formula.soakers.reduce(into: 0) { $0 += $1.water }
    return finalMixWater + prefermentWater + soakerWater
}

public func totalSalt(in formula: Formula) -> Double {
    let finalMixSalt = formula.finalMix.salt
    let soakerSalt = formula.soakers.reduce(into: 0) { $0 += $1.salt ?? 0 }
    return finalMixSalt + soakerSalt
}

public func totalWeight(of formula: Formula) -> Double {
    let finalMixWeight = formula.finalMix.flours.reduce(0) { $0 + $1.weight } +
        formula.finalMix.water +
        formula.finalMix.salt +
        (formula.finalMix.yeast ?? 0) +
        formula.finalMix.inclusions.reduce(0) { $0 + $1.weight } +
        formula.finalMix.enrichments.reduce(0) { $0 + $1.weight }

    let prefermentWeight = formula.preferments.reduce(0) { $0 + $1.totalWeight }
    let soakerWeight = formula.soakers.reduce(0) { $0 + $1.totalWeight }

    return finalMixWeight + prefermentWeight + soakerWeight
}

public func hydration(for formula: Formula) -> Double {
    let flour = totalFlour(in: formula)
    guard flour.isSignificant else { return 0 }
    return (totalWater(in: formula) / flour) * 100
}

public func saltPercentage(for formula: Formula) -> Double {
    let flour = totalFlour(in: formula)
    guard flour.isSignificant else { return 0 }
    return (totalSalt(in: formula) / flour) * 100
}

public func preFermentedFlour(in formula: Formula) -> Double {
    let flour = totalFlour(in: formula)
    guard flour.isSignificant else { return 0 }
    let prefermentFlour = formula.preferments.reduce(into: 0) { partialResult, preferment in
        partialResult += preferment.flourWeight + (preferment.starter?.flourContribution ?? 0)
    }
    return (prefermentFlour / flour) * 100
}

