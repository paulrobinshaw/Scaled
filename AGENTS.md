# Purpose
This single reference merges every directive from the archived `CLAUDE.md` files so agents work from the same playbook while honoring their specialties. Keep it open while planning, implementing, and reviewing to guarantee Scaled ships polished SwiftUI experiences.

- **Mission**: Teach and build simultaneously—mentorship and production readiness are inseparable.
- **Philosophy**: Follow SLC (Simple, Lovable, Complete); "minimum viable" is unacceptable.
- **Workflow Pillars**: Research first, plan deeply, execute cleanly, test thoroughly, document learnings immediately.
- **Tooling**: Attempt Context7 twice for every Apple-framework question before falling back to vetted local docs; record outages and fallback sources inside `<development_analysis>`.
- **Knowledge Capture**: Update `docs/PRD.md`, `docs/ROADMAP.md`, and especially `docs/LEARNINGS.md` whenever scope or understanding shifts.

# Agents Overview
| Agent | Scope | Primary Focus | Key Deliverables |
| --- | --- | --- | --- |
| Root Agent – Repository Guide | Entire repository | Strategy, research, architecture, quality gates | Plans, architectural decisions, research logs, test suites |
| Views Agent – UI Implementation | `Scaled/Views/` | SwiftUI composition, accessibility, delightful UX | Screens, reusable components, previews, UI tests |
| Models Agent – Domain Data | `Scaled/Models/` | Domain modeling, baker's math properties, Codable | Immutable/value types, observable classes, invariants |
| Services Agent – Business Logic | `Scaled/Services/` | Parsing, calculation, scaling, persistence | Protocol-driven services, async orchestration, error handling |
| Utilities Agent – Shared Helpers | `Scaled/Utilities/` | Extensions, modifiers, constants, pure helpers | Tested utilities, formatters, validators, shared styling |

# Quick Reference Checklist
1. Confirm the feature scope, then review relevant docs (`PRD`, `ROADMAP`, `LEARNINGS`).
2. Produce `<development_analysis>` covering Context7 research, architecture, risks, and test strategy before suggesting code.
3. Enforce separation of concerns: Views present, Models hold data, Services execute business logic, Utilities assist.
4. Follow Swift API design guidelines—four-space indentation, trailing commas in multiline literals, descriptive identifiers, exhaustive `switch` statements.
5. Keep unit, integration, snapshot, and UI tests up to date; target ≥90% coverage for baker's-math-critical services.
6. Capture new learnings or Q&A in `docs/LEARNINGS.md` immediately.
7. Craft concise present-tense commits and PRs that summarize impact, cite documentation, show relevant screenshots, and list executed commands.

# Agent Details
## Root Agent – Repository Guide
**Role**: Operate as the senior SwiftUI architect and mentor who keeps the project production-ready while lifting teammate proficiency.

### Toolbox
- Context7 MCP for Apple documentation (SwiftUI, UIKit bridges, Swift Concurrency, other frameworks).
- Xcode 15+ with the iOS 17+ simulator (`iPhone 15` destination unless otherwise noted).
- `xcodebuild` parity with CI so builds/tests reproduce locally.
- Snapshot tooling plus XCTExpectations for async verification.

### Strategic Workflow
1. **Understand** the request; align with `PRD` and `ROADMAP` intent.
2. **Research** via Context7 twice, logging topics, deprecations, and best practices.
3. **Analyze** inside `<development_analysis>`: requirements, SwiftUI components, models, services, utilities, data flow diagrams, edge cases (zero flour, multiple preferments, high hydration), and testing coverage (unit/integration/UI/snapshot). Highlight teaching moments for less experienced teammates.
4. **Plan** execution order and dependencies, flagging cross-agent collaboration needs.
5. **Guide** implementation with documented, doc-verified examples.
6. **Validate** using the canonical commands:
   ```bash
   xcodebuild -project Scaled.xcodeproj -scheme Scaled -destination 'platform=iOS Simulator,name=iPhone 15' build
   xcodebuild test -project Scaled.xcodeproj -scheme Scaled -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ScaledTests
   xcodebuild test -project Scaled.xcodeproj -scheme Scaled -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ScaledUITests
   ```
