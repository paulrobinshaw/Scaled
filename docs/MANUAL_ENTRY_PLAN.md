# Manual Recipe Entry Flow Implementation Plan

This plan turns the manual recipe entry experience from concept into a production-ready feature that meets the PRD promise of capturing a formula in under 60 seconds while keeping the workflow delightful and accurate.

## 1. Product Goals & Success Metrics
- **Speed**: Expert users can enter a new bread formula in < 60 seconds once ingredient data is known.
- **Accuracy**: Inline validation ensures baker's math never drifts (hydration, salt %, prefermented flour caps).
- **Delight**: Haptic cues, low-friction navigation, and quick actions make the workflow feel crafted for professionals.
- **Reliability**: Drafts autosave locally and recover after an app relaunch without data loss.

### Key Metrics to Track
- Median time from "New Formula" tap to save/scale.
- Number of validation blocks per session.
- Autosave recovery success rate.

## 2. Architecture Overview
1. **Models (`@Observable`)**
   - `FormulaDraft`: Working copy of a formula during entry, references preferments, soakers, final mix arrays.
   - `IngredientDraft`: Lightweight draft rows with id, name, quantity, unit, ingredient role (flour, water, salt, etc.).
   - `EntryFocus`: Enum shared through `@Observable` model to coordinate focused field state.
2. **Services**
   - `FormulaDraftStore`: Persists drafts via JSON in `FileManager` with background autosave every 3 seconds.
   - `IngredientParserService`: Handles paste/import of multi-line ingredient text and converts to draft rows.
   - `ValidationService`: Provides async validation summary (hydration, salt %, prefermented flour) with thresholds from `CALCULATIONS.md`.
   - `MetricsService`: Computes running totals for sticky header dashboard.
3. **Views**
   - `ManualEntryScreen`: `NavigationStack` root with segmented sections (Metadata, Preferments, Final Mix, Summary).
   - `IngredientSectionView`: Hosts `ForEach` of `IngredientRow`, supports reorder/delete.
   - `IngredientRow`: Focus-aware row with custom keypad toolbar and typeahead suggestions.
   - `StickyMetricsBar`: Shows hydration, total dough weight, prefermented flour %.
   - `ValidationBanner`: Inline card summarizing blocking vs warning issues.
4. **Utilities**
   - `Haptics+Feedback`: Wrapper to trigger `.sensoryFeedback` on success/error.
   - `KeyboardShortcut+Accessory`: Configures toolbar numeric pad, plus quick actions (×2, ÷2, %, g → %).

## 3. Detailed Implementation Steps
### 3.1 Draft Data Model
- Create `FormulaDraft` with nested arrays of `IngredientDraft` grouped by section.
- Support computed baker's math metrics through `MetricsService` injection.
- Provide `mutating` helpers for reorder/duplicate ingredients and quick scaling actions per row.

### 3.2 Entry Screen Composition
- Use `NavigationStack` containing `ScrollView` + `LazyVStack` for performance.
- Break sections into cards with headers (metadata form, preferments list, final mix list).
- Keep `StickyMetricsBar` anchored via `.safeAreaInset(edge: .top)`.

### 3.3 Focus & Keyboard Management
- Introduce `@FocusState private var focusedField: EntryFocus.Field?` in `ManualEntryScreen`.
- Propagate bindings into each `IngredientRow` using `@Binding<EntryFocus.Field?>`.
- Configure `.toolbar` with custom numeric keypad (0-9, decimal, backspace, quick scaling).
- Provide gestures: swipe right to duplicate row, swipe left to delete.

### 3.4 Rapid Row Creation
- Add "Add ingredient" button pinned under each section with `keyboardShortcut(.return, modifiers: [.command])`.
- Implement paste-to-parse: when user pastes multi-line text, route to `IngredientParserService` preview sheet allowing accept/edit.
- Support defaulting ingredient role based on heuristics ("flour", "water", "salt").

### 3.5 Validation & Feedback
- Run validation on a debounce (`.onChange` with 250ms delay) to avoid UI jank.
- Show inline highlight + haptic on validation severity transitions.
- Block saving only on critical issues (missing flour weight, negative values).

### 3.6 Autosave & Persistence
- Persist draft snapshots whenever the user pauses for >500ms and when app moves to background.
- Provide recovery UI on launch: "Resume last draft" card using `ManualEntryScreen` initializer.
- Include unit tests for serialization/deserialization of `FormulaDraft`.

### 3.7 Completion & Scaling Handoff
- "Review & Scale" button in summary section pushes to existing scaling workflow with computed formula.
- Ensure transformation from `FormulaDraft` to production `Formula` is covered by service-level tests.

## 4. Testing Strategy
- **Unit Tests**: `FormulaDraftTests`, `IngredientParserServiceTests`, `ValidationServiceTests`, `FormulaDraftStoreTests`.
- **Snapshot Tests**: Layout snapshots for Ingredient rows in light/dark, validation banners, sticky metrics.
- **UI Tests**: Automate 60-second entry flow, paste-to-parse acceptance, autosave recovery.
- **Performance Tests**: Measure metrics recompute latency under 100ms for 50 ingredients.

## 5. Rollout Plan
1. Implement data models & services with unit tests (Iteration 1).
2. Build Manual Entry UI without advanced gestures, ensure baseline flow (Iteration 2).
3. Layer in custom keypad, haptics, gestures, paste parsing (Iteration 3).
4. Polish + snapshot/UI tests, add analytics instrumentation (Iteration 4).
5. Conduct internal dogfood with pro bakers, capture feedback before public release.

## 6. Risks & Mitigations
- **State Synchronization Bugs**: Rely on `@Observable` and limit direct mutation to helper methods; cover with tests.
- **Keyboard Lag**: Keep validation/metrics async and throttled, precompute formatters.
- **Parsing Accuracy**: Provide preview confirmation and easy manual override.
- **Autosave Data Loss**: Write to background queue with file atomicity, unit test crash recovery path.

## 7. Open Questions
- Do we need iCloud sync for drafts or is on-device persistence sufficient for phase 1?
- Should validation rules be configurable per bakery (enterprise requirement)?
- What telemetry SDK will capture timing metrics without impacting performance?

