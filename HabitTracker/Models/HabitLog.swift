//
//  HabitLog.swift
//  HabitTracker
//
//  Created by Yash Patil on 17/10/2025.
//
import Foundation

struct HabitLog: Identifiable, Hashable {
    let id: UUID
    var habitID: UUID
    var date: Date
    var amount: Double

    init(id: UUID = UUID(),
         habitID: UUID,
         date: Date = Date(),
         amount: Double = 1) {
        self.id = id
        self.habitID = habitID
        self.date = date
        self.amount = amount
    }
}