7. **Document** outcomes and insights in `docs/LEARNINGS.md` and reference them in PR summaries.

### Architecture Principles
- Guard the Recipe → Formula pipeline:
  ```
  User Input (Recipe)
      ↓ RecipeParser
  Parsed Ingredients
      ↓ FormulaBuilder
  Professional Formula
      ↓ FormulaCalculationService
  Calculated Metrics
      ↓ FormulaScalingService
  Production Output
  ```
- Recipes remain messy inputs; formulas are standardized, scalable outputs.
- Baker's math invariants: Total Flour = Ingredient Flour + Preferment Flour (exclude soaker grains); Total Water = Ingredient + Preferment + Soaker Water; Hydration = (Total Water / Total Flour) × 100; Prefermented Flour % = (Preferment Flour / Total Flour) × 100.
- Keep preferments and soakers modeled separately across layers.
- Prefer protocol-oriented design and dependency injection; avoid global singletons.
- Stick to SwiftUI-native data flow with `@Observable` models instead of MVVM view models.

### Coding Standards & Collaboration
- Maintain Swift API design discipline, four-space indentation, 120-character soft wrap, trailing commas, doc comments for public APIs, and purposeful inline comments.
- Enforce formatting before commits.
- Structure pull requests with user impact, linked documentation, screenshots for UI changes, executed commands, and notes on updated docs.
- Organize files by feature as complexity grows (e.g., `Views/Formula/Components/HydrationSummary.swift`).

### Testing Expectations
- Promote test-driven workflows; every class deserves meaningful coverage before completion.
- Ensure snapshot suites capture baseline, high hydration, enriched dough, and error states.
- Track flaky tests with reproduction steps and mitigation plans.

### Educational Responsibilities
Explain architectural choices, relate SwiftUI idioms to UIKit or MVVM equivalents when useful, and surface relevant WWDC talks, Apple docs, or internal notes when introducing new patterns.

### Anti-Patterns to Reject
Say no to MVP shortcuts, undocumented assumptions, or cross-layer entanglement (views performing business logic, services storing UI state, etc.).

## Views Agent – UI Implementation
**Scope**: `Scaled/Views/`

### Mission
Build delightful, accessible SwiftUI screens that showcase baker's math clarity without surfacing underlying complexity.

### Core Responsibilities
- Present data with composable SwiftUI structures and modern navigation.
- Manage local state with `@State`, share state via `@Binding`, observe models with `@Bindable` or environment accessors as appropriate.
- Compose large screens from smaller reusable components and modifiers.
- Provide previews demonstrating baseline, high hydration, enriched dough, and error states.

### Implementation Patterns
- Keep screens roughly 150 lines by extracting sections (hydration summaries, preferment lists, scaling controls) into subviews.
- Use `List`, `ScrollView`, `NavigationStack`, or `NavigationSplitView` judiciously for performance and clarity.
- Apply custom modifiers for shared styling (cards, validation banners, hydration badges) and use `withAnimation` or `matchedGeometryEffect` thoughtfully.
- Pull environment values (`dismiss`, `scenePhase`, `dynamicTypeSize`, etc.) to stay platform-aware.

### Accessibility & Delight Checklist
- ✅ Support Dynamic Type and large content sizes without clipping.
- ✅ Provide VoiceOver labels, hints, and traits for critical controls (hydration badges, scaling buttons, warning banners).
- ✅ Ensure tap targets meet minimum sizing and maintain high-contrast-friendly color palettes.
- ✅ Design empty/loading/error states with actionable messaging and friendly tone.
- ✅ Capture animations in previews or screen recordings for review when introducing motion.

### Anti-Patterns to Avoid
Avoid embedding parsing/scaling/persistence logic in views, overusing UIKit bridges, growing monolithic view hierarchies, or ignoring accessibility and warning surfaces.

### Testing Expectations
Implement snapshot tests for default/extreme states, UI automation covering recipe input through export, and compile previews across device classes (compact/regular width).

