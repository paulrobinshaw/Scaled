# Utilities Directory

This directory contains helper functions, extensions, and reusable utilities.

## SLC Principle: Simple, Lovable, Complete

Following our SLC approach (NOT MVP), utilities should be:
- **Simple**: Easy to understand and use with clear naming
- **Lovable**: Well-tested, performant, and handles edge cases gracefully
- **Complete**: Comprehensive functionality - no "TODO: handle this case later"

Every utility should be production-ready and thoroughly tested. No placeholder implementations.

## Purpose

Utilities provide:
- Swift type extensions
- Helper functions
- Custom view modifiers
- Constants and configuration
- Reusable algorithms
- Formatting utilities

## Extension Guidelines

Organize extensions by the type they extend:

```swift
// Double+BakersMath.swift
extension Double {
    /// Formats baker's percentages with a trailing percent symbol.
    var bakersPercentageString: String {
        String(format: "%.1f%%", self)
    }

    /// Rounds gram weights according to a Formula's rounding precision.
    func rounded(to precision: RoundingPrecision) -> Double {
        let factor = pow(10, Double(precision.decimalPlaces))
        return (self * factor).rounded() / factor
    }
}

// Array+FlourType.swift
extension Array where Element == FlourItem {
    /// Total flour weight for the provided flour types.
    func totalWeight(of types: Set<FlourType>) -> Double {
        reduce(0) { total, item in
            types.contains(item.type) ? total + item.weight : total
        }
    }
}
```

## Custom View Modifiers

Create reusable styling and behavior modifiers:

```swift
// WarningBannerModifier.swift
struct ValidationBannerModifier: ViewModifier {
    let warnings: [ValidationWarning]

    func body(content: Content) -> some View {
        VStack(spacing: 12) {
            content

            if !warnings.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(warnings) { warning in
                        Label(warning.message, systemImage: warning.level == .error ? "exclamationmark.octagon" : "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(color(for: warning.level))
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func color(for level: WarningLevel) -> Color {
        switch level {
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

extension View {
    func validationBanner(_ warnings: [ValidationWarning]) -> some View {
        modifier(ValidationBannerModifier(warnings: warnings))
    }
}
```

## Constants and Configuration

```swift
// BakersMathConstants.swift
enum BakersMathConstants {
    static let defaultHydrationWarningRange: ClosedRange<Double> = 85...110
    static let typicalSaltPercentage: ClosedRange<Double> = 1.6...2.4
    static let prefermentedFlourUpperBound: Double = 40
}

// FormattingConstants.swift
enum FormattingConstants {
    static let gramsFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter
    }()
}
```

## Helper Functions

Keep helper functions pure and testable:

```swift
// BakersMath.swift
enum BakersMath {
    static func hydration(water: Double, flour: Double) -> Double {
        guard flour > 0 else { return 0 }
        return (water / flour) * 100
    }

    static func prefermentedFlourPercentage(prefermentedFlour: Double, totalFlour: Double) -> Double {
        guard totalFlour > 0 else { return 0 }
        return (prefermentedFlour / totalFlour) * 100
    }

    static func scaledWeight(original: Double, factor: Double, precision: RoundingPrecision) -> Double {
        (original * factor).rounded(to: precision)
    }
}
```

## Guidelines

### DO:
- Keep utilities pure (no side effects where possible)
- Group helpers by concept (baker's math, formatting, validation)
- Cover edge cases with tests (zero flour, extreme hydration, rounding)
- Provide doc comments describing bakery-specific rules
- Prefer deterministic number formatting helpers over ad-hoc `String(format:)`

### DON'T:
- Create "Utils" grab bags with unrelated helpers
- Duplicate functionality that belongs in services or models
- Make utilities depend on global mutable state or SwiftUI views
- Bury business rules in extensions without documentation

## Organization

```
Utilities/
├── Extensions/
│   ├── Double+BakersMath.swift
│   ├── Array+FlourType.swift
│   └── Date+BatchPlanning.swift
├── ViewModifiers/
│   ├── ValidationBannerModifier.swift
│   └── HydrationBadgeModifier.swift
├── Helpers/
│   ├── BakersMath.swift
│   ├── IngredientParsingHelpers.swift
│   └── Rounding.swift
└── Constants/
    └── BakersMathConstants.swift
```

## Testing

Test utilities thoroughly since they're used throughout the app:

```swift
final class BakersMathTests: XCTestCase {
    func testHydrationRoundsCorrectly() {
        let hydration = BakersMath.hydration(water: 780, flour: 1000)
        #expect(hydration == 78)
    }

    func testScaledWeightHonorsPrecision() {
        let scaled = BakersMath.scaledWeight(original: 123.456, factor: 2, precision: .tenthGram)
        #expect(scaled == 246.9)
    }
}
```

## Common Utilities to Include

- **Baker's Math Helpers**: Hydration, salt percentage, prefermented flour calculations
- **Formatting**: Gram rounding, percentage strings, preferment schedule copy
- **Parsing Helpers**: Unit conversions (cups → grams), regex helpers for ingredient lines
- **View Modifiers**: Hydration badges, validation banners, scaling prompts
- **Batch Planning**: Timeline utilities for preferment start/end, production calendar dates
- **Testing Fixtures**: Factories for sample formulas/ingredients used across tests
