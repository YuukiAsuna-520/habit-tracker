//
//  HabitEditView.swift
//  HabitTracker
//
//  Created by Yash Patil on 17/10/2025.
//
import SwiftUI
import CoreData

struct HabitEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var dataManager = SharedDataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var habitTitle = ""
    @State private var hasIndividualReminder = false
    @State private var reminderTime = Date()
    @State private var isSaving = false
    
    let habit: Habit?
    
    init(habit: Habit? = nil) {
        self.habit = habit
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Habit name", text: $habitTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("habitNameField")
                }
                
                Section("Reminder Settings") {
                    Toggle("Enable reminder for this habit", isOn: $hasIndividualReminder)
                    
                    if hasIndividualReminder {
                        DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                    }
                }
            }
            .navigationTitle(habit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .accessibilityIdentifier("saveHabitButton")
                    .disabled(habitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    private func setupInitialValues() {
        if let habit = habit {
            habitTitle = habit.tittle ?? ""
            hasIndividualReminder = habit.reminderTime != nil
            if let reminderTime = habit.reminderTime {
                self.reminderTime = reminderTime
            }
        } else {
            // Default values for new habit
            hasIndividualReminder = false
            // Set default reminder time to 9 AM
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            reminderTime = calendar.date(from: components) ?? Date()
        }
    }
    
    private func saveHabit() {
        guard !isSaving else { return }
        isSaving = true
        
        let trimmedTitle = habitTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { 
            isSaving = false
            return 
        }
        
        let habitToSave: Habit
        if let existingHabit = habit {
            habitToSave = existingHabit
        } else {
            habitToSave = Habit(context: viewContext)
            habitToSave.id = UUID()
            habitToSave.createdAt = Date()
        }
        
        habitToSave.tittle = trimmedTitle
        
        // Set individual reminder time if enabled
        if hasIndividualReminder {
            habitToSave.reminderTime = reminderTime
            habitToSave.hasGlobalReminder = false
        } else {
            habitToSave.reminderTime = nil
            habitToSave.hasGlobalReminder = false
        }
        
        do {
            try viewContext.save()
            
            // Schedule notifications for this specific habit
            if hasIndividualReminder {
                // Request notification permission first
                Task {
                    let granted = await notificationManager.requestNotificationPermission()
                    if granted {
                        notificationManager.scheduleIndividualReminder(for: habitToSave, at: reminderTime)
                    } else {
                        print("Notification permission denied")
                    }
                }
            } else {
                notificationManager.cancelNotification(for: habitToSave)
            }
            
            dismiss()
        } catch {
            print("Error saving habit: \(error)")
        }
        
        isSaving = false
    }
}

#Preview {
    HabitEditView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
