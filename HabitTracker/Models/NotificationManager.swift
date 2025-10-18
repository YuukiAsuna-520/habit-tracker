//
//  NotificationManager.swift
//  HabitTracker
//
//  Created by Soorya Sanand on 15/10/2025.
//

import Foundation
import UserNotifications
import CoreData
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let dataManager = SharedDataManager.shared
    
    private init() {}
    
    // MARK: - Permission Management
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    func checkNotificationPermission() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Notification Scheduling
    
    func scheduleHabitReminders() {
        // Cancel all existing habit notifications
        cancelAllHabitNotifications()
        
        let habits = dataManager.fetchActiveHabits()
        
        if dataManager.isGlobalReminderEnabled, let globalTime = dataManager.globalReminderTime {
            // Schedule global reminder for all habits
            scheduleGlobalReminder(for: habits, at: globalTime)
        } else {
            // Schedule individual reminders for habits that have them
            for habit in habits {
                if !habit.hasGlobalReminder, let reminderTime = habit.reminderTime {
                    scheduleIndividualReminder(for: habit, at: reminderTime)
                }
            }
        }
    }
    
    private func scheduleGlobalReminder(for habits: [Habit], at time: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Habit Reminder"
        content.body = "Don't forget to complete your habits today!"
        content.sound = .default
        content.categoryIdentifier = "HABIT_REMINDER"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "global_habit_reminder", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling global reminder: \(error)")
            }
        }
    }
    
    private func scheduleIndividualReminder(for habit: Habit, at time: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time to work on: \(habit.tittle ?? "Your habit")"
        content.sound = .default
        content.categoryIdentifier = "HABIT_REMINDER"
        content.userInfo = ["habitId": habit.id?.uuidString ?? ""]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "habit_\(habit.id?.uuidString ?? UUID().uuidString)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling individual reminder: \(error)")
            }
        }
    }
    
    func cancelAllHabitNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(for habit: Habit) {
        let identifier = "habit_\(habit.id?.uuidString ?? UUID().uuidString)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Notification Categories and Actions
    
    func setupNotificationCategories() {
        let markDoneAction = UNNotificationAction(
            identifier: "MARK_DONE",
            title: "Mark Done",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze 15m",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "HABIT_REMINDER",
            actions: [markDoneAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([category])
    }
    
    // MARK: - Handle Notification Actions
    
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "MARK_DONE":
            if let habitIdString = userInfo["habitId"] as? String,
               let habitId = UUID(uuidString: habitIdString) {
                markHabitCompleteFromNotification(habitId: habitId)
            }
        case "SNOOZE":
            if let habitIdString = userInfo["habitId"] as? String,
               let habitId = UUID(uuidString: habitIdString) {
                snoozeHabitReminder(habitId: habitId)
            }
        default:
            break
        }
    }
    
    private func markHabitCompleteFromNotification(habitId: UUID) {
        let habits = dataManager.fetchActiveHabits()
        if let habit = habits.first(where: { $0.id == habitId }) {
            dataManager.markHabitComplete(habit)
        }
    }
    
    private func snoozeHabitReminder(habitId: UUID) {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Don't forget to complete your habit!"
        content.sound = .default
        content.categoryIdentifier = "HABIT_REMINDER"
        content.userInfo = ["habitId": habitId.uuidString]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15 * 60, repeats: false) // 15 minutes
        let request = UNNotificationRequest(identifier: "snooze_\(habitId.uuidString)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling snooze: \(error)")
            }
        }
    }
}
