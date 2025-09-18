# Scaled - Comprehensive Calculation Logic Documentation

## Overview

This document defines the detailed calculation logic for scaling bread recipes with complex preferment structures. It incorporates professional baking software insights (e.g., BreadStorm) and extends them to handle multiple flours, parallel and serial preferments (e.g., Detmolder method), and advanced scaling scenarios.

---

## Notation and Terminology

- **Ingredient**: Any component of the recipe (flour, water, salt, preferment, yeast, etc.).
- **Flour**: All flour types combined (bread flour, whole wheat, rye, etc.).
- **Preferment**: A pre-mixed ingredient containing flour, water, and possibly starter or yeast. Types include:
  - **Yeasted Preferment** (e.g., Poolish, Biga)
  - **Sourdough Preferment** (e.g., Levain)
  - **Soaker** (hydrated grains/seeds)
- **Final Mix**: Ingredients combined after preferment(s) are ready.
- **Baker's Percentage**: Percentage of each ingredient relative to total flour weight.
- **Hydration**: Total water weight divided by total flour weight.
- **Pre-fermented Flour %**: Percentage of total flour contained in preferments.
- **Serial Preferments**: Preferments built sequentially (one fed by the previous).
- **Parallel Preferments**: Multiple preferments prepared independently and combined.

---

## Core Principles

1. **Everything is an Ingredient**  
   Preferments are treated as ingredients but their internal flour and water components are tracked separately to calculate accurate baker's percentages and hydration.

2. **Total Flour Includes All Flour**  
   Total flour = flour in final mix + flour in all preferments (including serial and parallel).

3. **Hydration Includes All Water**  
   Total water = water in final mix + water in all preferments + water in soakers.

4. **Scaling Must Respect Preferment Composition**  
   When scaling by total yield, available flour, or preferment quantity, internal preferment flour and water must be accounted for to maintain recipe balance.

5. **Rounding**  
   No rounding during calculations; round only at final display.

6. **Validation**  
   Warnings and errors are issued based on hydration, salt %, prefermented flour %, and consistency checks.

---

## Data Structures

```swift
enum PrefermentType {
    case yeasted
    case sourdough
    case soaker
    case none
}

struct Ingredient {
    let name: String
    let weight: Double
    let isFlour: Bool
    let isWater: Bool
    let isSalt: Bool
    let isPreferment: Bool
    let prefermentType: PrefermentType
    let flourContent: Double  // Flour weight inside ingredient (0 if none)
    let waterContent: Double  // Water weight inside ingredient (0 if none)
    let isForWash: Bool       // Separate from dough calculation (egg wash, toppings)
}

struct Preferment {
    let name: String
    let type: PrefermentType
    let ingredients: [Ingredient]
    
    var totalWeight: Double {
        ingredients.reduce(0) { $0 + $1.weight }
    }
    
    var totalFlour: Double {
        ingredients.reduce(0) { $0 + $1.flourContent }
    }
    
    var totalWater: Double {
        ingredients.reduce(0) { $0 + $1.waterContent }
    }
}

struct Recipe {
    let ingredients: [Ingredient]
    let preferments: [Preferment]  // Can be empty
    
    // Total flour including preferments
    var totalFlour: Double {
        let flourInIngredients = ingredients.filter { $0.isFlour }.map { $0.weight }.reduce(0, +)
        let flourInPreferments = preferments.map { $0.totalFlour }.reduce(0, +)
        return flourInIngredients + flourInPreferments
    }
    
    // Total water including preferments
    var totalWater: Double {
        let waterInIngredients = ingredients.filter { $0.isWater }.map { $0.weight }.reduce(0, +)
        let waterInPreferments = preferments.map { $0.totalWater }.reduce(0, +)
        return waterInIngredients + waterInPreferments
    }
    
    // Pre-fermented flour percentage
    var prefermentedFlourPercentage: Double {
        let flourInPreferments = preferments.map { $0.totalFlour }.reduce(0, +)
        guard totalFlour > 0 else { return 0 }
        return (flourInPreferments / totalFlour) * 100
    }
    
    // Overall hydration percentage
    var overallHydration: Double {
        guard totalFlour > 0 else { return 0 }
        return (totalWater / totalFlour) * 100
    }
    
    // Salt percentage relative to total flour
    var saltPercentage: Double {
        let saltWeight = ingredients.filter { $0.isSalt }.map { $0.weight }.reduce(0, +)
        guard totalFlour > 0 else { return 0 }
        return (saltWeight / totalFlour) * 100
    }
    
    // Baker's percentages for all ingredients including preferments broken down
    func bakersPercentages() -> [String: Double] {
        var percentages: [String: Double] = [:]
        
        // Ingredients in final mix (excluding preferments)
        for ing in ingredients where !ing.isPreferment && !ing.isForWash {
            percentages[ing.name] = (ing.weight / totalFlour) * 100
        }
        
        // Preferments as ingredients (total weight)
        for pref in preferments {
            percentages[pref.name] = (pref.totalWeight / totalFlour) * 100
            // Optionally, breakdown of preferment components can be added separately
        }
        
        return percentages
    }
}
```

