//
//  DaysCounterWidget.swift
//  DaysCounterWidget
//
//  Created by Lee Richardson on 8/2/26.
//

import WidgetKit
import SwiftUI

// The App Group constants, the shared event list, and the date math all
// live in WidgetEventStore.swift — the entity query needs them too.

// Palette mirrors lib/theme/app_colors.dart 1:1 — Flutter owns the main
// app, this widget owns only its own view layer, so there's no shared
// code between the two targets, just matching hex values by convention.
private let lightBackground = Color(red: 0.961, green: 0.949, blue: 0.980) // #F5F2FA
private let lightTextPrimary = Color(red: 0.110, green: 0.102, blue: 0.129) // #1C1A22
private let lightTextMuted = Color(red: 0.545, green: 0.525, blue: 0.588) // #8B8696
private let lightDivider = Color(red: 0.894, green: 0.875, blue: 0.933) // #E4DFEE
private let cardLavender = Color(red: 0.890, green: 0.851, blue: 0.953) // #E3D9F3

private let darkBackground = Color(red: 0.086, green: 0.075, blue: 0.125) // #161320
private let darkTextPrimary = Color(red: 0.945, green: 0.929, blue: 0.980) // #F1EDFA
private let darkTextMuted = Color(red: 0.553, green: 0.525, blue: 0.639) // #8D86A3
private let darkDivider = Color(red: 0.173, green: 0.153, blue: 0.235) // #2C2740

// Milestone treatment. The accent and its ink are the same tokens the app
// uses for the FAB and selected segments; onAccentMuted is new here, since
// the widget needs a second readable weight on the accent that the app has
// never wanted. Measured against #B49CE8: ink 6.7:1, muted 5.0:1.
private let accent = Color(red: 0.706, green: 0.612, blue: 0.910) // #B49CE8
private let onAccent = Color(red: 0.141, green: 0.122, blue: 0.200) // #241F33
private let onAccentMuted = Color(red: 0.227, green: 0.200, blue: 0.314) // #3A3350

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "🎉 Birthday", dayCount: 42, dateLine: "Until June 19")
    }

    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> SimpleEntry {
        // Browsing the widget gallery hands us an empty configuration. Showing
        // the "choose an event" prompt there would undersell the widget, so
        // preview real data when we have some.
        if context.isPreview, configuration.event == nil {
            guard let first = loadEvents().first else { return placeholder(in: context) }
            return entry(for: Date(), event: first)
        }
        return currentEntry(for: Date(), configuration: configuration)
    }

    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        let entries: [SimpleEntry] = (0..<7).compactMap { dayOffset in
            guard let entryDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) else {
                return nil
            }
            return currentEntry(for: entryDate, configuration: configuration)
        }

        // Values only change once a day, so request a fresh timeline once
        // these entries are exhausted rather than polling more often.
        return Timeline(entries: entries, policy: .atEnd)
    }

    /// Three states, and the order of these checks matters: an empty event
    /// list means "add an event" even when no event is configured, since
    /// telling someone to choose from nothing is useless.
    private func currentEntry(for date: Date, configuration: SelectEventIntent) -> SimpleEntry {
        let events = loadEvents()
        if events.isEmpty {
            return SimpleEntry(date: date, title: "Add an event", dayCount: nil, dateLine: nil)
        }
        guard
            let id = configuration.event?.id,
            let event = events.first(where: { $0.id == id })
        else {
            return SimpleEntry(date: date, title: "Choose an event", dayCount: nil, dateLine: nil)
        }
        return entry(for: date, event: event)
    }

    /// Offers one preconfigured tile per event in the widget gallery, so the
    /// user can add an already-configured widget instead of adding a blank
    /// one and then editing it.
    func recommendations() -> [AppIntentRecommendation<SelectEventIntent>] {
        loadEvents().map { event in
            AppIntentRecommendation(
                intent: SelectEventIntent(event: EventEntity(event)),
                description: Text(event.displayTitle)
            )
        }
    }

    private func entry(for date: Date, event: WidgetEvent) -> SimpleEntry {
        guard let count = dayCount(for: event, on: date) else {
            return SimpleEntry(date: date, title: "Choose an event", dayCount: nil, dateLine: nil)
        }
        return SimpleEntry(
            date: date,
            title: event.displayTitle,
            dayCount: count,
            dateLine: dateLine(for: event)
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let dayCount: Int?
    let dateLine: String?
}

struct DaysCounterWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry

    /// Non-nil on the days worth acknowledging. Both kinds get the same
    /// celebratory surface; what differs is whether the headline is a word
    /// or a number.
    private var milestoneKind: Milestone? {
        entry.dayCount.flatMap { milestone(for: $0) }
    }

    private var isCelebrating: Bool { milestoneKind != nil }

    private var textPrimary: Color {
        if isCelebrating { return onAccent }
        return colorScheme == .dark ? darkTextPrimary : lightTextPrimary
    }

    private var textMuted: Color {
        if isCelebrating { return onAccentMuted }
        return colorScheme == .dark ? darkTextMuted : lightTextMuted
    }

    private var divider: Color {
        if isCelebrating { return onAccentMuted.opacity(0.35) }
        return colorScheme == .dark ? darkDivider : lightDivider
    }

    private var mascotImage: String { isCelebrating ? "MascotCelebration" : "Mascot" }

    /// The celebration art carries confetti well outside the character, so
    /// at a shared frame size its calendar body renders visibly smaller than
    /// the walking pose's and the character reads as shrunken. A larger frame
    /// puts the two bodies at the same presence; the extra few points beyond
    /// that are deliberate weight for the occasion.
    private var mascotSize: CGFloat { isCelebrating ? 96 : 72 }

    var body: some View {
        switch family {
        case .systemMedium:
            mediumBody
        default:
            smallBody
        }
    }

    /// With no count the title is the widget's only content, so it gets the
    /// primary color and room to wrap — muted single-line is for a label
    /// sitting above a big number.
    private var titleColor: Color { entry.dayCount == nil ? textPrimary : textMuted }
    private var titleLineLimit: Int { entry.dayCount == nil ? 3 : 1 }

    private var smallBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(titleColor)
                .lineLimit(titleLineLimit)
                .minimumScaleFactor(0.9)

            if let dayCount = entry.dayCount {
                if milestoneKind == .today {
                    // A bare "0 days" reads like a rendering bug on the one
                    // day the count matters most.
                    Text("Today")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    Text(dayCount.formatted())
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(textPrimary)
                    Text(dayCount == 1 ? "day" : "days")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(textMuted)
                }
            }
        }
        .padding(16)
    }

    private var mediumBody: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(titleColor)
                    .lineLimit(titleLineLimit)
                    .minimumScaleFactor(0.9)

                if let dayCount = entry.dayCount {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        if milestoneKind == .today {
                            Text("Today")
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .foregroundStyle(textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        } else {
                            Text(dayCount.formatted())
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .foregroundStyle(textPrimary)
                            Text(dayCount == 1 ? "day" : "days")
                                .font(.system(.callout, design: .rounded, weight: .semibold))
                                .foregroundStyle(textMuted)
                        }
                    }

                    if let dateLine = entry.dateLine {
                        Rectangle()
                            .fill(divider)
                            .frame(height: 1)
                            .padding(.vertical, 2)
                        Text(dateLine)
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(textMuted)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Image(mascotImage)
                .resizable()
                .scaledToFit()
                .frame(width: mascotSize, height: mascotSize)
        }
        .padding(16)
    }
}

