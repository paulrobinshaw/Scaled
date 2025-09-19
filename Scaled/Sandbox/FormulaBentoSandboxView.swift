import Observation
import SwiftUI

/// Experimental bento-style dashboard for formula editing/scaling.
/// Lives inside `Scaled/Sandbox` so we can iterate freely before
/// integrating with production flows.
struct FormulaBentoSandboxView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Bindable var formula: Formula
  @State private var scaleMultiplier: Double = 1.0
  @Namespace private var animationNamespace
  @State private var totalFormulaSelections: [UUID: SelectionOverride] = [:]

  private let calculationService = FormulaCalculationService()
  private let validationService = FormulaValidationService()

  private var bakersTable: BakersPercentageTable {
    calculationService.calculateBakersPercentages(for: formula)
  }

  private var warnings: [ValidationWarning] {
    validationService.validate(formula: formula)
  }

  private var gridColumns: [GridItem] {
    if horizontalSizeClass == .compact {
      return [GridItem(.flexible(), spacing: 16, alignment: .top)]
    } else {
      return [GridItem(.adaptive(minimum: 220, maximum: 320), spacing: 16, alignment: .top)]
    }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        FormulaHeaderTile(
          formula: formula, warnings: warnings, hydration: hydrationRollup.hydration)

        LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 12) {
          TotalFormulaTile(rows: bakersTable.totalFormula, selections: $totalFormulaSelections)
            .matchedGeometryEffect(id: "total", in: animationNamespace)

          if horizontalSizeClass == .compact {
            PrefermentsTile(preferments: formula.preferments)
              .matchedGeometryEffect(id: "pref", in: animationNamespace)
            SoakerTile(soakers: formula.soakers)
              .matchedGeometryEffect(id: "soaker", in: animationNamespace)
          } else {
            HStack(alignment: .top, spacing: 14) {
              PrefermentsTile(preferments: formula.preferments)
              SoakerTile(soakers: formula.soakers)
            }
            .frame(maxWidth: .infinity)
            .matchedGeometryEffect(id: "prefSoakerRow", in: animationNamespace)
          }

          FinalMixTile(rows: bakersTable.finalMix)
            .matchedGeometryEffect(id: "final", in: animationNamespace)
          NotesTile(notes: formula.notes)
            .matchedGeometryEffect(id: "notes", in: animationNamespace)
        }

        ScalingTile(scale: $scaleMultiplier, formula: formula)
          .matchedGeometryEffect(id: "scaling", in: animationNamespace)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 20)
    }
    .background(Color(.systemGroupedBackground))
    .navigationTitle("Formula Sandbox")
    .navigationBarTitleDisplayMode(.inline)
    .task(id: bakersTable.totalFormula.map { "\($0.ingredient)|\($0.category)" }) {
      syncSelectionsToRows(bakersTable.totalFormula)
    }
  }

  private var hydrationRollup: HydrationRollup {
    let rows = bakersTable.totalFormula
    var flourTotal = 0.0
    var waterTotal = 0.0

    for row in rows {
      let baseline = SelectionOverride(row: row)
      let selection = totalFormulaSelections[row.id] ?? baseline
      if selection.flour { flourTotal += row.weight }
      if selection.water { waterTotal += row.weight }
    }

    let hydration = flourTotal > 0 ? (waterTotal / flourTotal) * 100 : 0
    return HydrationRollup(flour: flourTotal, water: waterTotal, hydration: hydration)
  }

  private func syncSelectionsToRows(_ rows: [PercentageRow]) {
    var updated: [UUID: SelectionOverride] = [:]
    for row in rows {
      let existing = totalFormulaSelections[row.id] ?? SelectionOverride(row: row)
      updated[row.id] = existing.sanitized()
    }
    totalFormulaSelections = updated
  }
}

// MARK: - Tiles

private struct FormulaHeaderTile: View {
  let formula: Formula
  let warnings: [ValidationWarning]
  let hydration: Double