---

## Calculation Steps

### 1. Parse Recipe and Preferments

- Identify all ingredients.
- Identify preferments and their internal ingredients.
- Mark preferments with type (yeasted, sourdough, soaker).

### 2. Calculate Totals

- Compute total flour = flour in final mix + flour in all preferments.
- Compute total water = water in final mix + water in all preferments.
- Compute salt and other key ingredients totals.

### 3. Calculate Baker's Percentages

- For each ingredient (including preferments as single ingredients), calculate baker's % = (weight / total flour) × 100.
- For preferments, optionally calculate internal baker's percentages for display.

### 4. Calculate Hydration and Prefermented Flour %

- Hydration % = (total water / total flour) × 100
- Prefermented flour % = (flour in preferments / total flour) × 100

### 5. Scaling Modes

- **Scale by Total Yield**:  
  New total dough weight = number of loaves × weight per loaf  
  Scale all ingredients and preferments proportionally to meet new total dough weight.

- **Scale by Available Flour**:  
  Given flour weight available, scale recipe so total flour = available flour.  
  Scale all other ingredients accordingly.

- **Scale by Available Preferment**:  
  Given preferment weight available, calculate preferment flour content.  
  Calculate total flour based on prefermented flour % and scale entire recipe accordingly.

### 6. Mis-weigh Correction

- If ingredient weights deviate from expected scaled weights, calculate correction factor and adjust accordingly to maintain baker's percentages.

### 7. Rounding

- Do not round during calculations.
- Round only at display stage (e.g., nearest gram or tenth of gram).

---

## Handling Multiple Flours

- Sum all flour types to get total flour.
- Display individual flour types with their baker's % relative to total flour.
- Preferment flour is included in total flour.

---

## Handling Multiple Preferments

- Support parallel preferments: multiple preferments prepared independently.
- Support serial preferments: preferments fed sequentially (e.g., Detmolder method).
- Track flour and water in each preferment separately.
- Calculate prefermented flour % as sum of all preferment flours / total flour.
- Display preferment breakdown columns.

---

## Final Mix Breakdown

- Final mix ingredients = total ingredients minus preferment ingredients.
- Final mix flour = total flour - sum of preferment flours.
- Final mix hydration = (water in final mix) / (final mix flour).
- Baker's percentages for final mix calculated relative to final mix flour.

---

## Validation Rules

| Rule                                    | Warning/Error                    |
|-----------------------------------------|---------------------------------|
| Hydration < 50%                         | Warning: Dough may be too dry    |
| Hydration > 85%                         | Warning: Dough may be too wet    |
| Prefermented flour > 40%                 | Warning: High prefermented flour |
| Salt < 1.5% or Salt > 3%                 | Warning: Salt outside optimal range |
| Baker's percentages sum mismatch         | Error: Calculation inconsistency |

---

## Worked Examples

### Example 1: Country Sourdough with Levain

- Ingredients:
  - Bread Flour: 800g
  - Water: 380g
  - Salt: 20g
  - Levain: 400g (contains 200g flour + 200g water)

- Calculations:
  - Total flour = 800 + 200 = 1000g
  - Total water = 380 + 200 = 580g
  - Hydration = (580 / 1000) × 100 = 58%
  - Prefermented flour % = (200 / 1000) × 100 = 20%
  - Salt % = (20 / 1000) × 100 = 2%

- Baker's %:
  - Bread Flour: 80%
  - Water: 38%
  - Salt: 2%
  - Levain: 40% (weight relative to total flour)

---

### Example 2: Multiple Flours and Parallel Preferments

- Ingredients:
  - Bread Flour: 750g
  - Whole Wheat Flour: 250g
  - Water: 740g
  - Salt: 20g
  - Levain (Preferment 1): 320g (contains 200g flour + 120g water)
  - Poolish (Preferment 2): 200g (contains 100g flour + 100g water)

- Calculations:
  - Total flour = 750 + 250 + 200 + 100 = 1300g
  - Total water = 740 + 120 + 100 = 960g
  - Hydration = (960 / 1300) × 100 ≈ 73.85%
  - Prefermented flour % = ((200 + 100) / 1300) × 100 ≈ 23.08%
  - Salt % = (20 / 1300) × 100 ≈ 1.54%

- Baker's %:
  - Bread Flour: 57.69%
  - Whole Wheat Flour: 19.23%
  - Water: 56.92%
  - Salt: 1.54%
  - Levain: 24.62%
  - Poolish: 15.38%

---

## Pseudocode for Scaling by Total Yield

