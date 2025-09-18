import Foundation

/// Service for scaling formulas by various methods
class FormulaScalingService {

    // MARK: - Scale by Yield

    /// Scale formula to produce desired number of pieces at specified weight
    func scaleByYield(formula: Formula, pieces: Int, weightPerPiece: Double) -> Formula {
        let targetWeight = Double(pieces) * weightPerPiece
        let currentWeight = formula.totalWeight

        guard currentWeight > 0 else { return formula }

        let scaleFactor = targetWeight / currentWeight
        return applyScaleFactor(to: formula, factor: scaleFactor, newYield: FormulaYield(pieces: pieces, weightPerPiece: weightPerPiece))
    }

    // MARK: - Scale by Available Flour

    /// Scale formula based on available flour amount
    func scaleByAvailableFlour(formula: Formula, availableFlour: Double) -> Formula {
        let currentFlour = formula.totalFlour

        guard currentFlour > 0 else { return formula }

        let scaleFactor = availableFlour / currentFlour

        // Calculate new yield based on scaling
        let newTotalWeight = formula.totalWeight * scaleFactor
        let pieces = formula.yield.pieces
        let newWeightPerPiece = newTotalWeight / Double(pieces)

        return applyScaleFactor(
            to: formula,
            factor: scaleFactor,
            newYield: FormulaYield(pieces: pieces, weightPerPiece: newWeightPerPiece)
        )
    }

    // MARK: - Scale by Available Preferment

    /// Scale formula based on available preferment weight
    func scaleByAvailablePreferment(formula: Formula, prefermentId: UUID, availableWeight: Double) -> Formula {
        guard let preferment = formula.preferments.first(where: { $0.id == prefermentId }) else {
            return formula
        }

        let currentWeight = preferment.totalWeight
        guard currentWeight > 0 else { return formula }

        let scaleFactor = availableWeight / currentWeight

        // Calculate new yield
        let newTotalWeight = formula.totalWeight * scaleFactor
        let pieces = formula.yield.pieces
        let newWeightPerPiece = newTotalWeight / Double(pieces)

        return applyScaleFactor(
            to: formula,
            factor: scaleFactor,
            newYield: FormulaYield(pieces: pieces, weightPerPiece: newWeightPerPiece)
        )
    }

    // MARK: - Scale by Mixer Capacity

    /// Scale formula to fit mixer capacity (in kg)
    func scaleToMixerCapacity(formula: Formula, mixerCapacityKg: Double) -> Formula {
        let mixerCapacityG = mixerCapacityKg * 1000
        let currentWeight = formula.totalWeight

        guard currentWeight > 0 else { return formula }

        // Scale down if formula exceeds mixer capacity
        if currentWeight > mixerCapacityG {
            let scaleFactor = mixerCapacityG / currentWeight
            let newPieces = Int(Double(formula.yield.pieces) * scaleFactor)
            return scaleByYield(formula: formula, pieces: max(1, newPieces), weightPerPiece: formula.yield.weightPerPiece)
        }

        return formula
    }

    // MARK: - Batch Production

    /// Create batch production card for multiple batches
    func createBatchProduction(formula: Formula, numberOfBatches: Int) -> BatchProductionCard {
        var batchFormula = formula

        // Scale up for total production
        let totalPieces = formula.yield.pieces * numberOfBatches
        batchFormula = scaleByYield(
            formula: formula,
            pieces: totalPieces,
            weightPerPiece: formula.yield.weightPerPiece
        )

        // Create timeline
        let timeline = createProductionTimeline(for: batchFormula, batches: numberOfBatches)

        return BatchProductionCard(
            formula: batchFormula,
            batchCount: numberOfBatches,
            piecesPerBatch: formula.yield.pieces,
            weightPerPiece: formula.yield.weightPerPiece,
            timeline: timeline
        )
    }

    // MARK: - Mis-weigh Correction

    /// Correct formula when ingredients have been mis-weighed
    func correctMisweigh(formula: Formula, actualWeights: [UUID: Double]) -> MisweighCorrection {
        var correction = MisweighCorrection(original: formula)

        // Calculate what the corrected formula should be
        // This is a complex calculation that maintains baker's percentages
        // For now, return a simple adjustment suggestion

        for (ingredientId, actualWeight) in actualWeights {
            // Find the ingredient and calculate deviation
            // Add to correction suggestions
        }

        return correction
    }

    // MARK: - Private Methods

