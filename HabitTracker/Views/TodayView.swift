
//
//  TodayView.swift
//  HabitTracker
//
//  Created by Yash Patil on 17/10/2025.
//

import SwiftUI

struct TodayView: View {
    @State private var habits: [Habit] = [
        Habit(title: "Drink Water", progress: 0.0),
        Habit(title: "Read 20 pages", progress: 0.0),
        Habit(title: "Workout", progress: 0.0)
    ]
    @State private var showNew = false

    var body: some View {
        NavigationStack {
            List {
                if habits.isEmpty {
                    ContentUnavailableView(
                        "No habits yet",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Tap + to add your first habit.")
                    )
                } else {
                    ForEach($habits) { $habit in
                        HStack {
                     
                            Button {
                                habit.progress = habit.progress >= 1 ? 0 : 1
                            } label: {
                                Image(systemName: habit.progress >= 1 ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 26))
                                    .foregroundStyle(habit.progress >= 1 ? .green : .gray.opacity(0.6))
                                    .animation(.spring(response: 0.3), value: habit.progress)
                            }
                            .buttonStyle(.plain)

                            VStack(alignment: .leading) {
                                Text(habit.title)
                                    .font(.headline)
                                if habit.progress >= 1 {
                                    Text("Completed today")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Tap to complete")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                           
                            if habit.progress >= 1 {
                                Text("🔥")
                                    .font(.title3)
                                    .transition(.scale)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { idx in habits.remove(atOffsets: idx) }
                }
            }
            .animation(.easeInOut, value: habits)
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
                    HabitEditView { newHabit in
                        habits.append(newHabit)
                    }
                }
            }
        }
    }
}
