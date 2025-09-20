import SwiftUI

public enum Typography {
    public static let title = Font.system(.largeTitle, design: .serif).weight(.semibold)
    public static let heading = Font.system(.title2, design: .serif).weight(.semibold)
    public static let body = Font.system(.body, design: .rounded)
    public static let caption = Font.system(.caption, design: .rounded)
    public static let mono = Font.system(.body, design: .monospaced)
}
