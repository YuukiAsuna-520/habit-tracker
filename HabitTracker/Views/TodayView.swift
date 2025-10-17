//
//  TodayView.swift
//  HabitTracker
//
//  Created by 黑白熊 on 15/10/2025.
//

import SwiftUI

import SwiftUICore

struct TodayView: View {
    @Environment(\.managedObjectContext) private var ctx
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Habit.createdAt, ascending: true)],
                  predicate: NSPredicate(format: "isArchived == NO"))
    private var habits: FetchedResults<Habit>

    var body: some View {
        NavigationStack {
            List {
                ForEach(habits) { habit in
                    HabitRow(habit: habit)
                }.onDelete(perform: deleteHabit)
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: HabitEditView()) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }

    private func deleteHabit(at offsets: IndexSet) {
        offsets.map { habits[$0] }.forEach(ctx.delete)
        try? ctx.save()
    }
}
