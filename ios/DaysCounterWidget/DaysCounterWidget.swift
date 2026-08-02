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
private let widgetAppGroupIdentifier = "group.com.example.daysCounter"
private let widgetFeaturedEventKey = "featuredEventPayload"

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
        SimpleEntry(date: Date(), title: "Last Drink", dayCount: 1139)
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
            return SimpleEntry(date: date, title: "Add an event", dayCount: nil)
        }
        let title = [event.emoji, event.title].compactMap { $0 }.joined(separator: " ")
        return SimpleEntry(date: date, title: title, dayCount: count)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let dayCount: Int?
}

struct DaysCounterWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.title)

            if let dayCount = entry.dayCount {
                Text(dayCount.formatted())
                    .font(.largeTitle)

                Text("days")
            }
        }
    }
}

struct DaysCounterWidget: Widget {
    let kind: String = "DaysCounterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DaysCounterWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DaysCounterWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Days Counter")
        .description("Shows the day count for a tracked event.")
    }
}

#Preview(as: .systemSmall) {
    DaysCounterWidget()
} timeline: {
    SimpleEntry(date: .now, title: "Last Drink", dayCount: 1139)
    SimpleEntry(date: .now.addingTimeInterval(86400), title: "Last Drink", dayCount: 1140)
}
