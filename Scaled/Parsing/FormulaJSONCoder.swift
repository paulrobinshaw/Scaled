import Foundation

public protocol FormulaCoding {
    func encode(_ formula: Formula) throws -> Data
    func decode(_ data: Data) throws -> Formula
    func encodeCollection(_ formulas: [Formula]) throws -> Data
    func decodeCollection(_ data: Data) throws -> [Formula]
}

public struct FormulaJSONCoder: FormulaCoding {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601) {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        encoder.dateEncodingStrategy = dateEncodingStrategy
        decoder.dateDecodingStrategy = .iso8601
    }

    public func encode(_ formula: Formula) throws -> Data {
        try encoder.encode(formula)
    }

    public func decode(_ data: Data) throws -> Formula {
        try decoder.decode(Formula.self, from: data)
    }

    public func encodeCollection(_ formulas: [Formula]) throws -> Data {
        try encoder.encode(formulas)
    }

    public func decodeCollection(_ data: Data) throws -> [Formula] {
        try decoder.decode([Formula].self, from: data)
    }
}
