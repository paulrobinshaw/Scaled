import Foundation
import Observation

@MainActor
@Observable
final class FormulaEditorModel {
    var draft: Formula {
        didSet {
            guard !isRestoringState else { return }
            _ = undoStack.update(draft)
        }
    }

    private var undoStack: UndoStack<Formula>
    private var isRestoringState = false

    var canUndo: Bool { undoStack.canUndo }
    var canRedo: Bool { undoStack.canRedo }

    init(formula: Formula) {
        self.undoStack = UndoStack(initialValue: formula)
        self.draft = formula
    }

    func mutate(_ mutation: (inout Formula) -> Void) {
        var updated = draft
        mutation(&updated)
        draft = updated
    }

    func undo() {
        guard undoStack.canUndo else { return }
        isRestoringState = true
        undoStack.undo()
        draft = undoStack.value
        isRestoringState = false
    }

    func redo() {
        guard undoStack.canRedo else { return }
        isRestoringState = true
        undoStack.redo()
        draft = undoStack.value
        isRestoringState = false
    }



    func updateFlourType(id: UUID, type: FlourType) {
        mutate { formula in
            guard let index = formula.finalMix.flours.firstIndex(where: { $0.id == id }) else { return }
            formula.finalMix.flours[index].type = type
        }
    }

    func updateFlour(id: UUID, weight: Double) {
        mutate { formula in
            guard let index = formula.finalMix.flours.firstIndex(where: { $0.id == id }) else { return }
            formula.finalMix.flours[index].weight = max(0, weight)
        }
    }

    func addFlour(type: FlourType) {
        mutate { formula in
            formula.finalMix.flours.append(Flour(type: type, weight: 0))
        }
    }

    func removeFlour(id: UUID) {
        mutate { formula in
            formula.finalMix.flours.removeAll { $0.id == id }
        }
    }

    func updateFinalWater(_ weight: Double) {
        mutate { $0.finalMix.water = max(0, weight) }
    }

    func updateFinalSalt(_ weight: Double) {
        mutate { $0.finalMix.salt = max(0, weight) }
    }

    func updateYeast(_ weight: Double?) {
        mutate { $0.finalMix.yeast = weight.map { max(0, $0) } }
    }


    func updateYield(pieces: Int? = nil, weightPerPiece: Double? = nil) {
        mutate { formula in
            if let pieces { formula.yield.pieces = max(1, pieces) }
            if let weightPerPiece { formula.yield.weightPerPiece = max(0, weightPerPiece) }
        }
    }

    func addPreferment() {
        mutate { formula in
            var preferment = Preferment(name: "Preferment", flourWeight: 100, waterWeight: 100)
            preferment.kind = .levain
            formula.preferments.append(preferment)
        }
    }

    func removePreferment(id: UUID) {
        mutate { $0.preferments.removeAll { $0.id == id } }
    }

    func updatePreferment(_ preferment: Preferment) {
        mutate { formula in
            guard let index = formula.preferments.firstIndex(where: { $0.id == preferment.id }) else { return }
            formula.preferments[index] = preferment
        }
    }

    func addSoaker() {
        mutate { formula in
            let soaker = Soaker(name: "Soaker", grains: [Soaker.Grain(name: "Grain", weight: 50)], water: 50)
            formula.soakers.append(soaker)
        }
    }

    func removeSoaker(id: UUID) {
        mutate { $0.soakers.removeAll { $0.id == id } }
    }

    func updateSoaker(_ soaker: Soaker) {
        mutate { formula in
            guard let index = formula.soakers.firstIndex(where: { $0.id == soaker.id }) else { return }
            formula.soakers[index] = soaker
        }
    }
}
