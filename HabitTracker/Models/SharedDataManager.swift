//
//  SharedDataManager.swift
//  HabitTracker
//
//  Created by Soorya Sanand on 15/10/2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

class SharedDataManager: ObservableObject {
    static let shared = SharedDataManager()
    
    private let appGroupIdentifier = "group.com.soorya.sanand.HabitTracker"
    
    @Published var habits: [Habit] = []
    
    private init() {
        // Use the shared PersistenceController instead of creating a separate stack
    }
    
    var viewContext: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }
    
    func save() {
        let context = viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Habit Management
    
    func fetchActiveHabits() -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.createdAt, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching habits: \(error)")
            return []
        }
    }
    
    func fetchHabitsForToday() -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.createdAt, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching habits for today: \(error)")
            return []
        }
    }
    
    func markHabitComplete(_ habit: Habit, for date: Date = Date()) {
        var completionDates = (habit.completionDates as? [Date]) ?? []
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        // Check if already completed for this date
        if !completionDates.contains(where: { calendar.isDate($0, inSameDayAs: normalizedDate) }) {
            completionDates.append(normalizedDate)
            habit.completionDates = completionDates as NSObject
            save()
        }
    }
    
    func markHabitIncomplete(_ habit: Habit, for date: Date = Date()) {
        var completionDates = (habit.completionDates as? [Date]) ?? []
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        completionDates.removeAll { calendar.isDate($0, inSameDayAs: normalizedDate) }
        habit.completionDates = completionDates as NSObject
        save()
    }
    
    func isHabitCompleted(_ habit: Habit, for date: Date = Date()) -> Bool {
        guard let completionDates = habit.completionDates as? [Date] else { return false }
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        return completionDates.contains { calendar.isDate($0, inSameDayAs: normalizedDate) }
    }
    
    func getHabitStreak(_ habit: Habit) -> Int {
        guard let completionDates = habit.completionDates as? [Date] else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var streak = 0
        var currentDate = today
        
        while completionDates.contains(where: { calendar.isDate($0, inSameDayAs: currentDate) }) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
    
    // MARK: - UserDefaults for App Group
    
    private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }
    
    var globalReminderTime: Date? {
        get {
            return userDefaults.object(forKey: "globalReminderTime") as? Date
        }
        set {
            userDefaults.set(newValue, forKey: "globalReminderTime")
        }
    }
    
    var isGlobalReminderEnabled: Bool {
        get {
            return userDefaults.bool(forKey: "isGlobalReminderEnabled")
        }
        set {
            userDefaults.set(newValue, forKey: "isGlobalReminderEnabled")
        }
    }
    
    var isEveningReminderEnabled: Bool {
        get {
            // Check if this is the first time accessing this setting
            if userDefaults.object(forKey: "isEveningReminderEnabled") == nil {
                // First time - enable evening reminders by default
                userDefaults.set(true, forKey: "isEveningReminderEnabled")
                return true
            }
            return userDefaults.bool(forKey: "isEveningReminderEnabled")
        }
        set {
            userDefaults.set(newValue, forKey: "isEveningReminderEnabled")
        }
    }
    
    var eveningReminderTime: Date {
        get {
            if let time = userDefaults.object(forKey: "eveningReminderTime") as? Date {
                return time
            }
            // Default to 9 PM
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = 21
            components.minute = 0
            return calendar.date(from: components) ?? Date()
        }
        set {
            userDefaults.set(newValue, forKey: "eveningReminderTime")
        }
    }
    
    // MARK: - Incomplete Habits Tracking
    
    func getIncompleteHabitsForToday() -> [Habit] {
        let habits = fetchActiveHabits()
        return habits.filter { !isHabitCompleted($0) }
    }
    
    func getCompletionRateForToday() -> Double {
        let habits = fetchActiveHabits()
        guard !habits.isEmpty else { return 1.0 }
        
        let completedCount = habits.filter { isHabitCompleted($0) }.count
        return Double(completedCount) / Double(habits.count)
    }
}
