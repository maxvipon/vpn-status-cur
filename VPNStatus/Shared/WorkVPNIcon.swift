import SwiftUI

/// Shared VPN icon used across app and Live Activity.
struct WorkVPNIcon: View {
    var size: CGFloat = 24

    var body: some View {
        Image(systemName: "network")
            .font(.system(size: size * 0.85, weight: .medium))
            .symbolRenderingMode(.hierarchical)
            .frame(width: size, height: size)
            .accessibilityLabel("VPN")
    }
}
