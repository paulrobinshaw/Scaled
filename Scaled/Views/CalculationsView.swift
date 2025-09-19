import SwiftUI

struct CalculationsView: View {
    @Bindable var formula: Formula

    private let calculationService = FormulaCalculationService()
    private let validationService = FormulaValidationService()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Summary Card
                summaryCard

                // MARK: - Validation
                if !validationWarnings.isEmpty {
                    validationCard
                }

                // MARK: - Baker's Percentages
                bakersPercentageCard

                // MARK: - Preferment Breakdown
                if !formula.preferments.isEmpty {
                    prefermentBreakdownCard
                }
            }
            .padding()
        }
        .navigationTitle(formula.name.isEmpty ? "Calculations" : formula.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                GridRow {
                    Text("Total Flour:")
                        .foregroundColor(.secondary)
                    Text("\(Int(formula.totalFlour))g")
                        .fontWeight(.semibold)
                }

                GridRow {
                    Text("Total Water:")
                        .foregroundColor(.secondary)
                    Text("\(Int(formula.totalWater))g")
                        .fontWeight(.semibold)
                }

                GridRow {
                    Text("Total Weight:")
                        .foregroundColor(.secondary)
                    Text("\(Int(formula.totalWeight))g")
                        .fontWeight(.semibold)
                }

                Divider()

                GridRow {
                    Text("Hydration:")
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f%%", formula.overallHydration))
                        .fontWeight(.semibold)
                        .foregroundColor(hydrationColor)
                }

                GridRow {
                    Text("Salt:")
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f%%", formula.saltPercentage))
                        .fontWeight(.semibold)
                }

                GridRow {
                    Text("Pre-fermented Flour:")
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f%%", formula.prefermentedFlourPercentage))
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Validation Card
    private var validationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Validation")
                .font(.headline)

            ForEach(validationWarnings) { warning in
                HStack {
                    Text(warning.level.icon)
                    VStack(alignment: .leading) {
                        Text(warning.message)
                            .font(.caption)
                        if let value = warning.value {
                            Text(String(format: "%.1f", value))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Baker's Percentage Card
    private var bakersPercentageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Baker's Percentages")
                .font(.headline)

            if !bakersPercentages.totalFormula.isEmpty {
                Text("Total Formula")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(bakersPercentages.totalFormula) { row in
                    HStack {
                        Text(row.ingredient)
                            .font(.system(.body, design: .monospaced))
                        Spacer()
                        Text("\(Int(row.weight))g")
                            .foregroundColor(.secondary)
                            .font(.system(.caption, design: .monospaced))
                        Text(String(format: "%.1f%%", row.percentage))
                            .frame(width: 60, alignment: .trailing)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Preferment Breakdown Card
    private var prefermentBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferment Details")
                .font(.headline)

            ForEach(formula.preferments) { preferment in
                VStack(alignment: .leading, spacing: 8) {
                    Text(preferment.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    HStack {
                        Label("\(Int(preferment.flourWeight))g flour", systemImage: "leaf")
                            .font(.caption)
                        Spacer()
                        Label("\(Int(preferment.waterWeight))g water", systemImage: "drop")
                            .font(.caption)
                    }

                    Text("Hydration: \(Int(preferment.hydration))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                if preferment.id != formula.preferments.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Helper Methods
    private var bakersPercentages: BakersPercentageTable {
        calculationService.calculateBakersPercentages(for: formula)
    }

    private var validationWarnings: [ValidationWarning] {
        validationService.validate(formula: formula)
    }

    private var hydrationColor: Color {
        let hydration = formula.overallHydration
        switch hydration {
        case 0..<50: return .red
        case 50..<60: return .orange
        case 60..<85: return .green
        default: return .blue
        }
    }
}

#Preview {
    NavigationStack {
        CalculationsView(formula: {
            let formula = Formula(name: "Country Sourdough")

            // Add flour
            formula.finalMix.flours.addFlour(type: .bread, weight: 800)

            // Add water and salt
            formula.finalMix.water = 380
            formula.finalMix.salt = 20

            // Add a levain
            let levain = Preferment(name: "Levain", type: .levain)
            levain.flourWeight = 200
            levain.waterWeight = 200
            formula.preferments.append(levain)

            return formula
        }())
    }
}
