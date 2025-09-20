import Foundation

extension Double {
    var isSignificant: Bool { abs(self) > .ulpOfOne }
}
