//
//  SimpleWidget.swift
//  HabitWidget
//
//  Created by Soorya Sanand on 15/10/2025.
//

import WidgetKit
import SwiftUI

struct SimpleWidget: Widget {
    let kind: String = "SimpleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleTimelineProvider()) { entry in
            SimpleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Stay motivated with daily quotes!")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SimpleTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: "Every small step counts!")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), quote: MotivationalQuotes.getRandomQuote())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, quote: MotivationalQuotes.getRandomQuote())
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: String
}

struct SimpleWidgetEntryView: View {
    var entry: SimpleEntry
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

struct MotivationalQuotes {
    static let quotes = [
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
    
    static func getRandomQuote() -> String {
        return quotes.randomElement() ?? "Every small step counts!"
    }
}

#Preview(as: .systemSmall) {
    SimpleWidget()
} timeline: {
    SimpleEntry(date: Date(), quote: "Every small step counts!")
}

#Preview(as: .systemMedium) {
    SimpleWidget()
} timeline: {
    SimpleEntry(date: Date(), quote: "Progress, not perfection.")
}
