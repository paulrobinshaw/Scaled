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
// Date+Extensions.swift
extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    func formatted(as format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// String+Validation.swift
extension String {
    var isValidEmail: Bool {
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return predicate.evaluate(with: self)
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
```

## Custom View Modifiers

Create reusable styling and behavior modifiers:

```swift
// ViewModifiers.swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// LoadingOverlay.swift
struct LoadingOverlay: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .allowsHitTesting(!isLoading)
    }
}
```

## Constants and Configuration

```swift
// Constants.swift
enum Constants {
    enum API {
        static let baseURL = "https://api.example.com/v1"
        static let timeout: TimeInterval = 30
    }

    enum UI {
        static let cornerRadius: CGFloat = 12
        static let spacing: CGFloat = 16
        static let animationDuration: Double = 0.3
    }

    enum Storage {
        static let userKey = "com.app.currentUser"
        static let settingsKey = "com.app.settings"
    }
}
```

## Helper Functions

Keep helper functions pure and testable:

```swift
// Helpers.swift
enum Helpers {
    static func delay(_ seconds: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    static func randomID() -> String {
        UUID().uuidString
    }

    static func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: amount as NSNumber) ?? "$0.00"
    }
}
```

## Guidelines

### DO:
- Keep utilities pure (no side effects when possible)
- Group related utilities together
- Write unit tests for complex utilities
- Use meaningful names
- Add documentation comments
- Make utilities generic when appropriate

### DON'T:
- Create "Utils" grab bags with unrelated functions
- Duplicate Swift standard library functionality
- Make utilities dependent on app state
- Over-engineer simple problems

## Organization

```
Utilities/
├── Extensions/
│   ├── View+Extensions.swift
│   ├── Date+Extensions.swift
│   ├── String+Extensions.swift
│   └── Collection+Extensions.swift
├── ViewModifiers/
│   ├── Styling.swift
│   └── Animations.swift
├── Helpers/
│   ├── Validators.swift
│   └── Formatters.swift
└── Constants.swift
```

## Testing

Test utilities thoroughly since they're used throughout the app:

```swift
class DateExtensionsTests: XCTestCase {
    func testIsToday() {
        let today = Date()
        XCTAssertTrue(today.isToday)

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        XCTAssertFalse(yesterday.isToday)
    }
}
```

## Common Utilities to Include

- **Validation**: Email, phone, password strength
- **Formatting**: Dates, numbers, currency, percentages
- **Colors**: Theme colors, semantic colors
- **Typography**: Font styles, sizes
- **Animations**: Common transitions and effects
- **Device**: Screen size helpers, platform detection
- **Debugging**: Logging utilities, development helpers