  var body: some View {
    BentoCard(title: "Formula", icon: "bread.slice", style: .primary) {
      VStack(alignment: .leading, spacing: 12) {
        Text(formula.name.isEmpty ? "Untitled Formula" : formula.name)
          .font(.title3).bold()

        HStack(spacing: 12) {
          MetricChip(label: "Hydration", value: Self.percentString(hydration), accent: .teal)
          MetricChip(label: "Yield", value: "\(Int(formula.totalWeight)) g", accent: .orange)
          MetricChip(
            label: "Prefermented", value: Self.percentString(formula.prefermentedFlourPercentage),
            accent: .purple)
        }

        if !warnings.isEmpty {
          VStack(alignment: .leading, spacing: 8) {
            Text("Checks")
              .font(.caption)
              .foregroundColor(Color.white.opacity(0.8))

            ForEach(warnings.prefix(2)) { warning in
              WarningRow(warning: warning, prefersLightText: true)
            }

            if warnings.count > 2 {
              Text("+\(warnings.count - 2) more issues")
                .font(.footnote)
                .foregroundColor(Color.white.opacity(0.75))
            }
          }
        }
      }
    }
  }

  private static func percentString(_ value: Double) -> String {
    "\(Int(round(value)))%"
  }
}

private struct ScalingTile: View {
  @Binding var scale: Double
  let formula: Formula

  private let scalingService = FormulaScalingService()

  private var scaledFormula: Formula {
    scalingService.scaleByYield(
      formula: formula,
      pieces: formula.yield.pieces,
      weightPerPiece: formula.yield.weightPerPiece * scale
    )
  }

  var body: some View {
    BentoCard(title: "Scaling", icon: "ruler", style: .accent) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Scale factor: \(scale, format: .number.precision(.fractionLength(2)))")
          .font(.subheadline)

        Slider(value: $scale, in: 0.25...4.0, step: 0.05)
          .accentColor(.indigo)
          .animation(.spring(response: 0.5, dampingFraction: 0.85), value: scale)

        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Current batch")
              .font(.caption).foregroundColor(.secondary)
            Text("\(Int(formula.totalWeight)) g")
              .font(.headline)
          }
          Spacer()
          VStack(alignment: .leading, spacing: 4) {
            Text("Scaled batch")
              .font(.caption).foregroundColor(.secondary)
            Text("\(Int(scaledFormula.totalWeight)) g")
              .font(.headline)
          }
        }
      }
    }
  }
}

private struct TotalFormulaTile: View {
  let rows: [PercentageRow]
  @Binding var selections: [UUID: SelectionOverride]

  var body: some View {
    BentoCard(title: "Total Formula", icon: "tablecells", style: .neutral) {
      let totalPercentage = rows.reduce(0) { $0 + $1.percentage }
      let totalWeight = rows.reduce(0) { $0 + $1.weight }
      let rowFont = Font.system(size: 15, weight: .medium, design: .default)
      let valueFont = Font.system(size: 15, weight: .semibold, design: .default)
      let flourContribution = rows.reduce(0.0) { partial, row in
        let baseline = SelectionOverride(row: row)
        let selection = selections[row.id] ?? baseline
        return selection.flour ? partial + row.weight : partial
      }
      let waterContribution = rows.reduce(0.0) { partial, row in
        let baseline = SelectionOverride(row: row)
        let selection = selections[row.id] ?? baseline
        return selection.water ? partial + row.weight : partial
      }

      let flourRows = rows.filter { $0.category == "Flour" }
      let waterRows = rows.filter {
        $0.category == "Liquid" || $0.ingredient.lowercased().contains("water")
      }
      let saltRows = rows.filter {
        $0.category == "Salt" || $0.ingredient.lowercased().contains("salt")
      }
      let flourIDs = Set(flourRows.map(\.id))
      let waterIDs = Set(waterRows.map(\.id))
      let saltIDs = Set(saltRows.map(\.id))
      let remainingRows = rows.filter {
        !flourIDs.contains($0.id) && !waterIDs.contains($0.id) && !saltIDs.contains($0.id)
      }
      .sorted { $0.weight > $1.weight }
      let orderedRows = flourRows + waterRows + saltRows + remainingRows

      return VStack(spacing: 6) {
        headerRow
        ForEach(Array(orderedRows.enumerated()), id: \.element.id) { index, row in
          let baseline = SelectionOverride(row: row)
          let selection = selections[row.id] ?? baseline
          HStack {
            Text(row.ingredient)
              .font(rowFont)
            Spacer()
          GridToggleButton(
            systemName: "leaf.fill", tint: .orange, isOn: selection.flour,
            accessibilityLabel: "Include \(row.ingredient) in total flour"
          ) {
            var updated = selection
            updated.flour.toggle()
            if updated.flour { updated.water = false }
            updated = updated.sanitized()
            selections[row.id] = updated
          }
          .frame(width: 34)
          GridToggleButton(
            systemName: "drop.fill", tint: .blue, isOn: selection.water,
            accessibilityLabel: "Include \(row.ingredient) in total water"
          ) {
            var updated = selection
            updated.water.toggle()
            if updated.water { updated.flour = false }
            updated = updated.sanitized()
            selections[row.id] = updated
          }
            .frame(width: 34)
            Text(String(format: "%.1f%%", row.percentage))
              .font(valueFont)
              .frame(width: 74, alignment: .trailing)
              .lineLimit(1)
            Text("\(Int(row.weight)) g")
              .foregroundColor(.secondary)
              .font(valueFont)
              .frame(width: 76, alignment: .trailing)
              .lineLimit(1)
          }
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(
            (index.isMultiple(of: 2) ? Color(.secondarySystemFill) : Color(.tertiarySystemFill))
              .opacity(0.75)
          )
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }

        Divider()

        HStack {
          Text("Total")
            .font(Font.system(size: 16, weight: .semibold, design: .default))
          Spacer()
          Color.clear.frame(width: 34, height: 1)
          Color.clear.frame(width: 34, height: 1)
          Text(String(format: "%.1f%%", totalPercentage))
            .font(Font.system(size: 16, weight: .semibold, design: .default))
            .frame(width: 70, alignment: .trailing)
            .lineLimit(1)
          Text("\(Int(totalWeight)) g")
            .foregroundStyle(.primary)
            .font(Font.system(size: 16, weight: .semibold, design: .default))
            .frame(width: 76, alignment: .trailing)
            .lineLimit(1)
        }

        HStack(spacing: 16) {
          HStack(spacing: 6) {
            Image(systemName: "leaf.fill")
              .foregroundColor(.orange.opacity(0.85))
            Text("\(Int(flourContribution)) g flour")
          }
          HStack(spacing: 6) {
            Image(systemName: "drop.fill")
              .foregroundColor(.blue.opacity(0.85))
            Text("\(Int(waterContribution)) g water")
          }
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.top, 4)
      }
    }
    .onAppear(perform: syncSelections)
    .onChange(of: rows.map { "\($0.ingredient)|\($0.category)" }) { _ in
      syncSelections()
    }
  }

