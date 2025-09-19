# Scaled - Product Requirements Document (PRD)
*Version 0.2 | Date: September 18, 2025*

## Executive Summary

**Product Name:** Scaled
**Platform:** iOS (SwiftUI)
**Target Release:** V1.0 Q3 2025

**One-Line Vision:** Give every baker a fast, reliable co-pilot that turns any rough recipe into a ready-to-bake plan in seconds.

**The Problem:** Bakers waste hours figuring out what to mix. Recipes can be on scraps of paper, spreadsheets, whiteboards or even someone's head.

**The Solution:** Combine quick capture tools, rock-solid baker's math, and clear production checklists so bakers can plan, double-check, and run batches with confidence on a single device.

---

## Core SLC (Simple Lovable Complete)

**Core interface should be delightful**

### The 60-Second Experience
1. Chooses: Template recipe OR manual entry (photo assist optional)
2. Baker enters: "I need 200 loaves at 900g each"
3. Gets: Complete ingredient recipe with exact weights
4. Can scale by ANY ingredient: flour amount, available preferment, or total yield

### Success Metric
**Core Goal:** Baker goes from "I got an order" to "Here's exactly what I need to weigh" in under 60 seconds with 100% confidence in the math.

---

## Where We're Heading (2026+)

- **Smarter batch advice:** Learn from past bakes (with permission) to suggest hydration, timing, and mix adjustments before a mistake happens.
- **Shift planning:** Help head bakers line up ovens, teams, and handoffs across multiple locations.
- **Shared playbook:** Build a growing library of baking know-how that spots unusual numbers and recommends fixes.
- **Connected tools:** Talk to pro scales, proofers, and inventory systems so the plan on screen matches what happens in the kitchen.

These goals keep the "Simple, Lovable, Complete" foundation but point the product at the bigger operations problems bakeries want solved next.

---

## Target Users

### Primary Users
- **Home Bakers** (Serious hobbyists who want professional results)
- **Micro Bakeries** (Just 1 baker usually)
- **Professional Bakeries** (Just 1 user using Scaled in a larger bakery - usually the baker mixing)

### User Pain Points
✅ *Validated with baker interviews*
- "I waste so much time converting recipes"
- "My scaling always goes wrong"
- "I can't figure out baker's percentages"
- "It's 3am, I'm tired, and I just need the math to work"

### User Response to Concept
✅ *Validation confirmed*: "I would definitely use this"

### Key User Insights
- Bakers already use spreadsheets but find them cumbersome on phones
- Most scaling happens at 3-5am when cognitive load should be minimal
- Paper printouts are still king in professional kitchens
- Trust in calculations is paramount - one bad batch costs hundreds

---

## Core Features (V1.0)

### Must Have (P0)

#### 1. Smart Recipe Input
- **Templates:** 5 core bread templates everyone makes (Basic Sourdough, Baguette, Focaccia, White Bread, Whole Wheat)
- **Manual Entry:** Primary input method - fast, reliable, works offline
- **Photo Capture:** Secondary "magic" feature - AI assists but doesn't replace manual
- **Quick Scaling:** "200 loaves × 900g" interface for instant scaling
- **Recipe Saving/Library:** Store validated formulas for reuse
- **Trust Panel:** Show the math behind each ingredient, flag odd numbers, and let bakers compare "what if" tweaks before they mix

#### 2. Rock-Solid Scaling Engine
- **Preferment Calculator First:** Build robust preferment math as foundation
- **Scale by Any Ingredient:** Enter available flour/preferment/any ingredient → calculate everything else
- **Scale by Yield:** Enter loaf count + weight or just total yield needed → calculate everything else
- **Baker's Percentages:** All calculations use proper baker's percentage ratios
- **Multi-Flour Handling:** Primary flour = 100%, others calculated proportionally
- **Preferment Integration:** Handle poolish, levain, biga, pate fermentee, sponge with proper hydration calculations
- **Reverse Engineering:** "I made this batch, what's the formula?"

#### 3. Production Output
- **Recipe with Summary:** Exact ingredient weights + overall hydration % + % prefermented flour
- **Formula Sheet:** Clean baker's percentages for production
- **PDF Export:** Print-ready format for kitchen use
- **Unit Flexibility:** Toggle between metric/imperial (but never mix in calculations!)
- **Rounding Options:** Professional (1g precision) vs Home (5g precision)
- **Error Checking:** Warn for unusual hydration/ratios

