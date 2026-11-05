import SwiftUI

/// The symbol and explanation convey the issue without relying on a warning color.
struct TripWarningLabel: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
    }
}

#Preview("Warning · form") {
    Form { TripWarningLabel(message: "This local time does not exist. Choose another time.") }
}
#Preview("Warning · narrow, accessibility, dark") {
    Form { TripWarningLabel(message: "Your changes could not be saved. Try again.") }
        .frame(width: 320).dynamicTypeSize(.accessibility3).preferredColorScheme(.dark)
}
