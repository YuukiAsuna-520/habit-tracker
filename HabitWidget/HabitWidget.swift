//
//  HabitWidget.swift
//  HabitWidget
//
//  Created by Soorya Sanand on 15/10/2025.
//

import WidgetKit
import SwiftUI

struct HabitWidget: Widget {
    let kind: String = "HabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitTimelineProvider()) { entry in
            HabitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track your daily habits and stay motivated!")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HabitTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), motivationalQuote: "Every small step counts!")
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> ()) {
        let entry = createEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> ()) {
        let currentDate = Date()
        let entry = createEntry(date: currentDate)
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func createEntry(date: Date) -> HabitEntry {
        let quote = MotivationalQuotes.getRandomQuote()
        return HabitEntry(date: date, motivationalQuote: quote)
    }
}

struct HabitEntry: TimelineEntry {
    let date: Date
    let motivationalQuote: String
}

struct HabitWidgetEntryView: View {
    var entry: HabitEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.blue)
                Text("Daily Motivation")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Text(entry.motivationalQuote)
                .font(family == .systemMedium ? .body : .caption)
                .lineLimit(family == .systemMedium ? 4 : 3)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}



#Preview(as: .systemSmall) {
    HabitWidget()
} timeline: {
    HabitEntry(date: Date(), motivationalQuote: "Every small step counts!")
}

#Preview(as: .systemMedium) {
    HabitWidget()
} timeline: {
    HabitEntry(date: Date(), motivationalQuote: "Progress, not perfection.")
}