    /// Apply scale factor to all formula components
    private func applyScaleFactor(to formula: Formula, factor: Double, newYield: FormulaYield) -> Formula {
        let scaled = Formula(name: formula.name)
        scaled.recipeId = formula.recipeId
        scaled.version = formula.version + 1
        scaled.notes = formula.notes + "\nScaled by factor: \(String(format: "%.2f", factor))"
        scaled.yield = newYield

        // Scale preferments
        scaled.preferments = formula.preferments.map { preferment in
            let scaledPref = Preferment(name: preferment.name, type: preferment.type)
            scaledPref.flourWeight = preferment.flourWeight * factor
            scaledPref.waterWeight = preferment.waterWeight * factor

            if let starter = preferment.starter {
                scaledPref.starter = StarterComponent(
                    weight: starter.weight * factor,
                    hydration: starter.hydration  // Hydration stays the same
                )
            }

            if let yeast = preferment.yeast {
                scaledPref.yeast = yeast * factor
            }

            scaledPref.buildHours = preferment.buildHours
            scaledPref.temperature = preferment.temperature

            return scaledPref
        }

        // Scale soakers
        scaled.soakers = formula.soakers.map { soaker in
            let scaledSoaker = Soaker(name: soaker.name)
            scaledSoaker.grains = soaker.grains.map { grain in
                GrainItem(name: grain.name, weight: grain.weight * factor)
            }
            scaledSoaker.water = soaker.water * factor
            scaledSoaker.salt = soaker.salt.map { $0 * factor }
            scaledSoaker.soakHours = soaker.soakHours
            scaledSoaker.temperature = soaker.temperature
            scaledSoaker.boilingWater = soaker.boilingWater

            return scaledSoaker
        }

        // Scale final mix
        let scaledFinalMix = FinalMix()

        // Scale flours
        scaledFinalMix.flours.items = formula.finalMix.flours.items.map { item in
            FlourItem(type: item.type, weight: item.weight * factor)
        }

        scaledFinalMix.water = formula.finalMix.water * factor
        scaledFinalMix.salt = formula.finalMix.salt * factor
        scaledFinalMix.yeast = formula.finalMix.yeast.map { $0 * factor }

        // Scale inclusions
        scaledFinalMix.inclusions = formula.finalMix.inclusions.map { inclusion in
            Inclusion(
                name: inclusion.name,
                weight: inclusion.weight * factor,
                additionStage: inclusion.additionStage
            )
        }

        // Scale enrichments
        scaledFinalMix.enrichments = formula.finalMix.enrichments.map { enrichment in
            Enrichment(
                name: enrichment.name,
                weight: enrichment.weight * factor,
                type: enrichment.type
            )
        }

        scaledFinalMix.mixMethod = formula.finalMix.mixMethod
        scaledFinalMix.targetTemperature = formula.finalMix.targetTemperature

        scaled.finalMix = scaledFinalMix

        // Copy display preferences
        scaled.displayMode = formula.displayMode
        scaled.roundingPrecision = formula.roundingPrecision

        return scaled
    }

    /// Create production timeline
    private func createProductionTimeline(for formula: Formula, batches: Int) -> ProductionTimeline {
        var timeline = ProductionTimeline()

        // Calculate timing based on preferments
        if let longestPreferment = formula.preferments.max(by: { $0.buildHours < $1.buildHours }) {
            timeline.prefermentStart = -longestPreferment.buildHours
        }

        // Add mix time estimates
        timeline.mixingDuration = 0.25 * Double(batches)  // 15 min per batch
        timeline.bulkFermentation = 3.0  // Standard 3 hours
        timeline.divideAndShape = 0.5
        timeline.finalProof = 1.5
        timeline.baking = 0.75

        timeline.totalTime = abs(timeline.prefermentStart) +
            timeline.mixingDuration +
            timeline.bulkFermentation +
            timeline.divideAndShape +
            timeline.finalProof +
            timeline.baking

        return timeline
    }
}

// MARK: - Supporting Types

/// Batch production information
struct BatchProductionCard {
    let formula: Formula
    let batchCount: Int
    let piecesPerBatch: Int
    let weightPerPiece: Double
    let timeline: ProductionTimeline

    var totalPieces: Int {
        piecesPerBatch * batchCount
    }

    var totalWeight: Double {
        Double(totalPieces) * weightPerPiece
    }

    var batchWeight: Double {
        Double(piecesPerBatch) * weightPerPiece
    }
}

/// Production timeline in hours
struct ProductionTimeline {
    var prefermentStart: Double = 0  // Negative hours before mixing
    var mixingDuration: Double = 0
    var bulkFermentation: Double = 0
    var divideAndShape: Double = 0
    var finalProof: Double = 0
    var baking: Double = 0
    var totalTime: Double = 0
}

/// Mis-weigh correction information
struct MisweighCorrection {
    let original: Formula
    var suggestions: [CorrectionSuggestion] = []
    var canCorrect: Bool = true
    var notes: String = ""
}

/// Suggestion for correcting a mis-weighed ingredient
struct CorrectionSuggestion {
    let ingredient: String
    let targetWeight: Double
    let actualWeight: Double
    let adjustment: Double
    let adjustmentPercentage: Double
}