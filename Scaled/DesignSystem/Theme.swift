import SwiftUI

public enum Theme {
    public static func formBackground() -> some ViewModifier {
        BackgroundModifier(color: Surface.background)
    }

    public static func cardBackground() -> some ViewModifier {
        BackgroundModifier(color: Surface.secondary)
    }

    public static func sectionHeaderStyle() -> some ViewModifier {
        SectionHeaderModifier()
    }
}

private struct BackgroundModifier: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .padding(Spacing.lg)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Typography.heading)
            .foregroundStyle(Palette.charcoal)
            .padding(.bottom, Spacing.sm)
    }
}

public extension View {
    func themedFormBackground() -> some View {
        modifier(Theme.formBackground())
    }

    func themedCardBackground() -> some View {
        modifier(Theme.cardBackground())
    }

    func themedSectionHeader() -> some View {
        modifier(Theme.sectionHeaderStyle())
    }
}