  private var headerRow: some View {
    HStack {
      Text("Ingredient")
        .font(.caption)
        .foregroundColor(.secondary)
      Spacer()
      Image(systemName: "leaf.fill")
        .font(.caption)
        .foregroundColor(.orange.opacity(0.8))
        .frame(width: 34)
      Image(systemName: "drop.fill")
        .font(.caption)
        .foregroundColor(.blue.opacity(0.8))
        .frame(width: 34)
      Text("%")
        .font(.caption)
        .foregroundColor(.secondary)
        .frame(width: 70, alignment: .trailing)
      Text("g")
        .font(.caption)
        .foregroundColor(.secondary)
        .frame(width: 76, alignment: .trailing)
    }
    .padding(.horizontal, 10)
  }

  private func syncSelections() {
    var refreshed: [UUID: SelectionOverride] = [:]
    for row in rows {
      let existing = selections[row.id] ?? SelectionOverride(row: row)
      refreshed[row.id] = existing.sanitized()
    }
    selections = refreshed
  }
}

private struct PrefermentsTile: View {
  let preferments: [Preferment]

  var body: some View {
    BentoCard(title: "Preferments", icon: "sparkles", style: .wheat) {
      if preferments.isEmpty {
        Text("No preferments configured")
          .foregroundColor(Color.white.opacity(0.75))
      } else {
        VStack(alignment: .leading, spacing: 12) {
          ForEach(preferments) { preferment in
            VStack(alignment: .leading, spacing: 4) {
              Text(preferment.name.isEmpty ? "Untitled Preferment" : preferment.name)
                .font(.subheadline).bold()
              HStack(spacing: 12) {
                MetricChip(
                  label: "Hydration", value: percentString(preferment.hydration), accent: .orange)
                MetricChip(
                  label: "Flour", value: "\(Int(preferment.flourWeight)) g", accent: .brown)
                MetricChip(label: "Water", value: "\(Int(preferment.waterWeight)) g", accent: .teal)
              }
            }
          }
        }
      }
    }
  }

  private func percentString(_ value: Double) -> String {
    "\(Int(round(value)))%"
  }
}

private struct FinalMixTile: View {
  let rows: [PercentageRow]

