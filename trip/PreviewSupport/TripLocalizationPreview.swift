#if DEBUG
import Foundation
import SwiftUI
import TripLocalization

struct TripLocalizationPreview: View {
    let locale: Locale

    var body: some View {
        NavigationStack {
            Form {
                planning
                feedback
            }
            .navigationTitle(TripText.newTrip.localized(locale: locale))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(TripText.cancel.localized(locale: locale)) { }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(TripText.save.localized(locale: locale)) { }
                }
            }
        }
        .environment(\.locale, locale)
    }

    private var planning: some View {
        Section(TripText.yourDay.localized(locale: locale)) {
            Label(TripText.dayTitle(2).localized(locale: locale), systemImage: "calendar")
            LabeledContent(TripText.places.localized(locale: locale),
                value: TripText.placeCount(3).localized(locale: locale))
            LabeledContent(TripText.timeZone.localized(locale: locale), value: "Asia/Kolkata")
            Text(TripText.choosePlaces.localized(locale: locale))
            Text(TripText.noPlacesYet.localized(locale: locale))
        }
    }

    private var feedback: some View {
        Section(TripText.checklist.localized(locale: locale)) {
            Text(TripText.travelEssentials.localized(locale: locale))
            Text(TripText.confirmReservations.localized(locale: locale))
            Text(TripText.thisTripIsNoLongerAvailable.localized(locale: locale))
                .foregroundStyle(.secondary)
            Button(TripText.tryAgain.localized(locale: locale)) { }
        }
    }
}

#Preview("Localization · English") {
    TripLocalizationPreview(locale: Locale(identifier: "en"))
}
#Preview("Localization · Kannada, compact") {
    TripLocalizationPreview(locale: Locale(identifier: "kn"))
        .frame(width: 320)
}
#Preview("Localization · Hindi, large text and dark") {
    TripLocalizationPreview(locale: Locale(identifier: "hi"))
        .dynamicTypeSize(.accessibility1).preferredColorScheme(.dark)
}
#endif
