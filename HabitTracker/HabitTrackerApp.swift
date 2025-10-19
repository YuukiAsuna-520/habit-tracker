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
    @State private var notificationDelegate: NotificationDelegate?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    setupNotifications()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Handle notification responses when app becomes active
                    handleNotificationResponses()
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
    
    private func handleNotificationResponses() {
        // Set up notification response handler
        notificationDelegate = NotificationDelegate(notificationManager: notificationManager)
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
}

// MARK: - Notification Delegate
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let notificationManager: NotificationManager
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
        super.init()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        notificationManager.handleNotificationResponse(response)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
