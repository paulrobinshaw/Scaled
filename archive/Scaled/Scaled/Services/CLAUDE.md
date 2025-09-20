# Services Directory

This directory contains all business logic, data operations, and external integrations.

## SLC Principle: Simple, Lovable, Complete

Following our SLC approach (NOT MVP), services should be:
- **Simple**: Clear APIs with intuitive method names and parameters
- **Lovable**: Reliable, fast, with excellent error handling and recovery
- **Complete**: Full functionality including caching, retry logic, offline support where appropriate

No shortcuts or "temporary" solutions - build services that are production-ready from day one.

## Purpose

Services handle:
- Business logic and rules
- API/network communications
- Data persistence
- Complex calculations
- External system integrations
- Coordination between models

## Architecture Pattern

Services transform data and apply baker's math while keeping view/UI state elsewhere:

```swift
struct FormulaValidationService {
    let thresholds: ValidationThresholds

    func analyze(_ formula: Formula) -> FormulaAnalysis {
        var warnings: [ValidationWarning] = []

        if formula.overallHydration > thresholds.maxHydration {
            warnings.append(.init(level: .warning,
                                  category: "Hydration",
                                  message: "Hydration is very high",
                                  value: formula.overallHydration))
        }

        if formula.saltPercentage < thresholds.minSaltPercentage {
            warnings.append(.init(level: .info,
                                  category: "Salt",
                                  message: "Salt is lower than typical artisan ranges",
                                  value: formula.saltPercentage))
        }

        return FormulaAnalysis(
            totalFlour: formula.totalFlour,
            totalWater: formula.totalWater,
            totalWeight: formula.totalWeight,
            hydration: formula.overallHydration,
            saltPercentage: formula.saltPercentage,
            prefermentedFlourPercentage: formula.prefermentedFlourPercentage,
            warnings: warnings
        )
    }
}

struct ValidationThresholds {
    let maxHydration: Double
    let minSaltPercentage: Double
}
```

## Guidelines

### DO:
- Use protocol-oriented design for testability
- Implement proper error handling
- Use async/await for asynchronous operations when touching the network or disk
- Keep services focused on a single domain (parsing, calculation, scaling, persistence)
- Inject collaborators so domain logic is easy to mock
- Return value types or lightweight DTOs that views/models can consume
- Cache expensive calculations or I/O results where it improves UX

### DON'T:
- Create "Manager" classes that do everything
- Mix concerns (separate parsing, calculation, scaling, and persistence layers)
- Ignore thread safety for shared resources
- Return raw network responses (normalize into project models)
- Mark services as `ObservableObject` or store UI state inside services
- Create circular dependencies

## Service Types

Common Scaled service categories:

### Parsing Service
```swift
protocol RecipeParsing {
    func normalize(raw: [RawIngredient]) -> ParsedRecipe
}
```

### Calculation Service
```swift
protocol FormulaCalculating {
    func bakersPercentages(for formula: Formula) -> BakersPercentageTable
    func hydration(for formula: Formula) -> Double
}
```

### Scaling Service
```swift
protocol FormulaScaling {
    func scale(formula: Formula, toTargetWeight grams: Double) -> Formula
    func scale(formula: Formula, usingPreferment id: UUID, availableWeight grams: Double) -> Formula
}
```

### Persistence / Sync Service
```swift
protocol FormulaStore {
    func save(_ formula: Formula) throws
    func load(id: UUID) throws -> Formula?
    func delete(id: UUID) throws
}
```

## Organization

```
Services/
├── Parsing/
│   ├── RecipeParser.swift          # Convert RawIngredients into normalized data
│   └── FormulaBuilder.swift        # Map parsed data into Formula structures
├── Calculation/
│   ├── FormulaCalculationService.swift
│   └── FormulaValidationService.swift
├── Scaling/
│   └── FormulaScalingService.swift
└── Persistence/
    └── FormulaStore.swift          # Future: local/cloud persistence for formulas
```

## Testing

Services should be thoroughly tested:
- Unit tests for business logic
- Mock external dependencies
- Test error handling paths
- Verify state changes
- Test async operations

```swift
final class FormulaValidationServiceTests: XCTestCase {
    private var thresholds: ValidationThresholds!
    private var service: FormulaValidationService!

    override func setUp() {
        thresholds = .init(maxHydration: 85, minSaltPercentage: 1.6)
        service = FormulaValidationService(thresholds: thresholds)
    }

    func testHydrationWarningWhenAboveThreshold() {
        let formula = Formula(name: "Test")
        formula.finalMix.water = 900
        formula.finalMix.flours.addFlour(type: .bread, weight: 1000)

        let analysis = service.analyze(formula)

        #expect(analysis.warnings.contains { $0.category == "Hydration" })
    }
}
```
