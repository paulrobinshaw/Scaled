import Foundation

public struct Formula: Identifiable, Hashable, Codable {
    public struct DisplayPreferences: Hashable, Codable {
        public enum Mode: String, Hashable, Codable, CaseIterable {
            case bakersPercentage = "Baker's %"
            case weight = "Weight"
            case both = "Both"
        }

        public enum Rounding: String, Hashable, Codable, CaseIterable {
            case wholeGram = "1g"
            case tenthGram = "0.1g"
            case hundredthGram = "0.01g"

            public var decimalPlaces: Int {
                switch self {
                case .wholeGram: return 0
                case .tenthGram: return 1
                case .hundredthGram: return 2
                }
            }
        }

        public var mode: Mode
        public var rounding: Rounding

        public init(mode: Mode = .both, rounding: Rounding = .wholeGram) {
            self.mode = mode
            self.rounding = rounding
        }
    }

    public var id: UUID
    public var recipeID: UUID?
    public var name: String
    public var version: Int
    public var notes: String
    public var yield: FormulaYield
    public var preferments: [Preferment]
    public var soakers: [Soaker]
    public var finalMix: FinalMix
    public var display: DisplayPreferences
    public var createdDate: Date
    public var lastModified: Date

    public init(
        id: UUID = UUID(),
        recipeID: UUID? = nil,
        name: String = "",
        version: Int = 1,
        notes: String = "",
        yield: FormulaYield = .init(),
        preferments: [Preferment] = [],
        soakers: [Soaker] = [],
        finalMix: FinalMix = .init(),
        display: DisplayPreferences = .init(),
        createdDate: Date = .now,
        lastModified: Date = .now
    ) {
        self.id = id
        self.recipeID = recipeID
        self.name = name
        self.version = version
        self.notes = notes
        self.yield = yield
        self.preferments = preferments
        self.soakers = soakers
        self.finalMix = finalMix
        self.display = display
        self.createdDate = createdDate
        self.lastModified = lastModified
    }
}

public struct FormulaYield: Hashable, Codable {
    public var pieces: Int
    public var weightPerPiece: Double

    public init(pieces: Int = 1, weightPerPiece: Double = 1000) {
        self.pieces = max(1, pieces)
        self.weightPerPiece = max(0, weightPerPiece)
    }

    public var totalWeight: Double {
        Double(pieces) * weightPerPiece
    }
}
