
//
//  TodayView.swift
//  HabitTracker
//
//  Created by Yash Patil and Tingxuan Zhang on 17/10/2025.
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

    @State private var showEdit = false
    @State private var editingHabit: Habit? = nil
    
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
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        delete(habit)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        editingHabit = habit
                                        showEdit = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.yellow)
                                }
                        }
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
                NavigationStack { HabitEditView() }
            }
            .sheet(isPresented: $showEdit) {
                if let habit = editingHabit {
                    NavigationStack { HabitEditView(habit: habit) }
                }
            }
        }
    }

    private func delete(_ habit: Habit) {
        withAnimation {
            habit.isArchived = true
            try? ctx.save()
        }
        NotificationManager.shared.cancelNotification(for: habit)
        NotificationManager.shared.scheduleHabitReminders()
    }
}
