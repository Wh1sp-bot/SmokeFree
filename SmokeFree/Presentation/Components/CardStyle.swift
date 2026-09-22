import SwiftUI

extension View {
    /// Спільний вигляд «картки».
    func cardBackground() -> some View {
        background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
