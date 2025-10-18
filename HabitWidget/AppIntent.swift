//
//  AppIntent.swift
//  HabitWidget
//
//  Created by Soorya Narayanan Sanand on 18/10/2025.
//

import WidgetKit
import AppIntents

// Simple app intent for habit tracking
struct HabitAppIntent: AppIntent {
    static var title: LocalizedStringResource { "Track Habit" }
    static var description: IntentDescription { "Mark a habit as complete" }
    
    @Parameter(title: "Habit Name")
    var habitName: String
    
    func perform() async throws -> some IntentResult {
        // This could be used for Siri shortcuts in the future
        return .result()
    }
}
