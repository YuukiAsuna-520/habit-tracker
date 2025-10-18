//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by 黑白熊 on 15/10/2025.
//

import SwiftUI
import CoreData
import UserNotifications

@main
struct HabitTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    setupNotifications()
                }
        }
    }
    
    private func setupNotifications() {
        notificationManager.setupNotificationCategories()
        
        // Request permission on first launch
        Task {
            let status = await notificationManager.checkNotificationPermission()
            if status == .notDetermined {
                _ = await notificationManager.requestNotificationPermission()
            }
        }
    }
}
