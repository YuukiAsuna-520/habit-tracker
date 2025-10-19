
//
//  TodayView.swift
//  HabitTracker
//
//  Created by Yash Patil on 17/10/2025.
//

import SwiftUI
import CoreData

struct TodayView: View {
    @Environment(\.managedObjectContext) private var ctx
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.createdAt, ascending: true)],
        predicate: NSPredicate(format: "isArchived == NO")
    )
    private var habits: FetchedResults<Habit>
    
    @StateObject private var dataManager = SharedDataManager.shared
    @State private var showNew = false

    var body: some View {
        NavigationStack {
            VStack {
                if habits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No habits yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Tap the + button to create your first habit")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(habits) { habit in
                            HabitRow(habit: habit)
                        }
                        .onDelete(perform: deleteHabit)
                    }
                }
            }
            .animation(.easeInOut, value: habits.count)
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showNew = true } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showNew) {
                NavigationStack {
                    HabitEditView()
                }
            }
        }
    }

    private func deleteHabit(at offsets: IndexSet) {
        withAnimation {
            offsets.map { habits[$0] }.forEach { habit in
                // Archive instead of delete
                habit.isArchived = true
            }
            try? ctx.save()
        }
    }
}
