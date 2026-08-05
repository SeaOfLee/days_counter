//
//  DaysCounterWidget.swift
//  DaysCounterWidget
//
//  Created by Lee Richardson on 8/2/26.
//

import WidgetKit
import SwiftUI

// Keep these in sync with the matching constants in AppDelegate.swift —
// the two targets compile separately and can't share this definition.
private let widgetAppGroupIdentifier = "group.net.leerichardson.dayscounter"
private let widgetFeaturedEventKey = "featuredEventPayload"

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

private struct FeaturedEvent: Decodable {
    let id: String
    let title: String
    let date: String
    let direction: String
    let emoji: String?
}

private let utcCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}()

private let eventDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = utcCalendar
    formatter.timeZone = utcCalendar.timeZone
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

// Mirrors lib/utils/date_calculations.dart's formatDate, e.g. "June 19, 2023".
private let displayDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = utcCalendar
    formatter.timeZone = utcCalendar.timeZone
    formatter.dateFormat = "MMMM d, yyyy"
    return formatter
}()

/// Mirrors lib/utils/date_calculations.dart: normalize to UTC midnight (not
/// local midnight) so day counts don't skew across a DST transition.
private func dateOnlyUTC(fromLocal date: Date) -> Date {
    let localComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
    return utcCalendar.date(from: localComponents)!
}

private func calendarDayDifference(from start: Date, to end: Date) -> Int {
    utcCalendar.dateComponents([.day], from: start, to: end).day ?? 0
}

private func dayCount(for event: FeaturedEvent, on localDate: Date) -> Int? {
    guard let eventDate = eventDateFormatter.date(from: event.date) else { return nil }
    let today = dateOnlyUTC(fromLocal: localDate)
    switch event.direction {
    case "until":
        return calendarDayDifference(from: today, to: eventDate)
    default:
        return calendarDayDifference(from: eventDate, to: today)
    }
}

private func dateLine(for event: FeaturedEvent) -> String? {
    guard let eventDate = eventDateFormatter.date(from: event.date) else { return nil }
    let formatted = displayDateFormatter.string(from: eventDate)
    return event.direction == "until" ? "Until \(formatted)" : "Since \(formatted)"
}

private func loadFeaturedEvent() -> FeaturedEvent? {
    guard
        let defaults = UserDefaults(suiteName: widgetAppGroupIdentifier),
        let payload = defaults.string(forKey: widgetFeaturedEventKey),
        let data = payload.data(using: .utf8)
    else {
        return nil
    }
    return try? JSONDecoder().decode(FeaturedEvent.self, from: data)
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Last Drink", dayCount: 1139, dateLine: "Since June 19, 2023")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(currentEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        let entries: [SimpleEntry] = (0..<7).compactMap { dayOffset in
            guard let entryDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) else {
                return nil
            }
            return currentEntry(for: entryDate)
        }

        // Values only change once a day, so request a fresh timeline once
        // these entries are exhausted rather than polling more often.
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func currentEntry(for date: Date) -> SimpleEntry {
        guard let event = loadFeaturedEvent(), let count = dayCount(for: event, on: date) else {
            return SimpleEntry(date: date, title: "Add an event", dayCount: nil, dateLine: nil)
        }
        let title = [event.emoji, event.title].compactMap { $0 }.joined(separator: " ")
        return SimpleEntry(date: date, title: title, dayCount: count, dateLine: dateLine(for: event))
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

    private var textPrimary: Color { colorScheme == .dark ? darkTextPrimary : lightTextPrimary }
    private var textMuted: Color { colorScheme == .dark ? darkTextMuted : lightTextMuted }
    private var divider: Color { colorScheme == .dark ? darkDivider : lightDivider }

    var body: some View {
        switch family {
        case .systemMedium:
            mediumBody
        default:
            smallBody
        }
    }

    private var smallBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(textMuted)
                .lineLimit(1)

            if let dayCount = entry.dayCount {
                Text(dayCount.formatted())
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(textPrimary)
                Text(dayCount == 1 ? "day" : "days")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(textMuted)
            }
        }
        .padding(16)
    }

    private var mediumBody: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(textMuted)
                    .lineLimit(1)

                if let dayCount = entry.dayCount {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(dayCount.formatted())
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(textPrimary)
                        Text(dayCount == 1 ? "day" : "days")
                            .font(.system(.callout, design: .rounded, weight: .semibold))
                            .foregroundStyle(textMuted)
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

            Image("Mascot")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
        }
        .padding(16)
    }
}

private struct WidgetBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        colorScheme == .dark ? darkBackground : cardLavender
    }
}

struct DaysCounterWidget: Widget {
    let kind: String = "DaysCounterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DaysCounterWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetBackground()
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

#Preview(as: .systemSmall) {
    DaysCounterWidget()
} timeline: {
    SimpleEntry(date: .now, title: "Last Drink", dayCount: 1139, dateLine: "Since June 19, 2023")
    SimpleEntry(date: .now.addingTimeInterval(86400), title: "Last Drink", dayCount: 1140, dateLine: "Since June 19, 2023")
}

#Preview(as: .systemMedium) {
    DaysCounterWidget()
} timeline: {
    SimpleEntry(date: .now, title: "Last Drink", dayCount: 1139, dateLine: "Since June 19, 2023")
    SimpleEntry(date: .now.addingTimeInterval(86400), title: "Last Drink", dayCount: 1140, dateLine: "Since June 19, 2023")
}