  var body: some View {
    BentoCard(title: "Final Mix", icon: "drop.circle", style: .sky) {
      if rows.isEmpty {
        Text("No final mix ingredients yet")
          .foregroundColor(Color.white.opacity(0.75))
      } else {
        VStack(spacing: 8) {
          ForEach(rows) { row in
            HStack {
              Text(row.ingredient)
              Spacer()
              Text("\(Int(row.weight)) g")
                .foregroundColor(.secondary)
            }
            .font(.subheadline)
          }
        }
      }
    }
  }
}

private struct SoakerTile: View {
  let soakers: [Soaker]

  var body: some View {
    BentoCard(title: "Soakers", icon: "leaf", style: .minty) {
      if soakers.isEmpty {
        Text("No soakers added")
          .foregroundColor(Color.white.opacity(0.75))
      } else {
        VStack(alignment: .leading, spacing: 12) {
          ForEach(soakers) { soaker in
            VStack(alignment: .leading, spacing: 4) {
              Text(soaker.name.isEmpty ? "Untitled Soaker" : soaker.name)
                .font(.subheadline).bold()
              MetricChip(label: "Water", value: "\(Int(soaker.water)) g", accent: .blue)
            }
          }
        }
      }
    }
  }
}

private struct NotesTile: View {
  let notes: String

  var body: some View {
    BentoCard(title: "Notes", icon: "note.text", style: .neutral) {
      if notes.isEmpty {
        Text("Add mix, fermentation, or bake notes to keep context handy.")
          .foregroundColor(.secondary)
      } else {
        Text(notes)
          .font(.body)
          .foregroundColor(.primary)
      }
    }
  }
}

// MARK: - Shared Components

private struct BentoCard<Content: View>: View {
  let title: String
  let icon: String
  var style: BentoCardStyle = .neutral
  @ViewBuilder var content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Label(title, systemImage: icon)
        .font(.headline)
        .labelStyle(.titleAndIcon)
        .foregroundStyle(style.labelColor)
      content
    }
    .foregroundStyle(style.contentColor)
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(style.gradient)
        .overlay(
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(style.strokeColor, lineWidth: 1)
        )
        .shadow(color: style.shadowColor, radius: 12, y: 6)
    )
    .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    .transition(.move(edge: .bottom).combined(with: .opacity))
  }
}

private enum BentoCardStyle {
  case primary
  case neutral
  case accent
  case sky
  case wheat
  case minty

  var gradient: LinearGradient {
    switch self {
    case .primary:
      return LinearGradient(
        colors: [Color.pink.opacity(0.35), Color.orange.opacity(0.18)], startPoint: .topLeading,
        endPoint: .bottomTrailing)
    case .neutral:
      return LinearGradient(
        colors: [Color(.secondarySystemBackground), Color(.systemBackground)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    case .accent:
      return LinearGradient(
        colors: [Color.indigo.opacity(0.35), Color.blue.opacity(0.18)], startPoint: .topLeading,
        endPoint: .bottomTrailing)
    case .sky:
      return LinearGradient(
        colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.16)], startPoint: .topLeading,
        endPoint: .bottomTrailing)
    case .wheat:
      return LinearGradient(
        colors: [Color.yellow.opacity(0.32), Color.orange.opacity(0.14)], startPoint: .topLeading,
        endPoint: .bottomTrailing)
    case .minty:
      return LinearGradient(
        colors: [Color.green.opacity(0.28), Color.mint.opacity(0.14)], startPoint: .topLeading,
        endPoint: .bottomTrailing)
    }
  }

  var strokeColor: Color {
    switch self {
    case .neutral: return Color.white.opacity(0.35)
    default: return Color.white.opacity(0.45)
    }
  }

  var shadowColor: Color {
    switch self {
    case .neutral: return Color.black.opacity(0.05)
    default: return Color.black.opacity(0.12)
    }
  }

  var labelColor: Color {
    switch self {
    case .neutral: return .primary
    default: return Color.white
    }
  }

  var contentColor: Color {
    switch self {
    case .neutral: return .primary
    default: return Color.white.opacity(0.95)
    }
  }
}

private struct MetricChip: View {
  let label: String
  let value: String
  var accent: Color = .accentColor

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(label.uppercased())
        .font(.caption2)
        .foregroundColor(accent.opacity(0.7))
      Text(value)
        .font(.footnote)
        .bold()
        .foregroundColor(accent)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(accent.opacity(0.15))
    )
    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
  }
}

private struct WarningRow: View {
  let warning: ValidationWarning
  var prefersLightText: Bool = false

