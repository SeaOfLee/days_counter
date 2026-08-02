//
//  DaysCounterWidget.swift
//  DaysCounterWidget
//
//  Created by Lee Richardson on 8/2/26.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let timeline = Timeline(entries: [SimpleEntry(date: Date())], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct DaysCounterWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Last Drink")

            Text("1,139")
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
    SimpleEntry(date: .now)
}
