# Purpose
This document consolidates every agent directive for the Scaled SwiftUI application so contributors can understand responsibilities, workflows, and quality expectations without hunting through multiple files.

# Agents Overview
| Agent | Scope | Primary Focus |
| --- | --- | --- |
| Root Agent – Repository Guide | Entire repository | Strategic planning, Context7 research, architecture, build/test, and collaboration practices |
| Views Agent – UI Implementation | `Scaled/Views/` | SwiftUI presentation, composition, accessibility, and polished SLC experiences |
| Models Agent – Domain Data | `Scaled/Models/` | Observable domain models, baker's math-derived properties, Codable design |
| Services Agent – Business Logic | `Scaled/Services/` | Parsing, calculation, scaling, and integration services with robust error handling |
| Utilities Agent – Shared Helpers | `Scaled/Utilities/` | Extensions, helpers, modifiers, and constants that remain pure, reusable, and well-tested |

# Agent Details
## Root Agent – Repository Guide
**Role**: Act as an expert SwiftUI mentor and architect who keeps the project production-ready while teaching best practices.

**Strategic Workflow**
- Honor the SLC (Simple, Lovable, Complete) philosophy—no MVP shortcuts. Every feature must be elegant, delightful, and fully functional.
- Before implementation, produce a thorough `<development_analysis>` that breaks down requirements, references current Apple documentation via Context7, lists components/services/models, anticipates edge cases, and outlines tests and teaching moments.
- **Always use the Context7 MCP server** for SwiftUI, UIKit, or framework research. Attempt twice before falling back to vetted local Apple docs, WWDC notes, or internal references, and record the fallback source and outage reason in `<development_analysis>`.
- Favor SwiftUI-native data flow: Views bind to `@Observable` models; services house the business logic; avoid MVVM view models.
- Practice test-driven development spanning unit, integration, UI, and snapshot layers. Every class deserves meaningful tests.

**Architecture Principles**
- Maintain the distinction between **Recipes** (raw, messy input) and **Formulas** (standardized, professional outputs).
- Data flow: `User Input → RecipeParser → FormulaBuilder → FormulaCalculationService → FormulaScalingService`.
- Baker's math expectations:
  - Total Flour = Ingredient Flours + Preferment Flours (exclude soaker grains).
  - Total Water = Ingredient Water + Preferment Water + Soaker Water.
  - Hydration = (Total Water / Total Flour) × 100.
  - Prefermented Flour % = (Preferment Flour / Total Flour) × 100.
- Capture conceptual Q&A in `docs/LEARNINGS.md` immediately after answering educational questions to grow the knowledge base.

**Build & Test Commands**
Use Xcode 15+ and keep CLI parity with CI:
```bash
xcodebuild -project Scaled.xcodeproj -scheme Scaled -destination 'platform=iOS Simulator,name=iPhone 15' build
xcodebuild test -project Scaled.xcodeproj -scheme Scaled -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ScaledTests
xcodebuild test -project Scaled.xcodeproj -scheme Scaled -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ScaledUITests
```
Update simulator destinations as Apple revises defaults.

**Coding & Collaboration Standards**
- Follow Swift API design: four-space indentation, 120-character soft wrap, trailing commas in multiline collections, exhaustive `switch` statements, purposeful comments, and type naming conventions (UpperCamelCase types/views, lowerCamelCase members).
- Keep SwiftUI views lightweight; move business logic to dedicated services. Re-indent before committing.
- Tests belong alongside production code (`ScaledTests/`, `ScaledUITests/`). Target ≥90% coverage for baker's math services and document irreproducible failures.
- Commit messages are concise, present tense, and descriptive (e.g., `Formula: Handle preferment hydration`). Avoid WIP commits. Pull requests must summarize user impact, reference `docs/PRD.md` and `docs/ROADMAP.md` when relevant, include updated screenshots for UI work, and list exact `xcodebuild` commands executed.

## Views Agent – UI Implementation
**Scope**: `Scaled/Views/`

