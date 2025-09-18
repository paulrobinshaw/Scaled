# Scaled - UI Design & Delightful Display Concepts

## Core Visual Philosophy
**"Professional tools can be beautiful at 3am"**

---

## 🎨 Main Recipe Display

### Recipe Cards Grid
```
┌─────────────────────────┐ ┌─────────────────────────┐
│ 🥖 Country Sourdough    │ │ 🥐 Croissants           │
│                         │ │                         │
│ 78% hydration          │ │ 65% hydration           │
│ 20% prefermented       │ │ Poolish + Butter        │
│                         │ │                         │
│ ● ● ● ○ ○              │ │ ● ● ● ● ●              │
│ Difficulty             │ │ Difficulty             │
└─────────────────────────┘ └─────────────────────────┘

┌─────────────────────────┐ ┌─────────────────────────┐
│ 🍞 White Sandwich       │ │ ➕ New Recipe           │
│                         │ │                         │
│ 62% hydration          │ │    Tap to create or    │
│ Direct dough           │ │    import recipe       │
│                         │ │                         │
│ ● ○ ○ ○ ○              │ │                         │
│ Difficulty             │ │                         │
└─────────────────────────┘ └─────────────────────────┘
```

### SwiftUI Implementation
```swift
struct RecipeCard: View {
    let recipe: Recipe
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with emoji and name
            HStack {
                Text(recipe.emoji)
                    .font(.largeTitle)
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            // Key stats
            VStack(alignment: .leading, spacing: 4) {
                HydrationBadge(percentage: recipe.hydration)
                if let preferment = recipe.preferment {
                    PrefermentBadge(type: preferment.type)
                }
            }

            Spacer()

            // Difficulty indicator
            DifficultyDots(level: recipe.difficulty)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: isPressed ? 2 : 8)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture { /* Navigate */ }
        .onLongPressGesture { /* Quick scale */ }
    }
}
```

---

## 🧮 Preferment Visualization

### Hydration Ring Display
```
        Levain (100% hydration)
       ╱                    ╲
      ○━━━━━━━━━━━━━━━━━━━━━○
     ┃ ████████████████████ ┃ 100%
     ┃                      ┃
     ○──────────────────────○
      ╲                    ╱
        Flour: 200g | Water: 200g
        Starter: 40g
```

### Preferment Bubble Animation
- Gentle floating bubbles to show fermentation activity
- More bubbles = more active fermentation
- Color intensity shows maturity

---

## 📊 Scaling Interface

### Quick Scale View
```
┌──────────────────────────────────┐
│  Current Recipe: Country Sourdough│
│  ──────────────────────────────  │
│                                   │
│      🍞 How many loaves?         │
│                                   │
│         [ 2 0 0 ]                 │
│                                   │
│      ⚖️ Weight per loaf?         │
│                                   │
│         [ 9 0 0 ] g               │
│                                   │
│  ──────────────────────────────  │
│                                   │
│  Total Dough: 180 kg              │
│                                   │
│  ┌────────────────────────────┐  │
│  │   Calculate Ingredients     │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

### Scale by Ingredient
```
┌──────────────────────────────────┐
│  Scale by Available Ingredient   │
│  ──────────────────────────────  │
│                                   │
│  I have: [Flour      ▼]          │
│                                   │
│  Amount: [ 2 5 . 5 ] kg          │
│                                   │
│  This will make:                  │
│  • 28 loaves @ 900g               │
│  • Total dough: 25.2 kg          │
│                                   │
│  [Calculate Full Recipe]          │
└──────────────────────────────────┘
```

---

## 📤 Two-Way Share Sheet Integration

### Share OUT - Recipe Export
```swift
struct RecipeShareSheet: View {
    let recipe: Recipe
    @State private var showShareSheet = false

    var body: some View {
        Button(action: { showShareSheet = true }) {
            Label("Share Recipe", systemImage: "square.and.arrow.up")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [
                recipe.asPDF(),           // PDF for printing
                recipe.asText(),          // Text for messaging
                recipe.asScaledJSON(),    // For sharing with other Scaled users
                recipe.asImage()          // Visual recipe card
            ])
        }
    }
}

extension Recipe {
    func asText() -> String {
        """
        🍞 \(name) - Baker's Formula

        Hydration: \(hydration)%
        Yield: \(yield)

        INGREDIENTS:
        \(formattedIngredients)

        BAKER'S PERCENTAGES:
        \(formattedPercentages)

        Made with Scaled 📱
        """
    }
}
```

### Share IN - Recipe Import
```swift
struct ImportHandler: View {
    @State private var importedRecipe: Recipe?

    var body: some View {
        EmptyView()
            .onOpenURL { url in
                handleImport(from: url)
            }
            .onContinueUserActivity(NSUserActivityTypePasteboard) { activity in
                handlePasteboardImport(activity)
            }
    }