### Should Have (P1) - V1.1
- **Mistake Recovery Calculator:** "I added 10kg water instead of 6.5kg, how much flour to add?"
- **Timer Integration:** Basic fermentation timers
- **Temperature Adjustments:** Adjust timing based on dough/room temperature
- **Batch History:** Track what was made when
- **What-If Planning:** Try different yields, hydrations, or preferment ratios and see updated weights instantly
- **Environment Tips:** Suggest salt, water, or timing adjustments based on flour notes, room temperature, or starter strength

### Nice to Have (P2) - Future Versions
- Production scheduling
- Team collaboration (CloudKit sharing)
- Cost calculations
- Inventory management
- Multiple preferment support in single recipe
- Sourdough starter feeding calculator
- Demand forecasts and production scheduling
- Integrations with connected scales, proofers, and mixers

---

## Technical Requirements

### Platform
- **iOS Only:** SwiftUI native app
- **Minimum iOS Version:** iOS 16+
- **Storage:** Local storage initially (Core Data)
- **AI Integration:** OpenAI Vision API for photo recipe extraction (optional feature)
- **Future-friendly code:** Structure modules so they can ship on macOS or visionOS later without major rewrites

### Performance Requirements
- Photo processing: < 10 seconds (when online)
- Scaling calculations: Instant (<100ms)
- App launch: < 2 seconds
- Offline capable: ALL core calculations work without internet
- Photo feature degrades gracefully when offline

### Data Architecture

```swift
// Core Models
@Observable class Recipe {
    var name: String
    var ingredients: [Ingredient]
    var preferments: [Preferment]
    var totalFlourWeight: Double // Sum of all flours for percentage base
    var calculatedHydration: Double // Auto-calculated
    var prefermentedFlourPercentage: Double // Auto-calculated
}

@Observable class Ingredient {
    var name: String
    var weight: Double
    var bakerPercentage: Double? // Relative to total flour
    var isFlour: Bool // Affects percentage calculations
    var flourType: FlourType? // bread, rye, whole wheat, etc.
}

@Observable class Preferment {
    var type: PrefermentType // poolish, levain, biga, etc.
    var flour: Double
    var water: Double
    var starter: Double? // For sourdough
    var yeast: Double? // For commercial yeast preferments
    var hydrationPercentage: Double // Auto-calculated
}

enum FlourType {
    case bread, allPurpose, wholeWheat, rye, spelt
    var proteinContent: Double // Affects hydration recommendations
}

enum PrefermentType {
    case poolish, levain, biga, sponge, pateFermentee
    var typicalHydration: ClosedRange<Double> // For validation
}
```

### Learning From Real Batches

- **Optional feedback loop:** With baker opt-in, log how batches turned out (hydration, timing, fixes) in a privacy-safe way.
- **Helpful suggestions:** Use that history plus flour details to recommend better hydrations, salt levels, or timelines for similar doughs.
- **Always explain:** Every suggestion must show why we recommended it and how confident we are, so bakers can trust or dismiss it quickly.

### Critical Edge Cases & Solutions

1. **Multiple Flours:** Sum all flours for 100% base, show individual percentages
2. **No Flour Recipes:** Disable percentage view, show weights only
3. **Metric/Imperial:** Store internally in grams, convert on display only
4. **Rounding:** Always round at final display, never in calculations
5. **Preferment Overlap:** Flour in preferment counts toward total flour
6. **High Hydration:** Warn above 85% but allow (artisan breads need it)

---

## Pricing Strategy

### Recommended Approach: One-Time Purchase
- **Price:** $29.99 lifetime access
- **Rationale:**
  - Bakers have subscription fatigue
  - Sustainable without ongoing API costs if photo feature is limited
  - Premium pricing reflects professional tool value
  - Similar to buying a good kitchen scale

### Alternative: Freemium
- **Free:** 3 saved recipes, manual entry only
- **Paid ($29.99):** Unlimited recipes, photo extraction, PDF export
- **Photo Limits:** 10 free photo extractions, then $0.99 per 10 photos

### Not Recommended: Subscription
- Monthly subscriptions create friction for occasional users
- API costs can be managed through usage limits
- One-time purchase builds trust

---

## Success Metrics

