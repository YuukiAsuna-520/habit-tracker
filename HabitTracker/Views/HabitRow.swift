//
//  HabitRow.swift
//  HabitTracker
//
//  Created by Soorya Sanand and Tingxuan Zhang on 15/10/2025.
//

import SwiftUI
import CoreData

struct HabitRow: View {
    @ObservedObject var habit: Habit
    @StateObject private var dataManager = SharedDataManager.shared
    
    @State private var checkScale: CGFloat = 1.0
    
    var body: some View {
        HStack {
            // Completion checkbox
            Button(action: {
                toggleCompletion()
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .gray)
                    .font(.title2)
                    .scaleEffect(checkScale)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: checkScale)
                    .symbolEffect(.bounce, value: isCompleted)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                // Habit title
                Text(habit.tittle ?? "Untitled Habit")
                    .font(.headline)
                    .strikethrough(isCompleted)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                
                // Streak information
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("\(streakCount) day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Reminder indicator
            if hasReminder {
                Image(systemName: "bell.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var isCompleted: Bool {
        dataManager.isHabitCompleted(habit)
    }
    
    private var streakCount: Int {
        dataManager.getHabitStreak(habit)
    }
    
    private var hasReminder: Bool {
        if habit.hasGlobalReminder {
            return dataManager.isGlobalReminderEnabled
        } else {
            return habit.reminderTime != nil
        }
    }
    
    private func toggleCompletion() {
        if isCompleted {
            dataManager.markHabitIncomplete(habit)
        } else {
            dataManager.markHabitComplete(habit)

            #if canImport(UIKit)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif

            checkScale = 1.2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                checkScale = 1.0
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let habit = Habit(context: context)
    habit.tittle = "Drink Water"
    habit.createdAt = Date()
    habit.id = UUID()
    habit.hasGlobalReminder = true
    
    return HabitRow(habit: habit)
        .environment(\.managedObjectContext, context)
}
