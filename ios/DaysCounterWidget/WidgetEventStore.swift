//
//  WidgetEventStore.swift
//  DaysCounterWidget
//
//  Reads the event list the Flutter app projects into the shared App Group,
//  and computes the display values the widget renders from it.
//
//  Nothing here is `private`: `private` at file scope in Swift means
//  file-private, and both the timeline provider and the App Intents entity
//  query need these. They're internal to the extension module instead.
//

import Foundation

// Keep these in sync with the matching constants in AppDelegate.swift —
// the two targets compile separately and can't share this definition.
let widgetAppGroupIdentifier = "group.net.leerichardson.dayscounter"
let widgetEventsKey = "eventsPayload"

/// One event as serialized by DateEvent.toJson in the Flutter app.
struct WidgetEvent: Decodable {
    let id: String
    let title: String
    let date: String
    let direction: String
    let emoji: String?

    /// Matches how the app's event cards read, e.g. "🍺 Last Drink".
    var displayTitle: String {
        [emoji, title].compactMap { $0 }.joined(separator: " ")
    }
}

let utcCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}()

let eventDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = utcCalendar
    formatter.timeZone = utcCalendar.timeZone
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

// Mirrors lib/utils/date_calculations.dart's formatDate, e.g. "June 19, 2023".
let displayDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = utcCalendar
    formatter.timeZone = utcCalendar.timeZone
    formatter.dateFormat = "MMMM d, yyyy"
    return formatter
}()

/// Mirrors lib/utils/date_calculations.dart: normalize to UTC midnight (not
/// local midnight) so day counts don't skew across a DST transition.
func dateOnlyUTC(fromLocal date: Date) -> Date {
    let localComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
    return utcCalendar.date(from: localComponents)!
}

func calendarDayDifference(from start: Date, to end: Date) -> Int {
    utcCalendar.dateComponents([.day], from: start, to: end).day ?? 0
}

func dayCount(for event: WidgetEvent, on localDate: Date) -> Int? {
    guard let eventDate = eventDateFormatter.date(from: event.date) else { return nil }
    let today = dateOnlyUTC(fromLocal: localDate)
    switch event.direction {
    case "until":
        return calendarDayDifference(from: today, to: eventDate)
    default:
        return calendarDayDifference(from: eventDate, to: today)
    }
}

func dateLine(for event: WidgetEvent) -> String? {
    guard let eventDate = eventDateFormatter.date(from: event.date) else { return nil }
    let formatted = displayDateFormatter.string(from: eventDate)
    return event.direction == "until" ? "Until \(formatted)" : "Since \(formatted)"
}

/// The whole event list, in the order the app stores it. Returns an empty
/// list rather than nil for every failure mode — a missing key (never
/// synced) and an empty list (user has no events) render the same way, so
/// there's no reason to distinguish them here.
func loadEvents() -> [WidgetEvent] {
    guard
        let defaults = UserDefaults(suiteName: widgetAppGroupIdentifier),
        let payload = defaults.string(forKey: widgetEventsKey),
        let data = payload.data(using: .utf8),
        let events = try? JSONDecoder().decode([WidgetEvent].self, from: data)
    else {
        return []
    }
    return events
}

func event(withId id: String?) -> WidgetEvent? {
    guard let id else { return nil }
    return loadEvents().first { $0.id == id }
}