### V1.0 Launch Targets
- **User Validation:** 90%+ of users complete full recipe → scaling flow
- **Calculation Trust:** Zero reported calculation errors in first month
- **Photo Accuracy:** 70%+ accuracy (it's a bonus feature, not core)
- **Retention:** 60%+ of users return within 7 days
- **App Store:** 4.5+ star rating (quality over quantity)
- **Plan speed:** Median time from capture to final formula under 45 seconds
- **Advice value:** At least half of the bakers who see a warning or suggestion say it helped them fix an issue

### Business Metrics
- **Break-even:** 500 users at $29.99 = $15,000 (covers development)
- **Success:** 2,000 users in year one
- **API Costs:** Keep under $1 per user lifetime (limit photo usage)
- **Expansion:** Sign 10 paying micro-bakeries to pilot the operations features in year one
- **Learning Pool:** Collect anonymized feedback on 5,000 batches to fuel better guidance

---

## Development Strategy

### Phase 0: Vision Warm-Up (Week 0-1)
- Sit down with a handful of bakers, map the "autopilot" moments they want, and agree on the privacy rules for collecting batch feedback.

### Phase 1: Core Engine (Weeks 1-3)
- Lock in the scaling math, preferment handling, and hydration checks with automated tests.
- Set up local storage that can later sync across devices.

### Phase 2: Capture & Templates (Weeks 3-6)
- Ship the manual entry flow with a fast keypad and clear validation.
- Launch the starter set of templates and an AI/photo assist with a simple review screen.

### Phase 3: Production Flow (Weeks 6-9)
- Add the trust panel, production-mode checklist, PDF/print exports, and deeper error messaging.

### Phase 4: Smart Guidance Pilot (Weeks 9-12)
- Turn on the optional batch feedback loop, deliver first-round hydration/timing suggestions, and test them with 10 pilot bakers.

### Phase 5: Launch & Aftercare (Weeks 12-14)
- Prepare App Store assets, support scripts, and training guides.
- Use the pilot feedback and telemetry to plan the next releases.

---

## Risks & Mitigations

### Technical Risks
- **Preferment Math Complexity**
  - *Mitigation:* Build comprehensive test suite first
  - *Mitigation:* Get baker validation on calculations early

- **Photo Extraction Accuracy**
  - *Mitigation:* Position as bonus feature, not core
  - *Mitigation:* Always require user verification

- **API Costs**
  - *Mitigation:* Limit free photo extractions
  - *Mitigation:* Cache common recipe formats
- **Telemetry & Privacy**
  - *Mitigation:* Make batch sharing strictly opt-in with plain-language explanations and on-device scrubbing
  - *Mitigation:* Agree on data-retention rules with pilot bakers before launch

### Market Risks
- **Spreadsheet Competition**
  - *Mitigation:* Mobile-first UX that spreadsheets can't match
  - *Mitigation:* Speed and reliability at 3am

- **iOS Only Limitation**
  - *Mitigation:* Focus on premium market first
  - *Mitigation:* Web version in roadmap for year 2

### User Adoption Risks
- **Trust in Calculations**
  - *Mitigation:* Show work/formulas transparently
  - *Mitigation:* Beta test extensively with professionals

---

## Out of Scope (V1.0)

### Deliberately Excluded
- Multi-user collaboration/sharing
- Production scheduling/timing (beyond basic timers)
- Cost calculations
- Inventory management
- Android version
- Web version
- Recipe discovery/community features
- Nutrition calculations

### Future Considerations
- CloudKit sync for device switching
- Apple Watch app for timers
- Production planning suite
- Wholesale/retail pricing calculator
- Integration with POS systems

---

## Open Questions

1. **Template Selection:** Which 5 breads for initial templates? (Survey bakers)
2. **Rounding Preference:** Should this be user-configurable or fixed?
3. **Photo Feature:** Launch with or wait for V1.1?
4. **Beta Duration:** 2 weeks or 4 weeks of testing?
5. **Launch Market:** Global or US-only initially?
6. **Batch Sharing:** What makes bakers comfortable opting in to share results?
7. **Hardware Partners:** Which scale or proofer makers should we talk to first?

---

## Validation Status

### Completed ✅
- Problem validation with baker interviews
- Core concept validation ("I would definitely use this")
- Technical proof of concept (scaling math works)
- Preferment calculation validation

### In Progress 🔄
- Beta user recruitment (target: 10 bakers)
- Final pricing validation
- Photo accuracy testing with real recipe books

### Needed 📝
- App Store keyword research
- Competition analysis update
- Launch marketing plan

---

## Appendix: Competition Analysis

### Direct Competitors
- **BreadBoss:** Complex, expensive ($100+), Windows only
- **Spreadsheets:** Free but cumbersome on mobile
- **Paper:** Still dominant but error-prone

### Indirect Competitors
- Generic recipe apps (don't understand baker's math)
- Calculator apps (no recipe storage)
- Notes apps (no calculations)

### Our Advantage
- Mobile-first for kitchen use
- Baker's math native
- 60-second experience
- Offline-first reliability

---

*This PRD is a living document and will be updated based on user feedback and development learnings.*

*Last major update: Added pricing strategy, enhanced technical architecture, and incorporated preferment complexity considerations.*
