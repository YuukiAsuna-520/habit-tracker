//
//  HabitTrackerWidget.swift
//  HabitTrackerWidget
//
//  Created by grace cen on 20/10/2025.
//

//Adding Widget extension
import WidgetKit
import SwiftUI

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let backgroundColor: Color
}
//getting quotes for each day
struct QuoteProvider: TimelineProvider {

    let quotes = [
        "Small steps every day can lead to big changes.",
        "It does not matter how slowly you go, don't stop.",
        "Your habits define your future.",
        "Do what you can, with what you have, where you are.",
        "Don't forget to take things slow",
        "It always seem impossible until it's done. ",
        "Progress is about making small efforts daily"
    ]
    
    let colors: [Color] = [.blue, .green, .purple, .orange, .red, .pink, .mint]
    
    func placeholder(in context: Context) -> QuoteEntry { QuoteEntry(date: Date(), quote: quotes[0], backgroundColor: colors[0])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        completion(placeholder(in: context))
    }
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<QuoteEntry>) -> Void) {
        var entries: [QuoteEntry] = []
        let currentDate = Date()
        
        //generate one quote per day
        
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let midnight = Calendar.current.startOfDay(for: entryDate)
            
            //use quote selection based on day
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: midnight) ?? 0
            let quote = quotes[dayOfYear % quotes.count]
            let color = colors[dayOfYear % colors.count]
            //entry of quotes at midnight
            let entry = QuoteEntry(date: midnight, quote: quote, backgroundColor: color)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
}

struct HabitTrackerWidgetEntryView : View {
    var entry: QuoteEntry
    
    var body: some View {
        ZStack {
            
            Text(entry.quote)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .padding()
            
        }.containerBackground(for: .widget) {
            LinearGradient(colors: [entry.backgroundColor.opacity(0.6), entry.backgroundColor], startPoint: .top, endPoint: .bottom).overlay(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
        }
    }
}
struct HabitTrackerWidget: Widget {
    let kind: String = "HabitTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            HabitTrackerWidgetEntryView(entry: entry)
            
        }
        .configurationDisplayName("Daily Motivation")
        .description("Get inspired everyday with quotes")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    HabitTrackerWidget()
} timeline: {
    QuoteEntry(date: .now, quote: "Small steps every day lead to big changes.", backgroundColor: .blue)
    QuoteEntry(date: .now.addingTimeInterval(86400), quote: "Progress is about making small efforts daily", backgroundColor: .purple)
}
