import Foundation

/// Service for validating formulas and generating warnings
class FormulaValidationService {

    // MARK: - Main Validation

    /// Validate a formula and return any warnings or errors
    func validate(formula: Formula) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []

        // Check for critical errors first
        warnings.append(contentsOf: validateCriticalRequirements(formula))

        // Only continue with other validations if no critical errors
        let hasErrors = warnings.contains { $0.level == .error }
        if !hasErrors {
            warnings.append(contentsOf: validateHydration(formula))
            warnings.append(contentsOf: validateSalt(formula))
            warnings.append(contentsOf: validatePrefermentedFlour(formula))
            warnings.append(contentsOf: validateYeast(formula))
            warnings.append(contentsOf: validatePreferments(formula))
            warnings.append(contentsOf: validateSoakers(formula))
            warnings.append(contentsOf: validateProportions(formula))
        }

        return warnings
    }

    // MARK: - Critical Requirements

    private func validateCriticalRequirements(_ formula: Formula) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []

        // Must have flour
        if formula.totalFlour == 0 {
            warnings.append(ValidationWarning(
                level: .error,
                category: "Flour",
                message: "Formula must contain flour",
                value: 0
            ))
        }

        // Must have water
        if formula.totalWater == 0 {
            warnings.append(ValidationWarning(
                level: .error,
                category: "Water",
                message: "Formula must contain water",
                value: 0
            ))
        }

        // Must have either yeast or sourdough starter
        let hasYeast = (formula.finalMix.yeast ?? 0) > 0 ||
            formula.preferments.contains { ($0.yeast ?? 0) > 0 }
        let hasStarter = formula.preferments.contains { $0.starter != nil }

        if !hasYeast && !hasStarter {
            warnings.append(ValidationWarning(
                level: .warning,
                category: "Leavening",
                message: "No yeast or sourdough starter detected",
                value: nil
            ))
        }

        return warnings
    }

    // MARK: - Hydration Validation

    private func validateHydration(_ formula: Formula) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []
        let hydration = formula.overallHydration

        switch hydration {
        case 0..<45:
            warnings.append(ValidationWarning(
                level: .error,
                category: "Hydration",
                message: "Extremely low hydration - check water amounts",
                value: hydration
            ))

        case 45..<55:
            warnings.append(ValidationWarning(
                level: .warning,
                category: "Hydration",
                message: "Very dry dough (bagel/pretzel range)",
                value: hydration
            ))

        case 55..<60:
            warnings.append(ValidationWarning(
                level: .info,
                category: "Hydration",
                message: "Low hydration (stiff dough)",
                value: hydration
            ))

        case 85..<95:
            warnings.append(ValidationWarning(
                level: .warning,
                category: "Hydration",
                message: "High hydration (very wet dough)",
                value: hydration
            ))

        case 95..<110:
            warnings.append(ValidationWarning(
                level: .warning,
                category: "Hydration",
                message: "Very high hydration (ciabatta range)",
                value: hydration
            ))

        case 110...:
            warnings.append(ValidationWarning(
                level: .error,
                category: "Hydration",
                message: "Extremely high hydration - check calculations",
                value: hydration
            ))

        default:
            // Normal range 60-85%
            break
        }

        return warnings
    }

    // MARK: - Salt Validation

    private func validateSalt(_ formula: Formula) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []
        let saltPercentage = formula.saltPercentage

        switch saltPercentage {
        case 0:
            warnings.append(ValidationWarning(
                level: .error,
                category: "Salt",
                message: "No salt in formula",
                value: 0
            ))

        case 0..<1.0:
            warnings.append(ValidationWarning(
                level: .warning,
                category: "Salt",
                message: "Very low salt (may affect flavor and fermentation)",
                value: saltPercentage
            ))

        case 1.0..<1.5:
            warnings.append(ValidationWarning(
                level: .info,
                category: "Salt",
                message: "Low salt content",
                value: saltPercentage
            ))

        case 3.0..<3.5:
            warnings.append(ValidationWarning(
                level: .info,
                category: "Salt",
                message: "High salt content",
                value: saltPercentage
            ))

        case 3.5...:
            warnings.append(ValidationWarning(
                level: .warning,
                category: "Salt",
                message: "Very high salt (may inhibit fermentation)",
                value: saltPercentage
            ))

        default:
            // Normal range 1.5-3.0%
            break
        }

        return warnings
    }

    // MARK: - Prefermented Flour Validation

    private func validatePrefermentedFlour(_ formula: Formula) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []
        let prefFlourPercentage = formula.prefermentedFlourPercentage

        switch prefFlourPercentage {
        case 40..<50:
            warnings.append(ValidationWarning(
                level: .info,
                category: "Preferment",
                message: "High prefermented flour percentage",
                value: prefFlourPercentage
            ))

        case 50...:
            warnings.append(ValidationWarning(
                level: .warning,
                category: "Preferment",
                message: "Very high prefermented flour (may overferment)",
                value: prefFlourPercentage
            ))

        default:
            // Normal range 0-40%
            break
        }

        return warnings
    }

    // MARK: - Yeast Validation

    private func validateYeast(_ formula: Formula) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []

        // Calculate total yeast percentage
        let totalYeast = (formula.finalMix.yeast ?? 0) +
            formula.preferments.reduce(0) { $0 + ($1.yeast ?? 0) }

        guard formula.totalFlour > 0 else { return warnings }
        let yeastPercentage = (totalYeast / formula.totalFlour) * 100

        switch yeastPercentage {
        case 3.0...:
            warnings.append(ValidationWarning(
                level: .warning,
                category: "Yeast",
                message: "High yeast content (may ferment too quickly)",
                value: yeastPercentage
            ))

        case 0.1..<0.5 where formula.preferments.isEmpty:
            warnings.append(ValidationWarning(
                level: .info,
                category: "Yeast",
                message: "Low yeast content (long fermentation expected)",
                value: yeastPercentage
            ))

        default:
            break
        }

        return warnings
    }

    // MARK: - Preferment Validation

    private func validatePreferments(_ formula: Formula) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []

        for preferment in formula.preferments {
            // Check preferment hydration
            let hydration = preferment.hydration

            switch preferment.type {
            case .poolish:
                if abs(hydration - 100) > 5 {
                    warnings.append(ValidationWarning(
                        level: .info,
                        category: "Preferment",
                        message: "\(preferment.name): Poolish typically has 100% hydration",
                        value: hydration
                    ))
                }

            case .biga:
                if hydration < 45 || hydration > 65 {
                    warnings.append(ValidationWarning(
                        level: .info,
                        category: "Preferment",
                        message: "\(preferment.name): Biga typically has 45-65% hydration",
                        value: hydration
                    ))
                }

            default:
                break
            }

            // Check build time
            if preferment.buildHours < 4 {
                warnings.append(ValidationWarning(
                    level: .warning,
                    category: "Timing",
                    message: "\(preferment.name): Very short fermentation time",
                    value: preferment.buildHours
                ))
            } else if preferment.buildHours > 24 {
                warnings.append(ValidationWarning(
                    level: .info,
                    category: "Timing",
                    message: "\(preferment.name): Long fermentation time",
                    value: preferment.buildHours
                ))
            }
        }

        return warnings
    }

    // MARK: - Soaker Validation

    private func validateSoakers(_ formula: Formula) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []

        for soaker in formula.soakers {
            // Check soaker hydration
            let hydration = soaker.hydration

            if hydration < 50 {
                warnings.append(ValidationWarning(
                    level: .warning,
                    category: "Soaker",
                    message: "\(soaker.name): Low hydration may not fully soften grains",
                    value: hydration
                ))
            } else if hydration > 200 {
                warnings.append(ValidationWarning(
                    level: .info,
                    category: "Soaker",
                    message: "\(soaker.name): High hydration",
                    value: hydration
                ))
            }

            // Check soak time
            if soaker.soakHours < 2 && !soaker.boilingWater {
                warnings.append(ValidationWarning(
                    level: .warning,
                    category: "Timing",
                    message: "\(soaker.name): Short soak time without boiling water",
                    value: soaker.soakHours
                ))
            }
        }

        return warnings
    }

    // MARK: - Proportion Validation

    private func validateProportions(_ formula: Formula) -> [ValidationWarning] {
        var warnings: [ValidationWarning] = []

        // Check inclusion percentages
        let inclusionWeight = formula.finalMix.inclusions.reduce(0) { $0 + $1.weight }
        if formula.totalFlour > 0 {
            let inclusionPercentage = (inclusionWeight / formula.totalFlour) * 100

            if inclusionPercentage > 30 {
                warnings.append(ValidationWarning(
                    level: .warning,
                    category: "Inclusions",
                    message: "High inclusion percentage may affect dough structure",
                    value: inclusionPercentage
                ))
            }
        }

        // Check enrichment percentages
        let enrichmentWeight = formula.finalMix.enrichments.reduce(0) { $0 + $1.weight }
        if formula.totalFlour > 0 {
            let enrichmentPercentage = (enrichmentWeight / formula.totalFlour) * 100

            if enrichmentPercentage > 20 {
                warnings.append(ValidationWarning(
                    level: .info,
                    category: "Enrichments",
                    message: "Enriched dough detected",
                    value: enrichmentPercentage
                ))
            }
        }

        // Check whole grain percentage
        let wholeGrainFlours: [FlourType] = [.wholeWheat, .rye, .spelt, .einkorn, .kamut]
        let wholeGrainWeight = formula.finalMix.flours.items
            .filter { wholeGrainFlours.contains($0.type) }
            .reduce(0) { $0 + $1.weight }

        if formula.totalFlour > 0 {
            let wholeGrainPercentage = (wholeGrainWeight / formula.totalFlour) * 100

            if wholeGrainPercentage > 50 {
                warnings.append(ValidationWarning(
                    level: .info,
                    category: "Flour",
                    message: "High whole grain content",
                    value: wholeGrainPercentage
                ))
            }
        }

        return warnings
    }

    // MARK: - Helper Methods

    /// Get validation summary
    func getValidationSummary(for warnings: [ValidationWarning]) -> ValidationSummary {
        let errors = warnings.filter { $0.level == .error }
        let warningCount = warnings.filter { $0.level == .warning }.count
        let infoCount = warnings.filter { $0.level == .info }.count

        return ValidationSummary(
            hasErrors: !errors.isEmpty,
            errorCount: errors.count,
            warningCount: warningCount,
            infoCount: infoCount,
            isValid: errors.isEmpty
        )
    }
}

// MARK: - Supporting Types

/// Summary of validation results
struct ValidationSummary {
    let hasErrors: Bool
    let errorCount: Int
    let warningCount: Int
    let infoCount: Int
    let isValid: Bool

    var totalIssues: Int {
        errorCount + warningCount + infoCount
    }

    var statusMessage: String {
        if hasErrors {
            return "❌ Formula has \(errorCount) error(s)"
        } else if warningCount > 0 {
            return "⚠️ Formula has \(warningCount) warning(s)"
        } else if infoCount > 0 {
            return "ℹ️ Formula validated with \(infoCount) note(s)"
        } else {
            return "✅ Formula validated successfully"
        }
    }
}