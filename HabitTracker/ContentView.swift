//
//  ContentView.swift
//  HabitTracker
//
//  Created by Yash Patil on 17/10/2025.
//
//This project was created by Soorya Sanand, Yash Patil, Tingxuan Zhang, Grace Cen.


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