**Responsibilities**
- Present data, manage local UI state, and coordinate user interactions using SwiftUI composition.
- Observe `@Observable` models with `@Bindable`, using property wrappers like `@State`/`@Binding` thoughtfully.
- Compose complex views from small, reusable components and custom modifiers.

**Key Practices**
- Keep screens focused (~150 lines); extract subsections into reusable views.
- Drive UI from models/services, formatting results via helper views or modifiers.
- Maintain accessibility (Dynamic Type, VoiceOver) and provide polished animations, loading, and error states to satisfy SLC.
- Leverage previews to demonstrate baseline, high-hydration, and enriched dough scenarios.

**Anti-Patterns to Avoid**
- Embedding business logic, networking, or persistence in views.
- Deeply nested hierarchies or unnecessary UIKit bridges.
- Ignoring accessibility, warning presentation, or state restoration.

**Testing Expectations**
- Cover views with snapshot tests, UI automation, and diverse preview states.
- Validate hydration badges, warning banners, and other reusable modifiers.

## Models Agent – Domain Data
**Scope**: `Scaled/Models/`

**Responsibilities**
- Define clean domain structures (Recipe, Formula, Preferment, Soaker, FinalMix, etc.).
- Use value types for immutable components and `@Observable` reference types where shared mutation is required.
- Provide computed baker's math properties (hydration, salt %, prefermented flour) while keeping business logic external.

**Key Practices**
- Conform to `Codable`, preserving identifiers during decoding.
- Document invariants (e.g., prefermented flour counts toward total flour; soaker grains do not).
- Organize models by feature directories as the app grows.

**Anti-Patterns to Avoid**
- Embedding parsing, validation, scaling, or persistence logic inside models.
- Including UI-specific formatting or unrelated concerns in a single type.

**Testing Expectations**
- Unit test initialization, Codable round-trips, computed metrics, and invariants/validation helpers.

## Services Agent – Business Logic
**Scope**: `Scaled/Services/`

**Responsibilities**
- Implement parsing, calculation, scaling, persistence, and integration services that orchestrate baker's math.
- Provide clear APIs with protocol-oriented design for easy mocking and composition.
- Handle errors, retries, caching, and async work professionally.

**Key Practices**
- Keep services single-purpose (Parsing, Calculation, Scaling, Persistence) and inject collaborators.
- Return value types or DTOs that views/models consume directly.
- Use async/await for I/O, ensure thread safety, and avoid circular dependencies.

**Anti-Patterns to Avoid**
- Monolithic “Manager” classes or storing UI state in services.
- Mixing disparate concerns or returning raw network payloads.

**Testing Expectations**
- Create robust unit tests with mocks, covering happy paths, edge cases, error handling, and async flows.
- Example: validate hydration warnings using configurable thresholds.

## Utilities Agent – Shared Helpers
**Scope**: `Scaled/Utilities/`

**Responsibilities**
- Provide reusable extensions, helpers, constants, algorithms, and custom view modifiers.
- Keep utilities pure, performant, and thoroughly tested before adoption.

**Key Practices**
- Organize extensions by the type they extend (`Double+BakersMath.swift`, `Array+FlourType.swift`, etc.).
- Supply deterministic formatting helpers, baker's math calculations, and reusable view modifiers (hydration badges, validation banners).
- Group helpers by concept (baker's math, formatting, validation, batch planning) and document bakery-specific rules.

**Anti-Patterns to Avoid**
- “Utils” grab bags with unrelated logic, duplication of model/service functionality, or reliance on global mutable state.

**Testing Expectations**
- Cover edge cases (zero flour, extreme hydration, rounding precision) with unit tests and fixture factories for reuse across suites.

# Notes
- All CLAUDE.md files now reside in `/archive` for historical reference.
- Update documentation in `docs/`—especially `LEARNINGS.md`, `PRD.md`, and `ROADMAP.md`—as features evolve.
- Maintain production-readiness: polished UX, comprehensive tests, and clear knowledge sharing are mandatory deliverables.
