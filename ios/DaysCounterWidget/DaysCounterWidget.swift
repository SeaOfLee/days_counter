//
//  DaysCounterWidget.swift
//  DaysCounterWidget
//
//  Created by Lee Richardson on 8/2/26.
//

import WidgetKit
import SwiftUI

private let lastDrinkDate = Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 19))!

private func daysSince(_ start: Date, comparedTo date: Date) -> Int {
    let calendar = Calendar.current
    let startOfStart = calendar.startOfDay(for: start)
    let startOfDate = calendar.startOfDay(for: date)
    return calendar.dateComponents([.day], from: startOfStart, to: startOfDate).day ?? 0
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dayCount: daysSince(lastDrinkDate, comparedTo: Date()))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), dayCount: daysSince(lastDrinkDate, comparedTo: Date())))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        let entries: [SimpleEntry] = (0..<7).compactMap { dayOffset in
            guard let entryDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) else {
                return nil
            }
            return SimpleEntry(date: entryDate, dayCount: daysSince(lastDrinkDate, comparedTo: entryDate))
        }

        // Values only change once a day, so request a fresh timeline once
        // these entries are exhausted rather than polling more often.
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dayCount: Int
}

struct DaysCounterWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Last Drink")

            Text(entry.dayCount.formatted())
                .font(.largeTitle)

            Text("days")
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
    SimpleEntry(date: .now, dayCount: 1139)
    SimpleEntry(date: .now.addingTimeInterval(86400), dayCount: 1140)
}