private struct WidgetBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var entry: SimpleEntry

    var body: some View {
        if entry.dayCount.flatMap({ milestone(for: $0) }) != nil {
            // Same accent in both themes: a milestone should read as a
            // deliberate break from the everyday surface, not a tint of it.
            accent
        } else {
            colorScheme == .dark ? darkBackground : cardLavender
        }
    }
}

struct DaysCounterWidget: Widget {
    let kind: String = "DaysCounterWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectEventIntent.self, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DaysCounterWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetBackground(entry: entry)
                    }
            } else {
                DaysCounterWidgetEntryView(entry: entry)
                    .padding()
                    .background(lightBackground)
            }
        }
        .configurationDisplayName("Dayward")
        .description("Shows the day count for a tracked event.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Every entry state, so the empty and milestone layouts get checked without
// booting a simulator.
#Preview(as: .systemSmall) {
    DaysCounterWidget()
} timeline: {
    SimpleEntry(date: .now, title: "🎉 Birthday", dayCount: 42, dateLine: "Until June 19")
    SimpleEntry(date: .now.addingTimeInterval(86400), title: "🎉 Birthday", dayCount: 41, dateLine: "Until June 19")
    SimpleEntry(date: .now, title: "🎉 Birthday", dayCount: 0, dateLine: "Until August 22")
    SimpleEntry(date: .now, title: "🍺 Last Drink", dayCount: 1000, dateLine: "Since June 19, 2023")
    SimpleEntry(date: .now, title: "Choose an event", dayCount: nil, dateLine: nil)
    SimpleEntry(date: .now, title: "Add an event", dayCount: nil, dateLine: nil)
}

#Preview(as: .systemMedium) {
    DaysCounterWidget()
} timeline: {
    SimpleEntry(date: .now, title: "🎉 Birthday", dayCount: 42, dateLine: "Until June 19")
    SimpleEntry(date: .now.addingTimeInterval(86400), title: "🎉 Birthday", dayCount: 41, dateLine: "Until June 19")
    SimpleEntry(date: .now, title: "🎉 Birthday", dayCount: 0, dateLine: "Until August 22")
    SimpleEntry(date: .now, title: "🍺 Last Drink", dayCount: 1000, dateLine: "Since June 19, 2023")
    SimpleEntry(date: .now, title: "Choose an event", dayCount: nil, dateLine: nil)
    SimpleEntry(date: .now, title: "Add an event", dayCount: nil, dateLine: nil)
}