    func handleImport(from url: URL) {
        // Handle .scaled files
        // Handle images with OCR
        // Handle text parsing
    }
}
```

### Share Sheet Actions

**Export Options:**
1. **PDF Recipe Card** - Beautiful for printing
2. **Plain Text** - For WhatsApp/Messages
3. **Scaled Format** (.scaled) - Full data for other users
4. **Image Snapshot** - Visual recipe for Instagram
5. **CSV** - For spreadsheet users

**Import Sources:**
1. **Photos** - OCR recipe extraction
2. **Files** - .scaled, .pdf, .txt
3. **Clipboard** - Paste recipe text
4. **AirDrop** - From other bakers
5. **Web URLs** - Recipe blog import

---

## 🌙 Morning Mode (Auto 3am-7am)

### Dark Theme Adjustments
```swift
struct MorningModeModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @State private var isMorningTime = false

    var backgroundColor: Color {
        if isMorningTime {
            // Warm dark background to reduce eye strain
            return Color(red: 0.05, green: 0.03, blue: 0.02)
        }
        return Color(.systemBackground)
    }

    var textColor: Color {
        if isMorningTime {
            // Slightly warm white for comfort
            return Color(red: 1.0, green: 0.97, blue: 0.94)
        }
        return Color(.label)
    }
}
```

---

## ✨ Delightful Animations

### Number Rolling
```swift
struct RollingNumber: View {
    let value: Double
    @State private var displayValue: Double = 0

    var body: some View {
        Text(String(format: "%.1f", displayValue))
            .font(.system(.largeTitle, design: .rounded))
            .monospacedDigit()
            .onChange(of: value) { newValue in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    displayValue = newValue
                }
            }
    }
}
```

### Dough Ball Scaling
```swift
struct DoughBallView: View {
    let totalWeight: Double

    var scaleFactor: CGFloat {
        // Scale between 0.5x and 2x based on weight
        min(max(totalWeight / 1000, 0.5), 2.0)
    }

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 0.94, green: 0.89, blue: 0.82),
                        Color(red: 0.87, green: 0.79, blue: 0.68)
                    ],
                    center: .topLeading,
                    startRadius: 5,
                    endRadius: 100
                )
            )
            .frame(width: 100 * scaleFactor, height: 100 * scaleFactor)
            .overlay(
                Text("\(Int(totalWeight))g")
                    .font(.caption)
                    .foregroundColor(.white)
            )
            .animation(.spring(), value: totalWeight)
    }
}
```

---

## 📱 Haptic Feedback

```swift
extension View {
    func scaledHaptic(_ type: ScaledHapticType) -> some View {
        self.onTapGesture {
            switch type {
            case .calculation:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .scaling:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
}

enum ScaledHapticType {
    case calculation, success, warning, scaling
}
```

---

## 🎯 Quick Actions

### Context Menu on Recipe Cards
```swift
.contextMenu {
    Button {
        quickScale(by: 2)
    } label: {
        Label("Double Recipe", systemImage: "multiply.circle")
    }

    Button {
        quickScale(by: 0.5)
    } label: {
        Label("Half Recipe", systemImage: "divide.circle")
    }

    Divider()

    Button {
        exportToPDF()
    } label: {
        Label("Export PDF", systemImage: "doc.fill")
    }

    ShareLink(item: recipe) {
        Label("Share Recipe", systemImage: "square.and.arrow.up")
    }

    Divider()

    Button(role: .destructive) {
        deleteRecipe()
    } label: {
        Label("Delete", systemImage: "trash")
    }
}
```

---

## 🎨 Color Coding System

```swift
enum RecipeColors {
    static let sourdough = Color(red: 0.84, green: 0.72, blue: 0.51)    // Warm tan
    static let yeasted = Color(red: 0.95, green: 0.83, blue: 0.62)      // Light wheat
    static let enriched = Color(red: 1.0, green: 0.89, blue: 0.71)      // Buttery yellow
    static let preferment = Color(red: 0.67, green: 0.78, blue: 0.89)   // Sky blue
    static let hydrationLow = Color.orange
    static let hydrationMedium = Color.blue
    static let hydrationHigh = Color.purple
}
```

---

## 📊 Formula Display

```
┌────────────────────────────────────┐
│ Country Sourdough - 200 loaves     │
│ ──────────────────────────────────│
│                                    │
│ PREFERMENT (Levain)                │
│ ├─ Bread Flour       20.0 kg  10% │
│ ├─ Whole Wheat       20.0 kg  10% │
│ ├─ Water            40.0 kg  20% │
│ └─ Starter           8.0 kg   4% │
│                                    │
│ FINAL DOUGH                        │
│ ├─ Bread Flour      140.0 kg  70% │
│ ├─ Whole Wheat       20.0 kg  10% │
│ ├─ Water           116.0 kg  58% │
│ └─ Salt              4.0 kg   2% │
│                                    │
│ ──────────────────────────────────│
│ Total Flour:        200.0 kg      │
│ Total Water:        156.0 kg      │
│ Total Hydration:    78%            │
│ Prefermented Flour: 20%            │
│ Total Dough:        360.0 kg      │
│                                    │
│ [Share] [Print] [Scale] [Save]     │
└────────────────────────────────────┘
```

---

## 🚀 Implementation Priority

1. **Week 1:** Basic recipe cards with tap navigation
2. **Week 2:** Scaling interface with number rolling
3. **Week 3:** Share sheet integration (import/export)
4. **Week 4:** Preferment visualizations
5. **Week 5:** Morning mode and haptics
6. **Week 6:** Polish animations and transitions

---

*"Make the math beautiful, and bakers will trust it."*