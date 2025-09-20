# Models Directory

This directory contains all data models and domain objects for the application.

## SLC Principle: Simple, Lovable, Complete

Following our SLC approach (NOT MVP), models should be:
- **Simple**: Clean, understandable data structures
- **Lovable**: Well-designed with thoughtful property names and relationships
- **Complete**: Fully implemented with all necessary properties - no "we'll add it later"

## Purpose

Models represent the core data structures of your application. They should be:
- Simple and focused on data representation
- Observable when UI needs to react to changes
- Free from business logic (that belongs in Services)

## SwiftUI Integration

Use the `@Observable` macro (Swift 5.9+) for models that need UI observation:

```swift
import Observation

@Observable
final class Formula {
    var id: UUID = UUID()
    var name: String = ""
    var preferments: [Preferment] = []
    var soakers: [Soaker] = []
    var finalMix = FinalMix()

    var overallHydration: Double {
        guard totalFlour > 0 else { return 0 }
        return (totalWater / totalFlour) * 100
    }

    var totalFlour: Double {
        finalMix.flours.totalWeight + preferments.reduce(0) { $0 + $1.flourWeight }
    }

    var totalWater: Double {
        finalMix.water + preferments.reduce(0) { $0 + $1.waterWeight } + soakers.reduce(0) { $0 + $1.water }
    }
}
```

## Guidelines

### DO:
- Use value types (struct) for immutable ingredients and components (`FlourItem`, `GrainItem`)
- Use `@Observable` reference types when multiple views mutate the same formula/recipe object
- Keep models focused on data + derived baker's math (computed properties for hydration, salt %, prefermented flour)
- Conform to `Codable` (and restore identifiers during decoding)
- Document invariants (e.g., prefermented flour contributes to total flour, soaker grains do not)

### DON'T:
- Embed service logic (parsing, validation, scaling) inside models
- Make network or persistence calls from models
- Include view-specific formatting (e.g., `String(format:)` for hydration labels)
- Let one model balloon with unrelated concerns—split into Recipe, Formula, Preferment, etc.

## Example Structure

As your app grows, organize models by feature:

```
Models/
├── Recipe/
│   ├── Recipe.swift              # Raw user input
│   ├── RawIngredient.swift       # Unparsed ingredient lines
│   └── RecipeSource.swift
├── Formula/
│   ├── Formula.swift
│   ├── Preferment.swift
│   ├── Soaker.swift
│   └── FinalMix.swift
└── Shared/
    ├── BakersPercentages.swift   # DTOs for calculations
    └── Validation.swift          # ValidationWarning, FormulaAnalysis
```

## Testing

Every model should have corresponding unit tests that verify:
- Initialization with default values
- Codable encoding/decoding
- Computed properties (hydration, salt, prefermented flour)
- Validation helpers / invariants (e.g., prefermented flour never exceeds total flour)