```
function scaleRecipeByYield(recipe, numberOfLoaves, weightPerLoaf):
    totalDoughWeight = numberOfLoaves * weightPerLoaf
    currentTotalWeight = sum of all ingredient weights + sum of all preferment weights
    
    scaleFactor = totalDoughWeight / currentTotalWeight
    
    for each ingredient in recipe.ingredients:
        ingredient.weight *= scaleFactor
    
    for each preferment in recipe.preferments:
        for each ingredient in preferment.ingredients:
            ingredient.weight *= scaleFactor
    
    return scaled recipe
```

---

## Pseudocode for Calculating Baker's Percentages

```
function calculateBakersPercentages(recipe):
    totalFlour = sum of flour in ingredients + sum of flour in preferments
    
    percentages = {}
    
    for ingredient in recipe.ingredients:
        if not ingredient.isPreferment and not ingredient.isForWash:
            percentages[ingredient.name] = (ingredient.weight / totalFlour) * 100
    
    for preferment in recipe.preferments:
        percentages[preferment.name] = (preferment.totalWeight / totalFlour) * 100
    
    return percentages
```

---

## JSON Test Vectors

```json
[
  {
    "name": "Simple Country Sourdough",
    "ingredients": [
      {"name": "Bread Flour", "weight": 800, "isFlour": true, "isWater": false, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 800, "waterContent": 0, "isForWash": false},
      {"name": "Water", "weight": 380, "isFlour": false, "isWater": true, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 0, "waterContent": 380, "isForWash": false},
      {"name": "Salt", "weight": 20, "isFlour": false, "isWater": false, "isSalt": true, "isPreferment": false, "prefermentType": "none", "flourContent": 0, "waterContent": 0, "isForWash": false},
      {"name": "Levain", "weight": 400, "isFlour": false, "isWater": false, "isSalt": false, "isPreferment": true, "prefermentType": "sourdough", "flourContent": 200, "waterContent": 200, "isForWash": false}
    ],
    "preferments": [
      {
        "name": "Levain",
        "type": "sourdough",
        "ingredients": [
          {"name": "Flour", "weight": 200, "isFlour": true, "isWater": false, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 200, "waterContent": 0, "isForWash": false},
          {"name": "Water", "weight": 200, "isFlour": false, "isWater": true, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 0, "waterContent": 200, "isForWash": false}
        ]
      }
    ]
  },
  {
    "name": "Multi-Flour with Parallel Preferments",
    "ingredients": [
      {"name": "Bread Flour", "weight": 750, "isFlour": true, "isWater": false, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 750, "waterContent": 0, "isForWash": false},
      {"name": "Whole Wheat Flour", "weight": 250, "isFlour": true, "isWater": false, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 250, "waterContent": 0, "isForWash": false},
      {"name": "Water", "weight": 740, "isFlour": false, "isWater": true, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 0, "waterContent": 740, "isForWash": false},
      {"name": "Salt", "weight": 20, "isFlour": false, "isWater": false, "isSalt": true, "isPreferment": false, "prefermentType": "none", "flourContent": 0, "waterContent": 0, "isForWash": false},
      {"name": "Levain", "weight": 320, "isFlour": false, "isWater": false, "isSalt": false, "isPreferment": true, "prefermentType": "sourdough", "flourContent": 200, "waterContent": 120, "isForWash": false},
      {"name": "Poolish", "weight": 200, "isFlour": false, "isWater": false, "isSalt": false, "isPreferment": true, "prefermentType": "yeasted", "flourContent": 100, "waterContent": 100, "isForWash": false}
    ],
    "preferments": [
      {
        "name": "Levain",
        "type": "sourdough",
        "ingredients": [
          {"name": "Flour", "weight": 200, "isFlour": true, "isWater": false, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 200, "waterContent": 0, "isForWash": false},
          {"name": "Water", "weight": 120, "isFlour": false, "isWater": true, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 0, "waterContent": 120, "isForWash": false}
        ]
      },
      {
        "name": "Poolish",
        "type": "yeasted",
        "ingredients": [
          {"name": "Flour", "weight": 100, "isFlour": true, "isWater": false, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 100, "waterContent": 0, "isForWash": false},
          {"name": "Water", "weight": 100, "isFlour": false, "isWater": true, "isSalt": false, "isPreferment": false, "prefermentType": "none", "flourContent": 0, "waterContent": 100, "isForWash": false}
        ]
      }
    ]
  }
]
```

---

## Summary

- Treat preferments as ingredients with tracked internal flour and water.
- Total flour and water include all preferments.
- Baker's percentages and hydration are calculated on total flour.
- Support multiple flours and multiple preferments (parallel and serial).
- Provide scaling modes by yield, flour, and preferment availability.
- Warn and error on out-of-range parameters.
- Round only at display.
- Display columns: Total Formula, Preferments, Final Mix.
- Separate non-dough items (egg wash, toppings) from dough calculations.

---

*This comprehensive logic ensures accurate recipe scaling, hydration control, and preferment tracking for professional baking software and applications.*