  var body: some View {
    HStack(alignment: .top, spacing: 8) {
      Image(
        systemName: warning.level == .error ? "exclamationmark.octagon.fill" : "info.circle.fill"
      )
      .foregroundColor(warning.level == .error ? .red : .orange)
      .font(.body)
      VStack(alignment: .leading, spacing: 2) {
        Text(warning.category)
          .font(.caption)
          .foregroundColor(prefersLightText ? Color.white.opacity(0.65) : .secondary)
        Text(warning.message)
          .font(.footnote)
          .foregroundColor(prefersLightText ? Color.white : .primary)
      }
    }
  }
}

private struct GridToggleButton: View {
  let systemName: String
  let tint: Color
  let isOn: Bool
  let accessibilityLabel: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: systemName)
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(isOn ? tint : Color.secondary.opacity(0.65))
        .frame(width: 28, height: 28)
        .background(
          RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(isOn ? tint.opacity(0.2) : Color(.tertiarySystemFill))
        )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(accessibilityLabel)
    .accessibilityValue(isOn ? "Included" : "Excluded")
  }
}

private struct SelectionOverride: Equatable {
  var flour: Bool
  var water: Bool
}

extension SelectionOverride {
  fileprivate init(row: PercentageRow) {
    let baseline = SelectionOverride(
      flour: row.countsTowardFlour,
      water: row.countsTowardWater
    )
    self = baseline.sanitized()
  }

  fileprivate func sanitized() -> SelectionOverride {
    guard flour && water else { return self }
    // Favour the flour selection when both are set; callers will explicitly
    // toggle the other flag back on if needed.
    return SelectionOverride(flour: true, water: false)
  }
}

private struct HydrationRollup {
  var flour: Double
  var water: Double
  var hydration: Double
}

private struct TotalFormulaTilePreview: View {
  @State private var selections: [UUID: SelectionOverride] = [:]

  var body: some View {
    let rows = SampleFormulaData.makeSampleBakersTable().totalFormula
    return TotalFormulaTile(rows: rows, selections: $selections)
      .frame(maxWidth: 360)
  }
}

// MARK: - Preview

#Preview("Total Formula Tile") {
  TotalFormulaTilePreview()
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Full Sandbox") {
  NavigationStack {
    FormulaBentoSandboxView(formula: SampleFormulaData.makeSampleFormula())
  }
  .preferredColorScheme(.light)
  .frame(maxHeight: 600)
}

private enum SampleFormulaData {
  static func makeSampleFormula() -> Formula {
    let formula = Formula(name: "San Francisco Sourdough")
    formula.notes = "70% hydration, medium salt. Retard overnight for best flavor."
    formula.yield = FormulaYield(pieces: 2, weightPerPiece: 900)

    let levain = Preferment(name: "Levain", type: .levain)
    levain.flourWeight = 200
    levain.waterWeight = 200
    levain.yeast = nil

    formula.preferments = [levain]

    let soaker = Soaker(name: "Seed Soaker")
    soaker.water = 80
    soaker.salt = 0
    formula.soakers = [soaker]

    formula.finalMix.flours.addFlour(type: .bread, weight: 700)
    formula.finalMix.flours.addFlour(type: .wholeWheat, weight: 100)
    formula.finalMix.water = 420
    formula.finalMix.salt = 18
    formula.finalMix.inclusions = [
      Inclusion(name: "Toasted Seeds", weight: 60, additionStage: .mixing)
    ]

    return formula
  }

  static func makeSampleBakersTable() -> BakersPercentageTable {
    var table = BakersPercentageTable()
    table.totalFormula = [
      PercentageRow(
        ingredient: "Bread Flour", weight: 700, percentage: 70, category: "Flour",
        countsTowardFlour: true
      ),
      PercentageRow(
        ingredient: "Whole Wheat", weight: 100, percentage: 10, category: "Flour",
        countsTowardFlour: true
      ),
      PercentageRow(
        ingredient: "Levain Flour", weight: 200, percentage: 20, category: "Flour",
        countsTowardFlour: true
      ),
      PercentageRow(
        ingredient: "Water", weight: 700, percentage: 70, category: "Liquid",
        countsTowardWater: true
      ),
      PercentageRow(ingredient: "Salt", weight: 18, percentage: 1.8, category: "Salt"),
      PercentageRow(ingredient: "Levain", weight: 400, percentage: 40, category: "Preferment"),
      PercentageRow(ingredient: "Seed Soaker", weight: 80, percentage: 8, category: "Soaker"),
      PercentageRow(ingredient: "Toasted Seeds", weight: 60, percentage: 6, category: "Inclusion"),
    ]
    return table
  }
}
