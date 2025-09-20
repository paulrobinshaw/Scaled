import SwiftUI

struct CollapsibleSection<Header: View, Content: View>: View {
    @State private var isExpanded: Bool
    private let header: () -> Header
    private let content: () -> Content

    init(initiallyExpanded: Bool = true, @ViewBuilder header: @escaping () -> Header, @ViewBuilder content: @escaping () -> Content) {
        _isExpanded = State(initialValue: initiallyExpanded)
        self.header = header
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Button(action: { withAnimation(.easeInOut) { isExpanded.toggle() } }) {
                HStack {
                    header()
                        .themedSectionHeader()
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(Palette.burntOrange)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, Spacing.sm)
    }
}
