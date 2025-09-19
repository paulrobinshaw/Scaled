# Views Directory

This directory contains all SwiftUI views and UI components.

## SLC Principle: Simple, Lovable, Complete

Following our SLC approach (NOT MVP), views should be:
- **Simple**: Clean, readable SwiftUI code with clear intent
- **Lovable**: Delightful UI with smooth animations, thoughtful interactions, and attention to detail
- **Complete**: Fully functional with proper error states, loading states, and edge cases handled

No "good enough" UI - every view should feel polished and professional from the start.

## Purpose

Views are responsible for:
- Presenting data to users
- Handling user interactions
- Managing local UI state
- Composing smaller views into screens

## SwiftUI Best Practices

### State Management

Lean on SwiftUI's native property wrappers. Most Scaled views observe `@Observable` models through `@Bindable`:

```swift
struct FormulaSidebar: View {
    @Bindable var library: FormulaLibrary

    var body: some View {
        List(selection: $library.selection) {
            ForEach(library.formulas) { formula in
                NavigationLink(value: formula.id) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formula.name.isEmpty ? "Untitled" : formula.name)
                            .font(.headline)
                        Text("Hydration \(Int(formula.overallHydration))% · \(Int(formula.totalWeight))g")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
```

### View Composition

Build complex UIs from smaller, reusable components:

```swift
struct FormulaDetailView: View {
    @Bindable var formula: Formula

    var body: some View {
        TabView {
            FormulaEditView(formula: formula)
                .tabItem { Label("Edit", systemImage: "pencil") }

            CalculationsView(formula: formula)
                .tabItem { Label("Math", systemImage: "function") }
        }
    }
}
```

## Guidelines

### DO:
- Keep screens focused and small (under ~150 lines) and extract complex sections
- Observe `@Observable` models via `@Bindable` to keep hydration/salt metrics live
- Drive UI directly from services/models — format results inside helper views/modifiers
- Use custom modifiers for baker's math presentation (hydration badges, warning banners)
- Leverage previews to show baseline, high-hydration, and enriched dough states
- Audit accessibility (Dynamic Type, VoiceOver descriptions for warnings)

### DON'T:
- Put business logic or baker's math calculations in views — rely on services
- Make network or storage calls directly from views
- Create deeply nested view hierarchies (extract reusable components instead)
- Ignore accessibility/state restoration for warnings and critical metrics
- Reach for UIKit unless SwiftUI cannot achieve the interaction

## Organization

As your app grows, organize by feature:

```
Views/
├── Shell/
│   ├── ContentView.swift            # NavigationSplitView + App shell
│   └── FormulaSplitView.swift       # Sidebar + detail orchestration
├── Formula/
│   ├── FormulaEditView.swift        # Ingredient editing
│   ├── CalculationsView.swift       # Baker's math + validation output
│   └── Components/
│       ├── HydrationSummary.swift
│       ├── PrefermentList.swift
│       └── ScalingControls.swift
└── Shared/
    ├── Buttons/
    ├── Cards/
    └── Indicators/
```

## View Modifiers

Create custom view modifiers for consistent styling:

```swift
struct HydrationBadgeModifier: ViewModifier {
    let hydration: Double

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(hydrationColor.opacity(0.15))
            .foregroundStyle(hydrationColor)
            .clipShape(Capsule())
            .accessibilityLabel("Hydration \(Int(hydration)) percent")
    }

    private var hydrationColor: Color {
        switch hydration {
        case ..<55: return .orange
        case ..<85: return .green
        default: return .blue
        }
    }
}

extension View {
    func hydrationBadge(_ hydration: Double) -> some View {
        modifier(HydrationBadgeModifier(hydration: hydration))
    }
}

// Usage
Text("75% hydration")
    .hydrationBadge(75)
```

## Testing

Test views using:
- Snapshot tests for visual regression
- UI tests for user flows
- Preview providers for different states
