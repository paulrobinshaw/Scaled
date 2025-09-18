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
class User {
    var id: UUID = UUID()
    var name: String = ""
    var email: String = ""
    var isActive: Bool = true
}
```

## Guidelines

### DO:
- Use value types (struct) for simple data without identity
- Use reference types (class) with @Observable for shared state
- Keep models focused on a single responsibility
- Use Swift's Codable for JSON serialization
- Define computed properties for derived values

### DON'T:
- Put business logic in models (use Services)
- Make network calls from models
- Include view-specific formatting (use Views or Extensions)
- Create massive "God objects" with too many responsibilities

## Example Structure

As your app grows, organize models by feature:

```
Models/
├── User.swift
├── Authentication/
│   ├── LoginCredentials.swift
│   └── AuthToken.swift
├── Content/
│   ├── Post.swift
│   ├── Comment.swift
│   └── Media.swift
└── Settings/
    ├── UserPreferences.swift
    └── AppConfiguration.swift
```

## Testing

Every model should have corresponding unit tests that verify:
- Initialization with default values
- Codable encoding/decoding
- Computed properties
- Any validation logic