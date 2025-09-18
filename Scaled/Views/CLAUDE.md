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

Use SwiftUI's built-in property wrappers:

```swift
struct ContentView: View {
    @State private var isShowing = false     // Local view state
    @Binding var userName: String            // Two-way binding from parent
    @Environment(\.dismiss) var dismiss      // Environment values

    let user: User  // Observable model (if User is @Observable)

    var body: some View {
        // View implementation
    }
}
```

### View Composition

Build complex UIs from smaller, reusable components:

```swift
struct DashboardView: View {
    var body: some View {
        VStack {
            HeaderView()
            StatsSection()
            ActivityList()
        }
    }
}
```

## Guidelines

### DO:
- Keep views focused and small (under 150 lines ideally)
- Extract reusable components
- Use view modifiers for common styling
- Leverage SwiftUI's built-in components
- Use previews for rapid development
- Handle loading and error states

### DON'T:
- Put business logic in views (use Services)
- Make network calls directly from views
- Create deeply nested view hierarchies
- Ignore accessibility
- Use UIKit unless absolutely necessary

## Organization

As your app grows, organize by feature:

```
Views/
├── Shared/
│   ├── Buttons/
│   ├── Cards/
│   └── Forms/
├── Authentication/
│   ├── LoginView.swift
│   └── SignUpView.swift
├── Dashboard/
│   ├── DashboardView.swift
│   └── Components/
└── Settings/
    └── SettingsView.swift
```

## View Modifiers

Create custom view modifiers for consistent styling:

```swift
struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
    }
}

// Usage
Button("Save") { }
    .modifier(PrimaryButtonStyle())
```

## Testing

Test views using:
- Snapshot tests for visual regression
- UI tests for user flows
- Preview providers for different states