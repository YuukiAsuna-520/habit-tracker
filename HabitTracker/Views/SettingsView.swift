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
    
    @State private var isGlobalReminderEnabled = false
    @State private var globalReminderTime = Date()
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Enable Daily Reminders", isOn: $isGlobalReminderEnabled)
                        .onChange(of: isGlobalReminderEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            } else {
                                dataManager.isGlobalReminderEnabled = false
                                notificationManager.cancelAllHabitNotifications()
                            }
                        }
                    
                    if isGlobalReminderEnabled {
                        DatePicker("Reminder Time", selection: $globalReminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: globalReminderTime) { _, newValue in
                                dataManager.globalReminderTime = newValue
                                dataManager.isGlobalReminderEnabled = true
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
                    
                    HStack {
                        Text("App Group")
                        Spacer()
                        Text("group.com.Tingxuan.Zhang.HabitTracker")
                            .foregroundColor(.secondary)
                            .font(.caption)
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
                Button("Cancel", role: .cancel) {
                    isGlobalReminderEnabled = false
                }
            } message: {
                Text("Please enable notifications in Settings to receive habit reminders.")
            }
        }
    }
    
    private func loadSettings() {
        isGlobalReminderEnabled = dataManager.isGlobalReminderEnabled
        globalReminderTime = dataManager.globalReminderTime ?? Date()
    }
    
    private func requestNotificationPermission() {
        Task {
            let granted = await notificationManager.requestNotificationPermission()
            if granted {
                dataManager.isGlobalReminderEnabled = true
                dataManager.globalReminderTime = globalReminderTime
                notificationManager.setupNotificationCategories()
                notificationManager.scheduleHabitReminders()
            } else {
                await MainActor.run {
                    showingPermissionAlert = true
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
