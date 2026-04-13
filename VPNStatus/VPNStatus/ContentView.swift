import SwiftUI

struct ContentView: View {
    @State private var status: VPNStatus = VPNStatusStorage.load()
    @State private var message: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Saved status")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(status.displayTitle)
                        .font(.title2.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

                VStack(spacing: 12) {
                    Button("Show Work VPN") {
                        Task { await apply(.work) }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Show External VPN") {
                        Task { await apply(.external) }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Clear VPN (stop Live Activity)") {
                        Task { await apply(.none) }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)

                if let message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("VPN Status")
        }
        .onAppear { refresh() }
    }

    private func refresh() {
        status = VPNStatusStorage.load()
    }

    private func apply(_ newStatus: VPNStatus) async {
        message = nil
        do {
            if newStatus == .none {
                try await LiveActivityManager.shared.stop()
            } else {
                try await LiveActivityManager.shared.startOrUpdate(status: newStatus)
            }
            refresh()
        } catch {
            message = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
