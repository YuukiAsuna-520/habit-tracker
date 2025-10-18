//
//  ContentView.swift
//  HabitTracker
//
//  Created by Yash Patil on 17/10/2025.
//


import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Today")
                }
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
