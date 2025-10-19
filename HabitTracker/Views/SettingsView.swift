//
//  SettingsView.swift
//  HabitTracker
//
//  Created by Soorya Sanand on 15/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataManager = SharedDataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var isEveningReminderEnabled = false
    @State private var eveningReminderTime = Date()
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Daily Completion Reminder") {
                    Toggle("Enable Daily Completion Reminder", isOn: $isEveningReminderEnabled)
                        .onChange(of: isEveningReminderEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            } else {
                                dataManager.isEveningReminderEnabled = false
                                notificationManager.scheduleHabitReminders()
                            }
                        }
                    
                    if isEveningReminderEnabled {
                        DatePicker("Reminder Time", selection: $eveningReminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: eveningReminderTime) { _, newValue in
                                dataManager.eveningReminderTime = newValue
                                dataManager.isEveningReminderEnabled = true
                                notificationManager.scheduleHabitReminders()
                            }
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadSettings()
            }
            .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable notifications in Settings to receive habit reminders.")
            }
        }
    }
    
    private func loadSettings() {
        isEveningReminderEnabled = dataManager.isEveningReminderEnabled
        eveningReminderTime = dataManager.eveningReminderTime
    }
    
    private func requestNotificationPermission() {
        Task {
            let granted = await notificationManager.requestNotificationPermission()
            if granted {
                // Update the settings that were just enabled
                if isEveningReminderEnabled {
                    dataManager.isEveningReminderEnabled = true
                    dataManager.eveningReminderTime = eveningReminderTime
                }
                notificationManager.setupNotificationCategories()
                notificationManager.scheduleHabitReminders()
            } else {
                await MainActor.run {
                    // Reset the toggles if permission was denied
                    isEveningReminderEnabled = false
                    showingPermissionAlert = true
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
