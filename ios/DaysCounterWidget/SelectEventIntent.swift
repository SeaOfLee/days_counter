//
//  SelectEventIntent.swift
//  DaysCounterWidget
//
//  Per-instance widget configuration: each placed widget picks its own
//  event, which is what lets an iOS widget stack swipe between several of
//  them. Entity, query and intent live together here — they're small, and
//  splitting forty lines across three files would be over-decomposition.
//

import AppIntents
import WidgetKit

struct EventEntity: AppEntity {
    let id: String
    /// Already emoji-joined, so picker rows read like the app's cards.
    let title: String

    init(_ event: WidgetEvent) {
        id = event.id
        title = event.displayTitle
    }

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Event" }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }

    static var defaultQuery = EventEntityQuery()
}

struct EventEntityQuery: EntityQuery {
    /// Both methods re-read the shared list on every call rather than
    /// caching, so a renamed event shows its new title and a deleted event
    /// resolves to nothing (which the provider renders as the prompt).
    func entities(for identifiers: [String]) async throws -> [EventEntity] {
        loadEvents()
            .filter { identifiers.contains($0.id) }
            .map(EventEntity.init)
    }

    /// Populates the picker. Order matches the app's list order, because
    /// the payload is written in list order — see WidgetBridge.updateEvents.
    func suggestedEntities() async throws -> [EventEntity] {
        loadEvents().map(EventEntity.init)
    }
}

struct SelectEventIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Event"
    static var description = IntentDescription("Choose which event this widget shows.")

    // Deliberately optional: a non-optional parameter changes how iOS treats
    // widgets placed before this feature existed. Optional is what gives the
    // "needs configuration" state for free.
    @Parameter(title: "Event")
    var event: EventEntity?

    init() {}

    init(event: EventEntity?) {
        self.event = event
    }
}
