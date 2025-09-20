import Testing
@testable import Scaled

struct UndoStackTests {
    @Test
    func undoAndRedoRestoresValues() {
        var stack = UndoStack(initialValue: Formula(name: "Test"))
        var formula = stack.value
        formula.name = "Updated"
        _ = stack.update(formula)
        #expect(stack.canUndo)
        stack.undo()
        #expect(stack.value.name == "Test")
        stack.redo()
        #expect(stack.value.name == "Updated")
    }
}
