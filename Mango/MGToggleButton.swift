import SwiftUI

struct MGToggleButton: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    let title: String
    let isOn: Binding<Bool>
    var body: some View {
        Toggle(title, isOn: isOn)
            .background(RoundedRectangle(cornerRadius: 6).fill(isOn.wrappedValue ? .clear : self.backgroundColor))
            .toggleStyle(.button)
    }
    
    private var backgroundColor: Color {
        switch colorScheme {
        case .light:
            return .gray.opacity(0.1)
        case .dark:
            return .white.opacity(0.1)
        @unknown default:
            return .gray.opacity(0.1)
        }
    }
}