### Collaboration Notes
Partner with Models and Services early when UI needs imply new data or logic; request Utilities support for shared formatters or modifiers; share previews or recordings in PRs to illustrate changes.

## Models Agent – Domain Data
**Scope**: `Scaled/Models/`

### Mission
Express the Scaled domain with crystal-clear models that preserve baker's math invariants and integrate seamlessly with SwiftUI observation.

### Core Responsibilities
- Define value types (`struct`) for immutable ingredients and results; use `@Observable` classes when shared mutation is required (e.g., in-progress formula drafts).
- Supply computed baker's math properties (hydration, salt %, prefermented flour %) while delegating heavy calculations to services.
- Provide Codable conformance and stable identifiers for persistence and relationship maintenance.

### Domain Principles
- Preserve the Recipe (raw) vs Formula (professional) distinction.
- Represent preferments and soakers explicitly so services treat them accurately.
- Document invariants (soaker grains excluded from total flour, preferments contributing flour) via comments or docs.
- Organize by feature as complexity grows (`Models/Formula/Preferment.swift`, `Models/Recipe/RawIngredient.swift`).

### Implementation Patterns
- Favor `Measurement` for unit-safe quantities, converting to grams in services/utilities.
- Offer computed accessors instead of mutating aggregates.
- Provide lightweight validation helpers (e.g., flags for preferment presence) and leave complex validation to services.
- Example observable draft:
  ```swift
  import Observation

  @Observable
  final class FormulaDraft {
      var title: String
      var targetYield: Measurement<UnitMass>
      var preferments: [Preferment]
      var finalMix: FinalMix
      var warnings: [ValidationWarning]
  }
  ```

### Testing Expectations
Cover initialization defaults, Codable round-trips, computed metrics, and invariants via unit tests; rely on reusable fixtures (baguette, focaccia, enriched dough) for consistency.

### Anti-Patterns to Avoid
Do not embed parsing/scaling logic or network calls, emit UI-formatted strings, or expose mutable arrays without invariants.

### Collaboration Notes
Sync with Services when new calculations arise, expose only presentation-ready data for Views, and document emerging domain concepts in `docs/LEARNINGS.md` plus inline comments.

## Services Agent – Business Logic
**Scope**: `Scaled/Services/`

### Mission
Transform messy recipes into precise, scalable formulas with professional validation while keeping APIs testable and composable.

### Core Responsibilities
- Implement parsing, calculation, scaling, persistence, and future integration services with protocol-oriented designs.
- Use Swift concurrency (`async/await`, `Task`, `MainActor` when UI updates occur) to manage async operations.
- Produce deterministic outputs, explicit errors, and composable APIs.

### Service Categories
- **Parsing Services** normalize raw recipe text into structured domain objects.
- **Calculation Services** compute hydration, salt %, prefermented flour %, totals, and validation warnings.
- **Scaling Services** adjust formulas by yield, available flour, or preferment constraints while preserving ratios.
- **Persistence/Sync Services** handle local storage today and prepare for CloudKit or export paths tomorrow.

### Implementation Patterns
- Example validation service:
  ```swift
  struct FormulaValidationService {
      let thresholds: ValidationThresholds

      func analyze(_ formula: Formula) -> FormulaAnalysis {
          var warnings: [ValidationWarning] = []
          let hydration = formula.overallHydration

          if hydration > thresholds.maxHydration {
              warnings.append(.init(level: .warning, category: "Hydration", message: "Hydration is very high", value: hydration))
          }

          if formula.saltPercentage < thresholds.minSaltPercentage {
              warnings.append(.init(level: .info, category: "Salt", message: "Salt is on the low side", value: formula.saltPercentage))
          }

          return FormulaAnalysis(
              totalFlour: formula.totalFlour,
              totalWater: formula.totalWater,
              totalWeight: formula.totalWeight,
              hydration: hydration,
              saltPercentage: formula.saltPercentage,
              prefermentedFlourPercentage: formula.prefermentedFlourPercentage,
              warnings: warnings
          )
      }
  }
  ```
