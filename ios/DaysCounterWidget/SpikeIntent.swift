//
//  SpikeIntent.swift
//  DaysCounterWidget
//
//  THROWAWAY — Phase 21 build spike only. This exists to put real App
//  Intents symbols in the widget extension target so that
//  ExtractAppIntentsMetadata actually has work to do. Flipping
//  ENABLE_APP_INTENTS_METADATA_EXTRACTION on its own is a false negative:
//  with no intents in the target the task is a no-op and may never create
//  the build-graph edges that cycle with Flutter's "Thin Binary" phase.
//
//  Delete this file once the spike has answered the question.
//

import AppIntents
import WidgetKit

struct EventEntity: AppEntity {
    let id: String
    let title: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Event" }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }

    static var defaultQuery = EventEntityQuery()
}

struct EventEntityQuery: EntityQuery {
    private static let sample = [
        EventEntity(id: "1", title: "Last Drink"),
        EventEntity(id: "2", title: "Vacation"),
    ]

    func entities(for identifiers: [String]) async throws -> [EventEntity] {
        Self.sample.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [EventEntity] {
        Self.sample
    }
}

struct SelectEventIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Event"
    static var description = IntentDescription("Choose which event this widget shows.")

    @Parameter(title: "Event")
    var event: EventEntity?
}
