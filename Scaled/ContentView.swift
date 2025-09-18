import SwiftUI

struct ContentView: View {
    @State private var formulas: [Formula] = []
    @State private var selectedFormula: Formula?
    @State private var showingNewFormula = false

    var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            detailView
        }
        .onAppear {
            if formulas.isEmpty {
                createSampleFormula()
            }
        }
    }

    // MARK: - Sidebar View
    @ViewBuilder
    private var sidebarView: some View {
        List(selection: $selectedFormula) {
            ForEach(formulas) { formula in
                NavigationLink(value: formula) {
                    formulaRow(formula)
                }
            }
            .onDelete { indexSet in
                formulas.remove(atOffsets: indexSet)
            }
        }
        .navigationTitle("Formulas")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: createNewFormula) {
                    Label("New Formula", systemImage: "plus")
                }
            }
        }
        .overlay {
            if formulas.isEmpty {
                emptyStateView
            }
        }
    }

    // MARK: - Formula Row
    @ViewBuilder
    private func formulaRow(_ formula: Formula) -> some View {
        VStack(alignment: .leading) {
            Text(formula.name.isEmpty ? "Untitled Formula" : formula.name)
                .font(.headline)
            HStack {
                hydrationLabel(formula)
                Spacer()
                weightLabel(formula)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Hydration Label
    private func hydrationLabel(_ formula: Formula) -> some View {
        Text("Hydration: \(Int(formula.overallHydration))%")
            .font(.caption)
            .foregroundColor(.secondary)
    }

    // MARK: - Weight Label
    private func weightLabel(_ formula: Formula) -> some View {
        Text("\(Int(formula.totalWeight))g")
            .font(.caption)
            .foregroundColor(.secondary)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Formulas",
            systemImage: "doc.text",
            description: Text("Tap + to create your first formula")
        )
    }

    // MARK: - Detail View
    @ViewBuilder
    private var detailView: some View {
        if let formula = selectedFormula {
            NavigationStack {
                TabView {
                    FormulaEditView(formula: formula)
                        .tabItem {
                            Label("Edit", systemImage: "pencil")
                        }

                    CalculationsView(formula: formula)
                        .tabItem {
                            Label("Calculate", systemImage: "function")
                        }
                }
            }
        } else {
            ContentUnavailableView(
                "Select a Formula",
                systemImage: "doc.text",
                description: Text("Choose a formula from the sidebar or create a new one")
            )
        }
    }

    // MARK: - Helper Methods
    private func createNewFormula() {
        let newFormula = Formula(name: "New Formula")
        formulas.append(newFormula)
        selectedFormula = newFormula
    }

    private func createSampleFormula() {
        let sample = Formula(name: "Country Sourdough")

        // Add flour
        sample.finalMix.flours.addFlour(type: .bread, weight: 800)

        // Add water and salt
        sample.finalMix.water = 380
        sample.finalMix.salt = 20

        // Add a levain
        let levain = Preferment(name: "Levain", type: .levain)
        levain.flourWeight = 200
        levain.waterWeight = 200
        sample.preferments.append(levain)

        formulas.append(sample)
        selectedFormula = sample
    }
}

#Preview {
    ContentView()
}
