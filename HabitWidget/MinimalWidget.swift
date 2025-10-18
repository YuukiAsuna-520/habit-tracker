//
//  MinimalWidget.swift
//  HabitWidget
//
//  Created by Soorya Sanand on 15/10/2025.
//

import WidgetKit
import SwiftUI

struct MinimalWidget: Widget {
    let kind: String = "MinimalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MinimalTimelineProvider()) { entry in
            MinimalWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Stay motivated with daily quotes!")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MinimalTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MinimalEntry {
        MinimalEntry(date: Date(), quote: "Every small step counts!")
    }

    func getSnapshot(in context: Context, completion: @escaping (MinimalEntry) -> ()) {
        let entry = MinimalEntry(date: Date(), quote: getRandomQuote())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MinimalEntry>) -> ()) {
        let currentDate = Date()
        let entry = MinimalEntry(date: currentDate, quote: getRandomQuote())
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getRandomQuote() -> String {
        let quotes = [
            "Every small step counts!",
            "Progress, not perfection.",
            "You are stronger than you think.",
            "Consistency is the key to success.",
            "Today is a new opportunity.",
            "Small actions lead to big changes.",
            "Believe in your ability to improve.",
            "Every habit matters.",
            "You've got this!",
            "Success is the sum of small efforts."
        ]
        return quotes.randomElement() ?? "Every small step counts!"
    }
}

struct MinimalEntry: TimelineEntry {
    let date: Date
    let quote: String
}

struct MinimalWidgetEntryView: View {
    var entry: MinimalEntry
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
            
            Text(entry.quote)
                .font(family == .systemMedium ? .body : .caption)
                .lineLimit(family == .systemMedium ? 4 : 3)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview(as: .systemSmall) {
    MinimalWidget()
} timeline: {
    MinimalEntry(date: Date(), quote: "Every small step counts!")
}

#Preview(as: .systemMedium) {
    MinimalWidget()
} timeline: {
    MinimalEntry(date: Date(), quote: "Progress, not perfection.")
}
