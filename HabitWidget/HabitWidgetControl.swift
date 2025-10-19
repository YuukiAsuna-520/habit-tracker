//
//  HabitWidgetControl.swift
//  HabitWidget
//
//  Created by Soorya Narayanan Sanand on 18/10/2025.
//

import AppIntents
import SwiftUI
import WidgetKit

struct HabitWidgetControl: ControlWidget {
    static let kind: String = "com.soorya.sanand.HabitTracker.HabitWidget"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Complete Habit",
                isOn: value.isCompleted,
                action: ToggleHabitIntent(value.habitName)
            ) { isCompleted in
                Label(isCompleted ? "Done" : "Pending", systemImage: isCompleted ? "checkmark.circle.fill" : "circle")
            }
        }
        .displayName("Habit Tracker")
        .description("Mark your habit as complete")
    }
}

extension HabitWidgetControl {
    struct Value {
        var isCompleted: Bool
        var habitName: String
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: HabitConfiguration) -> Value {
            HabitWidgetControl.Value(isCompleted: false, habitName: configuration.habitName)
        }

        func currentValue(configuration: HabitConfiguration) async throws -> Value {
            // Check if the habit is completed for today
            let isCompleted = false // This would check against your Core Data
            return HabitWidgetControl.Value(isCompleted: isCompleted, habitName: configuration.habitName)
        }
    }
}

struct HabitConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Habit Configuration"

    @Parameter(title: "Habit Name", default: "Daily Habit")
    var habitName: String
}

struct ToggleHabitIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Toggle habit completion"

    @Parameter(title: "Habit Name")
    var habitName: String

    @Parameter(title: "Habit is completed")
    var value: Bool

    init() {}

    init(_ habitName: String) {
        self.habitName = habitName
    }

    func perform() async throws -> some IntentResult {
        // Toggle habit completion in Core Data
        // This would integrate with your SharedDataManager
        return .result()
    }
}
