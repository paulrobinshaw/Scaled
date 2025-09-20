import Foundation

public struct AppDependencies {
    public let formulaStore: any FormulaStoring
    public let percentageCalculator: BakersPercentageCalculating
    public let analyzer: FormulaAnalyzing
    public let coder: FormulaCoding

    public init(
        formulaStore: any FormulaStoring,
        percentageCalculator: BakersPercentageCalculating,
        analyzer: FormulaAnalyzing,
        coder: FormulaCoding
    ) {
        self.formulaStore = formulaStore
        self.percentageCalculator = percentageCalculator
        self.analyzer = analyzer
        self.coder = coder
    }
}

public extension AppDependencies {
    static func live() -> AppDependencies {
        AppDependencies(
            formulaStore: InMemoryFormulaStore(),
            percentageCalculator: DefaultBakersPercentageCalculator(),
            analyzer: DefaultFormulaAnalyzer(),
            coder: FormulaJSONCoder()
        )
    }

    static func preview() -> AppDependencies {
        let sample = SampleData.formulas
        return AppDependencies(
            formulaStore: InMemoryFormulaStore(seed: sample),
            percentageCalculator: DefaultBakersPercentageCalculator(),
            analyzer: DefaultFormulaAnalyzer(),
            coder: FormulaJSONCoder()
        )
    }
}

enum SampleData {
    static let formulas: [Formula] = {
        let levain = Preferment(
            name: "Levain",
            flourWeight: 200,
            waterWeight: 200,
            starter: .init(weight: 40),
            buildHours: 12
        )
        let soaker = Soaker(
            name: "Seed Soaker",
            grains: [Soaker.Grain(name: "Sunflower", weight: 50)],
            water: 50,
            soakHours: 6
        )
        let finalMix = FinalMix(
            flours: [
                Flour(type: .bread, weight: 800),
                Flour(type: .wholeWheat, weight: 200),
            ],
            water: 420,
            salt: 20,
            inclusions: [Inclusion(name: "Walnuts", weight: 80)],
            enrichments: [],
            mixMethod: .autolyse,
            targetTemperature: 24
        )
        let formula = Formula(
            name: "Country Sourdough",
            notes: "House loaf with levain and seeds",
            yield: FormulaYield(pieces: 2, weightPerPiece: 900),
            preferments: [levain],
            soakers: [soaker],
            finalMix: finalMix
        )
        return [formula]
    }()
}
