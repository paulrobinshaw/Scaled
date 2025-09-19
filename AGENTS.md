# Repository Guidelines

## Project Structure & Module Organization
Scaled is a SwiftUI iOS app. Core sources live in `Scaled/`, grouped by intent: `Views/` for SwiftUI screens, `Models/` for recipe and formula data types, `Services/` for parsing, calculations, and scaling, `Utilities/` for shared helpers, and `Assets.xcassets` for design tokens. Entry points `ScaledApp.swift` and `ContentView.swift` wire feature modules. Unit coverage sits in `ScaledTests/` (see `FormulaCalculationServiceTests.swift` and helpers), UI automation in `ScaledUITests/`, and product context inside `docs/`—review the PRD, roadmap, and calculations sheets before major changes.

## Build, Test, and Development Commands
Use Xcode 15+; open the project with `xed Scaled.xcodeproj` for interactive work. CLI builds and tests keep CI parity:
```bash
xcodebuild -project Scaled.xcodeproj -scheme Scaled -destination 'platform=iOS Simulator,name=iPhone 15' build
xcodebuild test -project Scaled.xcodeproj -scheme Scaled -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ScaledTests
xcodebuild test -project Scaled.xcodeproj -scheme Scaled -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ScaledUITests
```
Update the destination device when Apple releases new default simulators.

## Coding Style & Naming Conventions
Follow Swift API design guidance: four-space indentation, soft 120-character lines, trailing commas in multiline collections, and exhaustive `switch` statements. Use UpperCamelCase for types and views (`FormulaCalculationService`), lowerCamelCase for functions and stored properties (`hydrationRatio`). Prefer lightweight SwiftUI views backed by `@Observable` models and dedicated service objects for business logic. Re-indent before committing (`Editor > Structure > Re-Indent`) and keep comments purposeful—explain intent, not syntax.

## Testing Guidelines
Tests rely on XCTest. Mirror production filenames with a `Tests` suffix (e.g., `FormulaValidationServiceTests`) and share fixtures through `FormulaTestHelpers.swift`. Target at least 90% coverage for services touching baker's math, with regression cases for edge ratios (zero flour, high hydration, multi-preferment). Run both unit and UI suites before merging; attach failing scenarios to the PR if a bug fix cannot be reproduced locally.

## Commit & Pull Request Guidelines
Write commits in present tense with concise, descriptive subjects (e.g., `Formula: Handle preferment hydration`). Group related changes and avoid `WIP` commits on shared branches—squash noise locally. Pull requests need: a summary of user impact, references to relevant docs (`docs/PRD.md`, `docs/ROADMAP.md`), updated screenshots for UI touches, and the exact `xcodebuild` test commands you ran. Request reviews early and document open questions inline.

## Agent-Specific Notes
Start with `CLAUDE.md` to align on architecture, testing expectations, and Context7 usage; treat it as your operating manual. Capture new lessons or glossary updates in `docs/LEARNINGS.md` immediately after answering conceptual questions. Keep configuration secrets and provisioning data out of source control—document required environment setup in the PR instead of committing sensitive files.
