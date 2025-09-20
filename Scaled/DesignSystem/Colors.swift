import SwiftUI

public enum Palette {
    public static let burntOrange = Color(red: 0.78, green: 0.36, blue: 0.12)
    public static let cream = Color(red: 0.98, green: 0.95, blue: 0.88)
    public static let charcoal = Color(red: 0.14, green: 0.15, blue: 0.18)
    public static let stone = Color(red: 0.68, green: 0.66, blue: 0.62)
    public static let flour = Color(red: 0.93, green: 0.90, blue: 0.84)
}

public enum Surface {
    public static let background = Palette.cream
    public static let secondary = Palette.flour
    public static let tertiary = Color(.systemGray6)
}

public enum Semantic {
    public static let success = Color.green
    public static let warning = Color.orange
    public static let error = Color.red
}
