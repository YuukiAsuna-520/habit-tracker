//
//  HabitEditView.swift
//  HabitTracker
//
//  Created by Yash Patil on 17/10/2025.
//
import SwiftUI

struct HabitEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var targetPerDay = 1.0
    @State private var reminderHour = 8

    var onSave: ((Habit) -> Void)?

    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $title)
                Stepper(value: $targetPerDay, in: 1...100, step: 1) {
                    Text("Target per day: \(Int(targetPerDay))")
                }
            }

            Section("Reminder") {
                Stepper(value: $reminderHour, in: 5...22) {
                    Text("Daily at \(reminderHour):00")
                }
            }
        }
        .navigationTitle("New Habit")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    let habit = Habit(title: title,
                                      targetPerDay: targetPerDay,
                                      reminderHour: reminderHour)
                    onSave?(habit)
                    dismiss()
                }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
