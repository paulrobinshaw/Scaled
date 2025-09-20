import Foundation

public struct UndoStack<Value: Equatable> {
    private var past: [Value] = []
    private var present: Value
    private var future: [Value] = []

    public init(initialValue: Value) {
        self.present = initialValue
    }

    public var value: Value {
        present
    }

    public var canUndo: Bool { !past.isEmpty }
    public var canRedo: Bool { !future.isEmpty }

    @discardableResult
    public mutating func update(_ newValue: Value) -> Bool {
        guard newValue != present else { return false }
        past.append(present)
        present = newValue
        future.removeAll()
        return true
    }

    public mutating func undo() {
        guard canUndo else { return }
        future.insert(present, at: 0)
        present = past.removeLast()
    }

    public mutating func redo() {
        guard canRedo else { return }
        past.append(present)
        present = future.removeFirst()
    }
}
