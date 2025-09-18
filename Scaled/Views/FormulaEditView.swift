import SwiftUI

struct FormulaEditView: View {
    @Bindable var formula: Formula
    @State private var newFlourType: FlourType = .bread
    @State private var newFlourWeight: String = ""
    @State private var showingPrefermentSheet = false

    var body: some View {
        Form {
            // MARK: - Basic Info
            Section("Formula Info") {
                TextField("Name", text: $formula.name)
                Stepper("Yield: \(formula.yield.pieces) × \(Int(formula.yield.weightPerPiece))g",
                       value: $formula.yield.pieces,
                       in: 1...20)
            }

            // MARK: - Final Mix Flours
            Section("Flours") {
                ForEach(formula.finalMix.flours.items) { flour in
                    HStack {
                        Text(flour.type.rawValue)
                        Spacer()
                        Text("\(Int(flour.weight))g")
                    }
                }

                HStack {
                    Picker("Type", selection: $newFlourType) {
                        ForEach(FlourType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)

                    TextField("Weight (g)", text: $newFlourWeight)
                        .keyboardType(.numberPad)
                        .frame(width: 100)

                    Button("Add") {
                        if let weight = Double(newFlourWeight) {
                            formula.finalMix.flours.addFlour(type: newFlourType, weight: weight)
                            newFlourWeight = ""
                        }
                    }
                }
            }

            // MARK: - Water & Salt
            Section("Final Mix") {
                HStack {
                    Text("Water")
                    Spacer()
                    TextField("grams", value: $formula.finalMix.water, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .frame(width: 100)
                    Text("g")
                }

                HStack {
                    Text("Salt")
                    Spacer()
                    TextField("grams", value: $formula.finalMix.salt, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .frame(width: 100)
                    Text("g")
                }

                HStack {
                    Text("Yeast (optional)")
                    Spacer()
                    TextField("grams", value: $formula.finalMix.yeast, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                    Text("g")
                }
            }

            // MARK: - Preferments
            Section("Preferments") {
                ForEach(formula.preferments) { preferment in
                    VStack(alignment: .leading) {
                        Text(preferment.name)
                            .font(.headline)
                        HStack {
                            Text("Flour: \(Int(preferment.flourWeight))g")
                            Spacer()
                            Text("Water: \(Int(preferment.waterWeight))g")
                        }
                        .font(.caption)
                    }
                }

                Button("Add Preferment") {
                    showingPrefermentSheet = true
                }
            }
        }
        .navigationTitle("Edit Formula")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPrefermentSheet) {
            PrefermentEditSheet(formula: formula, isPresented: $showingPrefermentSheet)
        }
    }
}

// MARK: - Preferment Sheet
struct PrefermentEditSheet: View {
    let formula: Formula
    @Binding var isPresented: Bool

    @State private var preferment = Preferment()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $preferment.name)

                Picker("Type", selection: $preferment.type) {
                    ForEach(PrefermentType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }

                Section("Ingredients") {
                    HStack {
                        Text("Flour")
                        Spacer()
                        TextField("grams", value: $preferment.flourWeight, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                        Text("g")
                    }

                    HStack {
                        Text("Water")
                        Spacer()
                        TextField("grams", value: $preferment.waterWeight, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                        Text("g")
                    }

                    if preferment.type.usesYeast {
                        HStack {
                            Text("Yeast")
                            Spacer()
                            TextField("grams", value: $preferment.yeast, format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .frame(width: 100)
                            Text("g")
                        }
                    }
                }

                Section("Timing") {
                    HStack {
                        Text("Build Time")
                        Spacer()
                        TextField("hours", value: $preferment.buildHours, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                        Text("hours")
                    }
                }
            }
            .navigationTitle("Add Preferment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        formula.preferments.append(preferment)
                        isPresented = false
                    }
                    .disabled(preferment.name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FormulaEditView(formula: Formula(name: "Test Sourdough"))
    }
}