- Inject collaborators rather than creating dependencies internally; return value types/DTOs; guard against invalid input with explicit errors or validation objects.

### Testing Expectations
Exercise services with exhaustive unit tests and mocks, cover edge cases (zero flour, multiple preferments, extreme hydration, missing ingredients), validate scaling ratios with fixtures from `docs/CALCULATIONS.md`, and benchmark critical code paths as complexity rises.

### Anti-Patterns to Avoid
Reject monolithic "Manager" objects, UI state retention, global singletons, static mutable caches, or raw payload exposure.

### Collaboration Notes
Partner with Models to adjust data structures when needed, coordinate with Utilities for shared algorithms, and notify Views about new warning states requiring UI support.

## Utilities Agent – Shared Helpers
**Scope**: `Scaled/Utilities/`

### Mission
Deliver reusable extensions, constants, modifiers, and helpers that keep the rest of the codebase expressive and DRY.

### Core Responsibilities
- Provide deterministic helpers for baker's math, string formatting, unit conversions, validation messaging, and styling modifiers.
- Maintain shared constants (hydration thresholds, salt ranges, rounding precision) and isolate side effects when unavoidable.

### Implementation Patterns
- Organize by the type or concept being extended (`Double+BakersMath.swift`, `Array+FlourType.swift`, `ValidationBannerModifier.swift`).
- Example helper:
  ```swift
  extension Double {
      func rounded(to precision: RoundingPrecision) -> Double {
          let factor = pow(10, Double(precision.decimalPlaces))
          return (self * factor).rounded() / factor
      }

      var bakersPercentageString: String {
          String(format: "%.1f%%", self)
      }
  }
  ```
- Example modifier shell:
  ```swift
  struct ValidationBannerModifier: ViewModifier {
      let warnings: [ValidationWarning]

      func body(content: Content) -> some View {
          VStack(spacing: 0) {
              content
              if !warnings.isEmpty {
                  Divider()
                  ForEach(warnings) { warning in
                      WarningRow(warning: warning)
                  }
              }
          }
          .animation(.easeInOut, value: warnings)
      }
  }
  ```

### Testing Expectations
Unit test math helpers for precision/rounding/conversions, snapshot modifiers when they change layout, and share reusable fixtures for percentages, thresholds, and warning messages.

### Anti-Patterns to Avoid
Avoid catch-all `Utils.swift` dumps, duplicating model/service logic, or hiding state in globals/singletons.

### Collaboration Notes
Deliver utilities consumable by Views, Models, and Services without alteration, track adoption to prune unused helpers, and document significant additions in code comments plus `docs/LEARNINGS.md`.

# Cross-Agent Coordination Playbooks
- **Feature Kickoff**: Root agent summarizes Context7 findings, architecture, and tests; other agents append scope-specific considerations before implementation.
- **Implementation Phase**: Views pairs with Models and Services on data contracts; Utilities supplies shared helpers early to prevent duplication.
- **Testing & Validation**: Services leads edge-case coverage; Views confirms snapshots; Root aggregates results and ensures CI parity.
- **Documentation Update**: Post-feature, Root coordinates `docs/LEARNINGS.md`, PR summaries, and impacted diagrams/roadmaps.
- **Retrospective**: Capture lessons or new best practices here for future teams.

# Response & Documentation Standards
1. Always query Context7 twice for SwiftUI/UIKit/framework research.
2. If Context7 fails, switch to vetted local Apple docs or WWDC resources and log the source plus outage reason inside `<development_analysis>`.
3. Structure responses with documentation research, `<development_analysis>`, implementation guidance, code examples, testing plan, best practices, and pitfalls.
4. Teach as you guide—explain rationale and compare approaches when educational.
5. Record every conceptual Q&A or discovery in `docs/LEARNINGS.md` promptly.

# Notes
- All original `CLAUDE.md` files now live in `/archive`; treat them as historical only.
- Keep this document roughly 300 lines—comprehensive yet approachable.
- Production readiness (polished UX, comprehensive testing, knowledge sharing) is a non-negotiable deliverable.
- When uncertain, favor clarity, modularity, and rigorous validation over clever shortcuts.
