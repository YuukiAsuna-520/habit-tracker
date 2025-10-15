//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by 黑白熊 on 15/10/2025.
//

import SwiftUI
import CoreData

@main
struct HabitTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
