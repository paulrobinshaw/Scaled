# Learnings - Swift/SwiftUI Concepts & Solutions

This document captures important learnings, concepts, and solutions that arose during development of the Scaled app. It serves as a reference for understanding Swift/SwiftUI patterns and architectural decisions.

**Note**: This file is automatically updated whenever conceptual questions are asked during development.

## Table of Contents
- [@Observable and Class vs Struct](#observable-and-class-vs-struct)
- [Codable Protocol Purpose](#codable-protocol-purpose)
- [Final Class and Required Initializers](#final-class-and-required-initializers)
- [Swift Type-Checking Compiler Errors](#swift-type-checking-compiler-errors)
- [Preserving Identity When Decoding Observable Models](#preserving-identity-when-decoding-observable-models)
- [Keeping SwiftUI Views in Sync with @Bindable](#keeping-swiftui-views-in-sync-with-bindable)

---

## @Observable and Class vs Struct

### Question
Why use `@Observable` with classes instead of structs in our data models?

### Answer

#### What is @Observable?
`@Observable` is Swift's macro (Swift 5.9+) for making data observable in SwiftUI:
- Automatically tracks property changes and notifies views
- Only triggers updates when properties actually **read** by a view change
- More efficient than the older `@Published` pattern
- No need to mark individual properties

#### Why Class Instead of Struct?

**1. Reference Semantics Required**
```swift
// CLASS (Reference Type) ✅
@Observable
class Formula {
    var totalFlour: Double = 100
}

let formula = Formula()
let sameFormula = formula
sameFormula.totalFlour = 200  // Both variables point to same object

// STRUCT (Value Type) ❌
struct Formula {  // Can't use @Observable with struct
    var totalFlour: Double = 100
}
```

**2. Shared State Across Views**
- Same Formula instance needs to be displayed, modified, validated, and exported
- With classes, all views reference the same instance
- With structs, each view would have its own copy

**3. Complex Nested Data**
- Formula contains arrays of Preferments, Soakers, FinalMix
- With classes, modifying nested objects automatically updates parent
- With structs, complex update patterns would be needed

**4. SwiftUI Integration**
```swift
struct RecipeView: View {
    @State private var formula = Formula()  // Create once

    var body: some View {
        FormulaEditView(formula: formula)    // Pass reference
        FormulaDisplayView(formula: formula) // Same instance
    }
}
```

#### When We Use Structs
- Simple value types (`FlourItem`, `GrainItem`)
- Immutable data (`ValidationWarning`, `PercentageRow`)
- Small, copyable values (`FormulaYield`, `StarterComponent`)

---

## Codable Protocol Purpose

### Question
What is the purpose of `Codable` and why do we need it?

### Answer

`Codable` enables converting objects to/from external formats (JSON, property lists, etc.):

```swift
typealias Codable = Encodable & Decodable
```

#### Real-World Uses in Scaled

**1. Save Formulas to Device**
```swift
let formula = Formula(name: "My Sourdough")
let jsonData = try JSONEncoder().encode(formula)
UserDefaults.standard.set(jsonData, forKey: "saved_formula")
```

**2. Load Previously Saved Formulas**
```swift
if let jsonData = UserDefaults.standard.data(forKey: "saved_formula") {
    let formula = try JSONDecoder().decode(Formula.self, from: jsonData)
}
```

**3. Share Formulas Between Users**
```swift
// Export
let jsonData = try JSONEncoder().encode(formula)
// Send via email, AirDrop, etc.

// Import
let importedFormula = try JSONDecoder().decode(Formula.self, from: jsonData)
```

#### What Gets Encoded?
- ✅ Stored properties (actual data)
- ❌ Computed properties (recalculated when loaded)
- ❌ Hidden observation properties (from @Observable)

#### JSON Example
```json
{
  "name": "Country Sourdough",
  "yield": {
    "pieces": 2,
    "weightPerPiece": 800
  },
  "preferments": [{
    "name": "Levain",
    "flourWeight": 100,
    "waterWeight": 100
  }]
}
```

---

## Final Class and Required Initializers

### Question
Why did we get the error "Initializer requirement 'init(from:)' can only be satisfied by a 'required' initializer" and how do we fix it?

### Answer

#### The Problem
When a non-final class implements Codable's `init(from decoder:)`, Swift needs to ensure all subclasses can be decoded. This creates a requirement for `required` initializers.

#### Two Solutions

**Option 1: Make the Class `final` (Recommended)**
```swift
@Observable
final class FinalMix: Identifiable, Codable {
    // Can't be subclassed, so no 'required' needed
}
```

**Option 2: Use `required` Initializer**
```swift
@Observable
class FinalMix: Identifiable, Codable {
    required convenience init(from decoder: Decoder) throws {
        // All subclasses MUST implement this
    }
}
```

#### Why `final` is Better
1. **No Inheritance Needed**: Our models are concrete data types
2. **Performance**: Compiler can optimize final classes
3. **Clarity**: Explicitly states no subclassing intended
4. **Simpler**: No need for `required` keyword

#### Complete Pattern for @Observable + Codable
```swift
@Observable
final class ModelName: Identifiable, Codable {
    let id = UUID()
    var property1: String = ""

    init() { }

    enum CodingKeys: String, CodingKey {
        case property1  // Don't include 'id'
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        property1 = try container.decode(String.self, forKey: .property1)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(property1, forKey: .property1)
    }
}
```

---

## Decodable vs Encodable vs Codable

### Question
What's the difference between Decodable, Encodable, and Codable? When would we use each?

### Answer

#### The Three Protocols

**Encodable**: Convert Swift object → External format (JSON, etc.)
```swift
protocol Encodable {
    func encode(to encoder: Encoder) throws
}
```

**Decodable**: Convert External format → Swift object
```swift
protocol Decodable {
    init(from decoder: Decoder) throws
}
```

**Codable**: Both directions (it's just a typealias!)
```swift
typealias Codable = Encodable & Decodable
```

#### Visual Flow

```
        ENCODABLE →
Swift Object ←→ JSON/Data
        ← DECODABLE

        ←→ CODABLE
```

#### When to Use Each

**Use `Encodable` Only** - When you only need to send/save data:
```swift
// API request body that we send but never receive back
struct LoginRequest: Encodable {
    let username: String
    let password: String
}

// Usage: Convert to JSON to send to server
let request = LoginRequest(username: "baker", password: "sourdough")
let jsonData = try JSONEncoder().encode(request)
// Send jsonData to API...
```

**Use `Decodable` Only** - When you only need to receive/load data:
```swift
// API response that we receive but never send
struct WeatherData: Decodable {
    let temperature: Double
    let humidity: Double
    let timestamp: Date
}

// Usage: Convert from JSON received from server
let weatherData = try JSONDecoder().decode(WeatherData.self, from: jsonData)
// We never encode WeatherData back to JSON
```

**Use `Codable`** - When you need both (most common):
```swift
// Formula needs both: save to disk AND load from disk
@Observable
final class Formula: Codable {
    var name: String
    var water: Double
    // ...
}

// Can encode (save)
let jsonData = try JSONEncoder().encode(formula)

// Can decode (load)
let formula = try JSONDecoder().decode(Formula.self, from: jsonData)
```

#### Real-World Examples in Scaled

**Codable (Both Ways)**
- `Formula` - Save and load formulas
- `Recipe` - Import and export recipes
- `Preferment` - Part of Formula persistence

**Potentially Decodable Only**
```swift
// If we had an API for importing recipes from a website
struct WebRecipeImport: Decodable {
    let title: String
    let ingredients: [String]
    let source: URL
    // We import these but never send them back
}
```

**Potentially Encodable Only**
```swift
// Analytics event we send but never receive
struct BakeEvent: Encodable {
    let formulaId: UUID
    let timestamp: Date
    let action: String
    // We track these but never decode them in the app
}
```

#### Implementation Difference

**Encodable Implementation**
```swift
struct MyData: Encodable {
    let value: String

    // Only need encode method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }

    enum CodingKeys: String, CodingKey {
        case value
    }
}
```

**Decodable Implementation**
```swift
struct MyData: Decodable {
    let value: String

    // Only need init(from decoder:)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
    }

    enum CodingKeys: String, CodingKey {
        case value
    }
}
```

**Codable Implementation**
```swift
struct MyData: Codable {
    let value: String

    // Need BOTH methods
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }

    enum CodingKeys: String, CodingKey {
        case value
    }
}
```

#### Automatic vs Manual Implementation

**Automatic (for simple types)**
```swift
// Swift automatically implements both encode and decode
struct SimpleData: Codable {
    let name: String
    let value: Int
    // No implementation needed!
}
```

**Manual (for @Observable classes)**
```swift
@Observable
final class ComplexData: Codable {
    var name: String = ""

    // Must manually implement due to @Observable
    enum CodingKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}
```

#### Memory and Performance

- **Encodable only**: Slightly smaller memory footprint (no init from decoder)
- **Decodable only**: Slightly smaller memory footprint (no encode method)
- **Codable**: Most flexible but includes both protocols

In practice, the memory difference is negligible, so use what makes semantic sense:
- Use `Codable` when in doubt
- Use `Encodable` only for write-only data
- Use `Decodable` only for read-only data

---

## What is typealias?

### Question
What does `typealias` mean and when should we use it?

### Answer

`typealias` creates a **new name for an existing type**. It's just a nickname - not a new type.

#### Basic Syntax
```swift
typealias NewName = ExistingType

// Example
typealias Username = String
let user: Username = "baker123"  // Username IS String
```

#### Why Codable is a typealias
```swift
// Apple's definition
typealias Codable = Encodable & Decodable

// So when you write:
class Formula: Codable { }

// It's EXACTLY the same as:
class Formula: Encodable, Decodable { }
```

#### Common Use Cases

**1. Simplify Complex Types**
```swift
// Without typealias
var callback: (Bool, String?, Error?) -> Void

// With typealias - cleaner!
typealias Callback = (Bool, String?, Error?) -> Void
var callback: Callback
```

**2. Semantic Clarity**
```swift
typealias Grams = Double
typealias Percentage = Double

struct Preferment {
    var flourWeight: Grams = 100      // Clear units
    var hydration: Percentage = 100   // Clear meaning
}
```

**3. Protocol Combinations**
```swift
// Combine common protocols
typealias ViewableModel = Identifiable & Equatable & Hashable

struct Item: ViewableModel {
    let id = UUID()
    var name: String
}
```

#### Important: NOT Type Safety!
```swift
typealias Meters = Double
typealias Seconds = Double

let distance: Meters = 100
let time: Seconds = 50

// This compiles but is nonsense!
let bad = distance + time  // Both are just Double
```

For real type safety, use separate types:
```swift
struct Meters { let value: Double }
struct Seconds { let value: Double }
// Now you CAN'T accidentally add them
```

---

## Manual Codable Implementation for @Observable Classes

### Question
Why do I get "Type 'Formula' does not conform to protocol 'Decodable'" when I've declared Codable conformance?

### Answer

When you declare `extension Formula: Codable` but only provide `CodingKeys`, you haven't fully implemented the protocol. For `@Observable` classes, Swift can't auto-generate the required methods.

#### The Error Breakdown

**What You Had:**
```swift
@Observable
final class Formula: Identifiable {
    var name: String = ""
    // ... properties
}

extension Formula: Codable {
    enum CodingKeys: String, CodingKey {
        case name
    }
    // ❌ Missing implementations!
}
```

**What Codable Actually Requires:**
1. `CodingKeys` enum - Says WHAT to encode/decode ✅
2. `init(from decoder:)` - Says HOW to decode ❌
3. `encode(to:)` - Says HOW to encode ❌

#### The Complete Solution

```swift
extension Formula: Codable {
    // 1. Define what properties to save
    enum CodingKeys: String, CodingKey {
        case name, water, salt, preferments
    }

    // 2. Decodable: How to create Formula from JSON
    convenience init(from decoder: Decoder) throws {
        self.init()  // Call existing init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property
        name = try container.decode(String.self, forKey: .name)
        water = try container.decode(Double.self, forKey: .water)
        salt = try container.decode(Double.self, forKey: .salt)
        preferments = try container.decode([Preferment].self, forKey: .preferments)
    }

    // 3. Encodable: How to convert Formula to JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encode each property
        try container.encode(name, forKey: .name)
        try container.encode(water, forKey: .water)
        try container.encode(salt, forKey: .salt)
        try container.encode(preferments, forKey: .preferments)
    }
}
```

#### Key Methods to Know

**Decoding Methods:**
```swift
// Required property (throws if missing)
name = try container.decode(String.self, forKey: .name)

// Optional property (nil if missing)
notes = try container.decodeIfPresent(String.self, forKey: .notes)

// With default value if missing
version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
```

**Encoding Methods:**
```swift
// Always encode
try container.encode(name, forKey: .name)

// Only encode if not nil
try container.encodeIfPresent(notes, forKey: .notes)
```

#### Why Manual Implementation?

**Simple Struct - Auto Works:**
```swift
struct SimpleData: Codable {
    let name: String
    let value: Int
    // Swift auto-generates init(from:) and encode(to:)
}
```

**@Observable Class - Manual Required:**
```swift
@Observable
final class ComplexData: Codable {
    var name: String = ""

    // Swift adds hidden properties like:
    // var _$observationRegistrar = ObservationRegistrar()

    // These would break auto-generation, so we must
    // manually specify what to encode/decode
}
```

#### Common Pitfall: Missing Implementations

```swift
// This compiles but fails at runtime!
extension MyClass: Codable {
    enum CodingKeys: String, CodingKey {
        case property1, property2
    }
    // Forgot init(from:) and encode(to:)
}

// Error only appears when you try to use it:
let data = try JSONEncoder().encode(myInstance)  // 💥 Runtime crash!
```

#### Complete Pattern for Our Models

```swift
@Observable
final class MyModel: Identifiable, Codable {
    // Properties
    let id = UUID()
    var name: String = ""
    var value: Double = 0

    // Computed (not saved)
    var computed: Double { value * 2 }

    // Standard init
    init() {}

    // Codable implementation
    enum CodingKeys: String, CodingKey {
        case name, value
        // Don't include: id (auto-generated), computed (calculated)
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        value = try container.decode(Double.self, forKey: .value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
    }
}
```

#### Checklist for @Observable + Codable

- [ ] Class is marked `final`
- [ ] `CodingKeys` enum lists properties to save
- [ ] `convenience init(from decoder:)` implemented
- [ ] `encode(to encoder:)` implemented
- [ ] Optional properties use `decodeIfPresent`/`encodeIfPresent`
- [ ] Computed properties are NOT in CodingKeys

---

## Identifiable Protocol

### Question
What does Identifiable do and why do we need it?

### Answer

`Identifiable` gives objects a unique identity so SwiftUI can track them in lists and collections.

#### The Protocol
```swift
protocol Identifiable {
    associatedtype ID: Hashable
    var id: Self.ID { get }
}
```

Only requires ONE property: `id` (must be Hashable).

#### Why SwiftUI Needs It

**Problem without Identifiable:**
```swift
ForEach(recipes) { recipe in  // ❌ ERROR: SwiftUI can't track items
    Text(recipe.name)
}
```

**Solution with Identifiable:**
```swift
struct Recipe: Identifiable {
    let id = UUID()  // Unique identifier
    var name: String
}

ForEach(recipes) { recipe in  // ✅ SwiftUI tracks by id
    Text(recipe.name)
}
```

#### What It Enables

1. **Animations** - SwiftUI knows which item moved where
2. **State Preservation** - Selected items stay selected
3. **Performance** - Only changed items redraw
4. **Reordering** - Drag and drop knows item identity

#### In Our Scaled App

```swift
@Observable
final class Formula: Identifiable {
    let id = UUID()  // Automatically unique
    var name: String = ""
}

// Use in List
List(formulas) { formula in
    Text(formula.name)  // SwiftUI tracks each formula by id
}
```

#### Common ID Types

```swift
// UUID - Globally unique (recommended)
let id = UUID()  // "550e8400-e29b-41d4-a716-446655440000"

// String - Natural keys
let id: String  // "sourdough_recipe"

// Int - Database records
let id: Int  // 42
```

#### Key Benefits

- **Automatic tracking** in ForEach/List
- **Efficient updates** when data changes
- **Smooth animations** for add/remove/reorder
- **No duplicate key errors**

---

## Xcode Build Error: Multiple Commands Produce Same File

### Error
```
error: Multiple commands produce '/path/to/Scaled.app/CLAUDE.md'
```

### What It Means

Xcode is trying to copy multiple files with the same name (`CLAUDE.md`) to the same location in the app bundle. Since we have `CLAUDE.md` files in multiple directories:
- `/Scaled/Models/CLAUDE.md`
- `/Scaled/Services/CLAUDE.md`
- `/Scaled/Utilities/CLAUDE.md`
- `/Scaled/Views/CLAUDE.md`

Xcode doesn't know which one to use because they all want to be copied to the same destination.

### Why It Happens

When you add files to an Xcode project, they can be added to:
1. **Target Membership** - Files become part of the app bundle
2. **Reference Only** - Files are in the project for reference but not included in the app

Documentation files (`.md`) were accidentally added to the target's "Copy Bundle Resources" phase.

### How to Fix

**Option 1: Remove from Target (Recommended)**
1. In Xcode, select each `CLAUDE.md` file
2. In the File Inspector (right panel)
3. Uncheck "Target Membership" for the Scaled app target
4. These files are documentation only, not needed in the app bundle

**Option 2: Remove from Copy Bundle Resources**
1. Select your project in Xcode
2. Select the Scaled target
3. Go to "Build Phases" tab
4. Expand "Copy Bundle Resources"
5. Find all `CLAUDE.md` files
6. Select them and click the "-" button to remove

**Option 3: Rename Files**
If you need them in the bundle for some reason:
- Rename them to unique names like:
  - `Models-CLAUDE.md`
  - `Services-CLAUDE.md`
  - etc.

### Prevention

When adding documentation files to Xcode:
1. Choose "Create folder references" not "Create groups"
2. Don't check "Add to targets" for `.md` files
3. Or keep documentation files outside the main app directory

### Key Learning

**Build Phases** in Xcode control what happens during compilation:
- **Compile Sources**: `.swift` files get compiled
- **Copy Bundle Resources**: Resources copied into the app
- **Link Binary**: Frameworks get linked

Documentation files shouldn't be in "Copy Bundle Resources" unless your app specifically needs to read them at runtime.

---

## Hashable Requirement for List Selection

### Error
```
Generic struct 'List' requires that 'Formula' conform to 'Hashable'
```

### What It Means

When using `List(selection: $selectedItem)` in SwiftUI, the selection type must be `Hashable`. This allows SwiftUI to:
1. Track which item is currently selected
2. Compare items for equality
3. Store selections in Sets (which require Hashable elements)

### The Hashable Protocol

```swift
protocol Hashable: Equatable {
    func hash(into hasher: inout Hasher)
}

protocol Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool
}
```

Hashable requires two things:
1. **Equality** (`==`) - Determine if two items are the same
2. **Hashing** - Generate a unique integer for Set/Dictionary storage

### Why List Selection Needs Hashable

```swift
// SwiftUI's selection is a Set internally
@State private var selection: Set<Formula> = []

// Or for single selection
@State private var selectedFormula: Formula?

// List needs to:
List(selection: $selectedFormula) {
    // 1. Compare if tapped item == selectedFormula (needs Equatable)
    // 2. Store selection efficiently (needs Hashable)
    // 3. Animate selection changes (needs to track identity)
}
```

### The Fix for Our Formula Class

```swift
@Observable
final class Formula: Identifiable, Hashable {
    let id = UUID()  // Already have unique ID

    // Implement Equatable (part of Hashable)
    static func == (lhs: Formula, rhs: Formula) -> Bool {
        lhs.id == rhs.id  // Equal if same ID
    }

    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)  // Hash based on ID
    }
}
```

### Key Concepts

**1. Hash Values Must Match Equality**
```swift
// Rule: If a == b, then a.hashValue == b.hashValue
// Our implementation ensures this by using 'id' for both
```

**2. Reference Types vs Value Types**
```swift
// Classes (Reference Types) - Need manual implementation
class MyClass: Hashable {
    let id: UUID

    static func == (lhs: MyClass, rhs: MyClass) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Structs (Value Types) - Can auto-synthesize if all properties are Hashable
struct MyStruct: Hashable {
    let id: UUID  // UUID is Hashable
    let name: String  // String is Hashable
    // Automatically gets == and hash(into:)
}
```

**3. What Makes a Good Hash**
```swift
// Good - Based on identifying properties
func hash(into hasher: inout Hasher) {
    hasher.combine(id)  // Unique identifier
}

// Bad - Always same hash (poor performance)
func hash(into hasher: inout Hasher) {
    hasher.combine(1)  // All items hash to 1!
}

// Bad - Doesn't match equality
func hash(into hasher: inout Hasher) {
    hasher.combine(Date())  // Changes every time!
}
```

### Common SwiftUI Selection Patterns

**1. Single Selection**
```swift
struct ContentView: View {
    @State private var selectedItem: Item?  // Optional for single selection

    var body: some View {
        List(items, selection: $selectedItem) { item in
            Text(item.name)
        }
    }
}
```

**2. Multiple Selection**
```swift
struct ContentView: View {
    @State private var selectedItems: Set<Item> = []  // Set for multiple

    var body: some View {
        List(items, selection: $selectedItems) { item in
            Text(item.name)
        }
        .environment(\.editMode, .constant(.active))  // Enable multi-select
    }
}
```

**3. NavigationSplitView Selection**
```swift
NavigationSplitView {
    List(items, selection: $selectedItem) { item in
        NavigationLink(value: item) {
            Text(item.name)
        }
    }
} detail: {
    if let item = selectedItem {
        DetailView(item: item)
    }
}
```

### Alternative Without Hashable

If you can't make your type Hashable, track selection by ID:

```swift
@State private var selectedID: UUID?

List(formulas) { formula in
    NavigationLink(
        destination: DetailView(formula: formula),
        tag: formula.id,
        selection: $selectedID
    ) {
        Text(formula.name)
    }
}
```

### When You Need Hashable

- `List(selection:)` - Track selected items
- `Set<YourType>` - Store unique items
- `Dictionary<YourType, Value>` - Use as dictionary keys
- `ForEach` with `id: \.self` - When items are their own ID

### Best Practices

1. **Use Identifiable's ID for hashing** when available
2. **Keep hash function fast** - Don't do complex calculations
3. **Ensure hash matches equality** - Same equality = same hash
4. **Don't change hashable properties** after insertion into Set/Dictionary
5. **Consider using struct** if the type is naturally a value type

---

## Swift Type-Checking Compiler Errors

### Error
```
The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions
```

### What It Means

The Swift compiler has a timeout when trying to figure out types. When expressions are too complex, especially with:
- Deeply nested SwiftUI views
- Multiple inline closures
- Complex string interpolations
- Chained operations with type inference

The compiler gives up and asks you to simplify.

### Why It Happens in SwiftUI

SwiftUI's DSL (Domain Specific Language) relies heavily on type inference. When you write:
```swift
NavigationSplitView {
    List {
        ForEach(...) {
            VStack {
                HStack {
                    // More nesting...
                }
            }
        }
    }
} detail: {
    // More complex views...
}
```

The compiler has to:
1. Infer types for each view builder
2. Check all modifiers
3. Validate all closures
4. Combine everything into the final type

With too much nesting, this becomes exponentially complex.

### The Solution: Extract Sub-Views

**Before (Complex):**
```swift
var body: some View {
    NavigationSplitView {
        List(selection: $selectedFormula) {
            ForEach(formulas) { formula in
                NavigationLink(value: formula) {
                    VStack(alignment: .leading) {
                        Text(formula.name.isEmpty ? "Untitled" : formula.name)
                        HStack {
                            Text("Hydration: \(Int(formula.overallHydration))%")
                            Spacer()
                            Text("\(Int(formula.totalWeight))g")
                        }
                    }
                }
            }
        }
        // ... more nested content
    } detail: {
        // ... more nested views
    }
}
```

**After (Extracted):**
```swift
var body: some View {
    NavigationSplitView {
        sidebarView  // Extract to computed property
    } detail: {
        detailView   // Extract to computed property
    }
}

@ViewBuilder
private var sidebarView: some View {
    List(selection: $selectedFormula) {
        ForEach(formulas) { formula in
            NavigationLink(value: formula) {
                formulaRow(formula)  // Extract to function
            }
        }
    }
}

private func formulaRow(_ formula: Formula) -> some View {
    VStack(alignment: .leading) {
        Text(formula.name.isEmpty ? "Untitled" : formula.name)
        HStack {
            hydrationLabel(formula)  // Even more extraction
            Spacer()
            weightLabel(formula)
        }
    }
}
```

### Extraction Strategies

#### 1. Computed Properties for View Sections
```swift
@ViewBuilder
private var headerSection: some View {
    // Complex header view
}

@ViewBuilder
private var contentSection: some View {
    // Complex content
}
```

#### 2. Functions for Repeated Elements
```swift
private func makeRow(_ item: Item) -> some View {
    // Row view for item
}
```

#### 3. Separate View Structs for Major Components
```swift
struct FormulaListView: View {
    @Binding var formulas: [Formula]

    var body: some View {
        // List implementation
    }
}
```

### Common Triggers

1. **String Interpolation in Views:**
```swift
// Problem
Text("Value: \(String(format: "%.2f", calculation.result * 100))%")

// Solution - extract to computed property
var formattedValue: String {
    String(format: "%.2f%%", calculation.result * 100)
}
Text("Value: \(formattedValue)")
```

2. **Complex Ternary Operators:**
```swift
// Problem
Text(item.value > 100 ? "High: \(item.value)" : item.value > 50 ? "Medium: \(item.value)" : "Low: \(item.value)")

// Solution - extract to function
private func statusText(for value: Int) -> String {
    switch value {
    case 100...: return "High: \(value)"
    case 50...: return "Medium: \(value)"
    default: return "Low: \(value)"
    }
}
```

3. **Deeply Nested Builders:**
```swift
// Problem - 5+ levels deep
VStack {
    HStack {
        VStack {
            ForEach {
                HStack {
                    // Too deep!
                }
            }
        }
    }
}

// Solution - break into components
var body: some View {
    VStack {
        headerView
        contentList
    }
}
```

### Benefits of Extraction

1. **Faster Compilation** - Each piece type-checks independently
2. **Better Readability** - Named sections are self-documenting
3. **Reusability** - Extracted views can be reused
4. **Testability** - Smaller pieces are easier to test
5. **Performance** - SwiftUI can optimize smaller view hierarchies better

### Rules of Thumb

- If a view body is >50 lines, start extracting
- If nesting is >3 levels deep, extract inner levels
- If you see the error, immediately extract rather than trying small fixes
- Name extracted views/functions clearly to maintain readability

---

## Preserving Identity When Decoding Observable Models

### Question
Why did persisted `Formula`/`Preferment`/`Soaker` instances lose their identity after loading from storage, and how do we retain it?

### Answer

`@Observable` classes originally declared `let id = UUID()` and their custom `init(from:)` skipped the encoded identifier. During decoding, Swift created a brand-new instance with a fresh UUID, so every relationship (`Recipe.formulaId`, list selection, scaling lookups) broke once data round-tripped through persistence.

**Fix:** make `id` mutable and decode the stored UUID inside `init(from:)`, or pass it through a convenience initializer.

```swift
@Observable
final class Formula: Identifiable, Codable {
    var id: UUID = UUID()

    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let decodedId = try container.decodeIfPresent(UUID.self, forKey: .id) {
            id = decodedId
        }
        // decode the remaining properties…
    }

    init(name: String, id: UUID = UUID()) {
        self.id = id
        self.name = name
    }
}
```

### Why it Matters
- **Relationship integrity:** selection in `NavigationSplitView` and foreign-key style links rely on stable identifiers.
- **Business logic:** services such as `FormulaScalingService.scaleByAvailablePreferment` search by `UUID` and silently fail if IDs change.
- **Persistence correctness:** encoding/decoding should be lossless unless you intentionally re-key objects.

### Additional Tips
- Apply the same pattern to every observable model that encodes an `id`.
- When composing convenience initialisers, accept `id` as a parameter so call sites can inject known identifiers (useful in migrations/tests).

---

## Keeping SwiftUI Views in Sync with @Bindable

### Question
`CalculationsView` stopped updating hydration, salt %, and validation warnings while editing a formula. How do we keep the view reactive?

### Answer

The view accepted the model as a plain `let formula: Formula` and cached derived values in `@State`. Because there was no observation relationship, SwiftUI never re-rendered when nested properties changed.

**Solution:** receive the model as `@Bindable` (or `@ObservedObject` on earlier OSes) and compute derived values on demand.

```swift
struct CalculationsView: View {
    @Bindable var formula: Formula
    private let calculationService = FormulaCalculationService()

    private var bakersPercentages: BakersPercentageTable {
        calculationService.calculateBakersPercentages(for: formula)
    }

    var body: some View {
        ScrollView { /* render using live data */ }
    }
}
```

### Benefits
- **Live updates:** edits in `FormulaEditView` propagate instantly to calculations and validations.
- **Less state juggling:** no more `onAppear`/`onChange` bookkeeping or stale cached arrays.
- **Simpler testing:** derived data is pure, making previews and unit tests more predictable.

### When to Use
- Prefer `@Bindable` whenever you hand an `@Observable` model down the view hierarchy on iOS 17+/macOS 14+.
- Fall back to `@ObservedObject` + `ObservableObject` for earlier OS targets.

---

## Key Takeaways

1. **Use `@Observable` with classes** for SwiftUI reactive data
2. **Use structs** for simple value types without identity
3. **Implement Codable** for persistence and data transfer
4. **Use `final`** on @Observable classes to avoid required initializers
5. **Manually implement Codable** for @Observable classes to handle hidden properties
6. **Restore encoded identifiers** when decoding observable models to keep relationships intact
7. **Leverage `@Bindable`/`@ObservedObject`** so downstream views stay in sync with observable models
8. **Extract complex SwiftUI views** to avoid type-checking timeouts

---

## Fast Manual Recipe Entry in SwiftUI

### Question
How can we design a delightful manual recipe entry flow that lets bakers capture recipes quickly in SwiftUI?

### Answer

- **Anchor on the 60-second promise.** Manual entry is the primary capture path, so every screen should keep the baker focused on getting from "rough recipe" to a trustworthy formula in under a minute. Offer a clear choice between starting from a template or jumping straight into manual entry, and surface the progress toward a complete formula so the flow feels fast and intentional.【F:docs/PRD.md†L22-L29】【F:docs/PRD.md†L73-L79】
- **Structure inputs as bite-sized cards.** Use a vertically scrolling `List` (or `ScrollView` + `LazyVStack`) with sections for meta data, preferments, and final mix ingredients. Each row can be a lightweight view that accepts `@Bindable` models so edits propagate instantly. Show only the fields that matter for the ingredient type (e.g., flour rows expose weight + flour type picker, water rows expose temperature slider) to reduce decision fatigue.
- **Create a purpose-built keypad.** Replace the default keyboard with a numeric pad that includes quick-add controls for grams, percentages, and hydration shortcuts. Attach it with `.toolbar` when the ingredient amount field is focused, provide large tap targets, and respect hardware keyboard input. Pair with `@FocusState` to jump the cursor to the next logical field after submission so the baker never touches the screen more than necessary.【F:docs/PRD.md†L244-L248】
- **Offer rapid ingredient creation.** Provide a persistent "Add ingredient" button that inserts a pre-filled row using the most common flour or water choice, and support paste/import so bakers can drop text from spreadsheets or notes. Consider a multi-line capture sheet: a `TextEditor` with parsing preview that lets power users paste a whole recipe, review detected rows, and accept them into the structured list.
- **Layer delightful validation.** As weights change, calculate baker's percentages live and flash subtle confirmation (e.g., a checkmark pulse) when numbers look professional. For suspicious ratios, slide in inline warnings that explain the math and how to fix it, reinforcing trust without blocking progress. Summarize hydration, salt %, and prefermented flour in a sticky header so bakers feel oriented.
- **Speed up common adjustments.** Add swipe actions or trailing menus on ingredient rows for quick duplication, conversion between preferment/final mix, or toggling "counts as flour". Provide command menu shortcuts (`.commands`) and hardware keyboard navigation for pro bakers working on iPad or Magic Keyboard.
- **Delight through continuity.** Keep animations gentle but informative: fade in new rows, slide totals into place, and use haptics (`.sensoryFeedback`) when a section is complete. Respect offline constraints and autosave drafts frequently so bakers feel safe closing the app mid-entry.

---

*This document will be updated as new architectural questions arise during development.*

---

## SwiftUI Feature Modules & Baker's Math Helpers (2025-09-18)

### What changed?
We migrated Scaled away from monolithic services and global `@Observable` singletons to a feature-first layout:
- `Foundation/BakersMath` now hosts pure helpers like `hydration(for:)`, `preFermentedFlour(in:)`, and scaling utilities that keep baker's percentages intact.
- `Features/Formula` owns view state (`FormulaListModel`, `FormulaEditorModel`) and SwiftUI composition while depending on injected services.
- Undo/redo is centralized through a reusable `UndoStack` value type so inline ingredient edits can safely roll back.

### Why it matters
- **Testability**: Pure functions make it trivial to cover hydration, scaling, and mis-weigh correction edge cases without spinning up UI.
- **SwiftUI sanity**: Feature folders keep views lean (<300 lines) and ensure state flows through `@Bindable` models instead of ad-hoc view models.
- **Extensibility**: Protocol-driven services (`FormulaStoring`, `BakersPercentageCalculating`, `FormulaAnalyzing`) let us swap persistence or analytics without touching views.

### Tips for future work
- When adding a new feature, create sibling folders (`Views/`, `State/`, `Services/`, `Tests/`) so the Xcode file watcher picks them up automatically.
- Keep numerical helpers pure and surface errors via `ValidationWarning` so UI stays declarative.
- If a view needs more than ~250 lines, promote subviews into `Features/<Feature>/Components/` before adding logic.
