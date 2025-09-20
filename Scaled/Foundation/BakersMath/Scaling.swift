import Foundation

public func scaleByYield(formula: Formula, targetPieces: Int, weightPerPiece: Double) -> Formula {
    let targetWeight = Double(max(1, targetPieces)) * max(0, weightPerPiece)
    let currentWeight = totalWeight(of: formula)
    guard currentWeight.isSignificant else { return formula }

    let factor = targetWeight / currentWeight
    var scaled = applyScaleFactor(formula, factor: factor)
    scaled.yield = FormulaYield(pieces: max(1, targetPieces), weightPerPiece: max(0, weightPerPiece))
    scaled.version += 1
    scaled.lastModified = .now
    return scaled
}

public func scaleByIngredient(
    formula: Formula,
    ingredient identifier: IngredientIdentifier,
    targetWeight: Double
) -> Formula {
    let currentWeight = weight(of: identifier, in: formula)
    guard currentWeight.isSignificant else { return formula }

    let factor = max(0, targetWeight) / currentWeight
    var scaled = applyScaleFactor(formula, factor: factor)
    let newTotal = totalWeight(of: scaled)
    let pieces = scaled.yield.pieces
    scaled.yield = FormulaYield(pieces: pieces, weightPerPiece: newTotal / Double(pieces))
    scaled.version += 1
    scaled.lastModified = .now
    return scaled
}

public struct MisweighCorrectionResult: Hashable {
    public let correctedFormula: Formula
    public let appliedFactor: Double
    public let reference: MisweighReference
}

public struct MisweighReference: Hashable {
    public let ingredient: IngredientIdentifier
    public let expectedWeight: Double
    public let actualWeight: Double
    public var delta: Double { actualWeight - expectedWeight }
}

public func correctMisweigh(
    formula: Formula,
    measuredWeights: [IngredientIdentifier: Double]
) -> MisweighCorrectionResult {
    guard let (identifier, actual) = measuredWeights.first else {
        return MisweighCorrectionResult(
            correctedFormula: formula,
            appliedFactor: 1,
            reference: MisweighReference(
                ingredient: .finalWater,
                expectedWeight: 0,
                actualWeight: 0
            )
        )
    }

    let expected = weight(of: identifier, in: formula)
    guard expected.isSignificant else {
        return MisweighCorrectionResult(
            correctedFormula: formula,
            appliedFactor: 1,
            reference: MisweighReference(
                ingredient: identifier,
                expectedWeight: expected,
                actualWeight: actual
            )
        )
    }

    let factor = max(0, actual) / expected
    var corrected = applyScaleFactor(formula, factor: factor)
    let pieces = corrected.yield.pieces
    let newWeightPerPiece = totalWeight(of: corrected) / Double(pieces)
    corrected.yield = FormulaYield(pieces: pieces, weightPerPiece: newWeightPerPiece)
    corrected.version += 1
    corrected.lastModified = .now

    let reference = MisweighReference(
        ingredient: identifier,
        expectedWeight: expected,
        actualWeight: actual
    )

    return MisweighCorrectionResult(
        correctedFormula: corrected,
        appliedFactor: factor,
        reference: reference
    )
}

private func applyScaleFactor(_ formula: Formula, factor: Double) -> Formula {
    guard factor.isSignificant else { return formula }

    var scaled = formula
    scaled.finalMix = scaleFinalMix(formula.finalMix, by: factor)
    scaled.preferments = formula.preferments.map { scalePreferment($0, by: factor) }
    scaled.soakers = formula.soakers.map { scaleSoaker($0, by: factor) }
    scaled.lastModified = .now
    return scaled
}

private func scaleFinalMix(_ finalMix: FinalMix, by factor: Double) -> FinalMix {
    var scaled = finalMix
    scaled.flours = finalMix.flours.map { flour in
        Flour(id: flour.id, type: flour.type, weight: flour.weight * factor)
    }
    scaled.water *= factor
    scaled.salt *= factor
    scaled.yeast = finalMix.yeast.map { $0 * factor }
    scaled.inclusions = finalMix.inclusions.map { inclusion in
        Inclusion(
            id: inclusion.id,
            name: inclusion.name,
            weight: inclusion.weight * factor,
            additionStage: inclusion.additionStage
        )
    }
    scaled.enrichments = finalMix.enrichments.map { enrichment in
        Enrichment(
            id: enrichment.id,
            name: enrichment.name,
            weight: enrichment.weight * factor,
            kind: enrichment.kind
        )
    }
    return scaled
}

private func scalePreferment(_ preferment: Preferment, by factor: Double) -> Preferment {
    var scaled = preferment
    scaled.flourWeight *= factor
    scaled.waterWeight *= factor
    scaled.starter = preferment.starter.map { starter in
        Preferment.Starter(weight: starter.weight * factor, hydration: starter.hydration)
    }
    scaled.yeast = preferment.yeast.map { $0 * factor }
    return scaled
}

private func scaleSoaker(_ soaker: Soaker, by factor: Double) -> Soaker {
    var scaled = soaker
    scaled.grains = soaker.grains.map { grain in
        Soaker.Grain(id: grain.id, name: grain.name, weight: grain.weight * factor)
    }
    scaled.water *= factor
    scaled.salt = soaker.salt.map { $0 * factor }
    return scaled
}

private func weight(of identifier: IngredientIdentifier, in formula: Formula) -> Double {
    switch identifier {
    case .finalFlour(let id):
        return formula.finalMix.flours.first(where: { $0.id == id })?.weight ?? 0
    case .finalWater:
        return formula.finalMix.water
    case .finalSalt:
        return formula.finalMix.salt
    case .finalYeast:
        return formula.finalMix.yeast ?? 0
    case .preferment(let id):
        return formula.preferments.first(where: { $0.id == id })?.totalWeight ?? 0
    case .prefermentFlour(let id):
        return formula.preferments.first(where: { $0.id == id })?.flourWeight ?? 0
    case .prefermentWater(let id):
        return formula.preferments.first(where: { $0.id == id })?.waterWeight ?? 0
    case .soaker(let id):
        return formula.soakers.first(where: { $0.id == id })?.totalWeight ?? 0
    case .inclusion(let id):
        return formula.finalMix.inclusions.first(where: { $0.id == id })?.weight ?? 0
    case .enrichment(let id):
        return formula.finalMix.enrichments.first(where: { $0.id == id })?.weight ?? 0
    }
}
