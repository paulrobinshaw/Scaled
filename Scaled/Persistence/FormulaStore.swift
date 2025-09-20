import Foundation

public protocol FormulaStoring {
    func loadFormulas() async throws -> [Formula]
    func save(formulas: [Formula]) async throws
}

public actor InMemoryFormulaStore: FormulaStoring {
    private var storage: [Formula]

    public init(seed: [Formula] = []) {
        self.storage = seed
    }

    public func loadFormulas() async throws -> [Formula] {
        storage
    }

    public func save(formulas: [Formula]) async throws {
        storage = formulas
    }
}
