//
//  Habit.swift
//  HabitTracker
//
//  Created by Yash Patil on 17/10/2025.
//

import Foundation

struct Habit: Identifiable, Hashable {
    let id: UUID
    var title: String
    var targetPerDay: Double
    var progress: Double
    var reminderHour: Int
    var createdAt: Date

    init(id: UUID = UUID(),
         title: String,
         targetPerDay: Double = 1,
         progress: Double = 0,
         reminderHour: Int = 8,
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.targetPerDay = targetPerDay
        self.progress = progress
        self.reminderHour = reminderHour
        self.createdAt = createdAt
    }
}
