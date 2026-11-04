import SwiftUI
import TripDomain
import TripLocalization

struct TripDurationControl: View {
    let label: String
    @Binding var minutes: Double
    let range: ClosedRange<Int>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(label)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(reduceMotion ? nil : .smooth(duration: 0.18), value: minutes)
            slider
                .accessibilityLabel(label)
                .accessibilityValue(TripScheduleText.duration(Int(minutes)))
        }
    }

    private var slider: some View {
        Slider(value: $minutes, in: Double(range.lowerBound)...Double(range.upperBound), step: 5) {
            Text(label)
        } minimumValueLabel: {
            Text(TripScheduleText.duration(range.lowerBound)).font(.caption)
        } maximumValueLabel: {
            Text(TripScheduleText.duration(range.upperBound)).font(.caption)
        } tick: { value in
            value == Double(range.lowerBound) || value.truncatingRemainder(dividingBy: 60) == 0
                ? SliderTick(value) : nil
        }
    }
}

#Preview("Visit duration · interactive") {
    @Previewable @State var minutes = 60.0
    Form {
        TripDurationControl(label: TripText.durationValue(TripScheduleText.duration(Int(minutes))).text,
                            minutes: $minutes, range: TripLimits.visitMinutes)
    }
}
#Preview("Buffer · large text, dark") {
    @Previewable @State var minutes = 10.0
    Form {
        TripDurationControl(label: TripText.bufferValue(TripScheduleText.duration(Int(minutes))).text,
                            minutes: $minutes, range: TripLimits.bufferMinutes)
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
