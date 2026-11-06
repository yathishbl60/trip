import SwiftUI
import TripDomain
import TripLocalization

struct TripTodayContentView: View {
    let tripID: UUID
    let today: TripTodayModel
    let controller: TripController
    let division: TripPaneDivision?
    @State private var expandsRest = false
    @ScaledMetric(relativeTo: .body) private var readableColumn: CGFloat = 180

    var body: some View {
        let horizontal = division?.sideBySide == true
        let gap = division?.gap ?? 0
        let layout = horizontal ? AnyLayout(HStackLayout(spacing: gap)) : AnyLayout(VStackLayout(spacing: gap))
        let rest = today.rest
        let split = canSeparate(rest)
        let length = split ? division?.secondLength : division?.largerLength
        return layout {
            if split, let division {
                List { primary }
                    .frame(width: horizontal ? division.firstLength : nil, height: horizontal ? nil : division.firstLength)
            }
            List {
                if !split { primary }
                if !rest.isEmpty { agenda(rest, split: split) }
                Section { Text(today.zoneText).font(.footnote).foregroundStyle(.secondary) }
            }.frame(width: horizontal ? length : nil, height: horizontal ? nil : length)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: division?.largerAlignment ?? .center)
    }

    private func canSeparate(_ rest: [TripTodayItem]) -> Bool {
        guard let division, !today.snapshot.needsTimeZoneReview, today.next != nil, !rest.isEmpty else { return false }
        return division.fitsBoth(minimumWidth: readableColumn, minimumHeight: AppTheme.controlTarget * 3)
    }

    @ViewBuilder private var primary: some View {
        if today.snapshot.needsTimeZoneReview {
            Section {
                Label(TripText.confirmThisTripSTimeZone.resource, systemImage: "clock.badge.questionmark")
                Text(TripText.olderSchedulesNeedYourReviewBeforeTodayCanUse.resource).foregroundStyle(.secondary)
                Button(TripText.reviewInEditTrip.resource) { controller.beginEdit(tripID) }
            }
        } else if let next = today.next {
            TripTodayNextView(item: next, today: today, tripID: tripID, controller: controller)
        } else {
            ContentUnavailableView(today.emptyTitle, systemImage: "sun.horizon", description: Text(today.emptyMessage))
        }
    }

    private func agenda(_ items: [TripTodayItem], split: Bool) -> some View {
        TripTodayAgendaSection(items: items, today: today, tripID: tripID, controller: controller,
                               hasOwnPane: split, isExpanded: $expandsRest)
    }
}

#if DEBUG
#Preview("Today · asymmetric book fold, right to left") {
    let model = TripTodayPreview.planner()
    let id = model.library.trips[0].id
    let size = CGSize(width: 700, height: 500)
    let fold = TripPaneDivision(CGRect(x: 280, y: 0, width: 18, height: size.height), in: size)
    TripTodayContentView(tripID: id, today: model.today(id, at: TripTodayPreview.now)!,
                         controller: TripController(model: model), division: fold)
        .frame(width: size.width, height: size.height).environment(\.layoutDirection, .rightToLeft)
}
#Preview("Today · short tabletop, accessibility text") {
    let model = TripTodayPreview.planner()
    let id = model.library.trips[0].id
    let size = CGSize(width: 480, height: 570)
    let fold = TripPaneDivision(CGRect(x: 0, y: 245, width: size.width, height: 20), in: size)
    TripTodayContentView(tripID: id, today: model.today(id, at: TripTodayPreview.now)!,
                         controller: TripController(model: model), division: fold)
        .frame(width: size.width, height: size.height).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
