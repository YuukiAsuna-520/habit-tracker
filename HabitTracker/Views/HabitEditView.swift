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
    @State private var isGlobalReminder = true
    
    let habit: Habit?
    
    init(habit: Habit? = nil) {
        self.habit = habit
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Habit Details") {
                    TextField("Habit name", text: $habitTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("Reminder Settings") {
                    Toggle("Use global reminder time", isOn: $isGlobalReminder)
                        .onChange(of: isGlobalReminder) { _, newValue in
                            hasIndividualReminder = !newValue
                        }
                    
                    if !isGlobalReminder {
                        Toggle("Set individual reminder", isOn: $hasIndividualReminder)
                        
                        if hasIndividualReminder {
                            DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        }
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
                    .disabled(habitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            isGlobalReminder = habit.hasGlobalReminder
            hasIndividualReminder = !habit.hasGlobalReminder && habit.reminderTime != nil
            if let reminderTime = habit.reminderTime {
                self.reminderTime = reminderTime
            }
        } else {
            // Default values for new habit
            isGlobalReminder = dataManager.isGlobalReminderEnabled
            hasIndividualReminder = false
        }
    }
    
    private func saveHabit() {
        let trimmedTitle = habitTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let habitToSave: Habit
        if let existingHabit = habit {
            habitToSave = existingHabit
        } else {
            habitToSave = Habit(context: viewContext)
            habitToSave.id = UUID()
            habitToSave.createdAt = Date()
        }
        
        habitToSave.tittle = trimmedTitle
        habitToSave.hasGlobalReminder = isGlobalReminder
        
        if isGlobalReminder {
            habitToSave.reminderTime = nil
        } else if hasIndividualReminder {
            habitToSave.reminderTime = reminderTime
        } else {
            habitToSave.reminderTime = nil
        }
        
        do {
            try viewContext.save()
            
            // Schedule notifications
            notificationManager.scheduleHabitReminders()
            
            dismiss()
        } catch {
            print("Error saving habit: \(error)")
        }
    }
}

#Preview {
    HabitEditView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
