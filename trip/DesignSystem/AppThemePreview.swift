#if DEBUG
import SwiftUI

private struct AppThemePreview: View {
    @State private var reminders = true

    var body: some View {
        Form {
            Section("Content") {
                Text("Lake weekend").font(.headline)
                Text("Your next trip").foregroundStyle(.secondary)
                Label("Saved to trip", systemImage: "checkmark.circle")
            }
            actions
            Section("Controls") {
                Toggle("Reminders", isOn: $reminders)
                ProgressView(value: 0.6)
                Button("Delete trip", role: .destructive) {}
            }
        }
        .tint(AppTheme.accent)
    }

    private var actions: some View {
        Section("Actions") {
            Button("Directions", systemImage: "arrow.triangle.turn.up.right.diamond") {}
                .buttonStyle(.borderedProminent).tint(AppTheme.accentFill)
            Button("Save to trip", systemImage: "bookmark") {}
                .buttonStyle(.bordered)
            Button("Show all places") {}
        }
    }
}

#Preview("App colors · light") {
    AppThemePreview().preferredColorScheme(.light)
}

#Preview("App colors · dark") {
    AppThemePreview().preferredColorScheme(.dark)
}

#Preview("App colors · large text") {
    AppThemePreview().preferredColorScheme(.dark).dynamicTypeSize(.accessibility2)
}
#endif
