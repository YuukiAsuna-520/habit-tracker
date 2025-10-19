//
//  StatsView.swift
//  HabitTracker
//
//  Created by Yash Patil on 17/10/2025.
//
import SwiftUI
import Charts
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.createdAt, ascending: true)],
        predicate: NSPredicate(format: "isArchived == NO")
    )
    private var habits: FetchedResults<Habit>
    
    @StateObject private var dataManager = SharedDataManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if habits.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "chart.bar")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No habits to track")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("Create some habits to see your progress here")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        // Overall Progress Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Progress")
                                .font(.headline)
                            
                            let completedToday = habits.filter { dataManager.isHabitCompleted($0) }.count
                            let totalHabits = habits.count
                            let progress = totalHabits > 0 ? Double(completedToday) / Double(totalHabits) : 0.0
                            
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            
                            Text("\(completedToday) of \(totalHabits) habits completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Individual Habit Stats
                        LazyVStack(spacing: 12) {
                            ForEach(habits) { habit in
                                HabitStatsCard(habit: habit)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
        }
    }
}

struct HabitStatsCard: View {
    @ObservedObject var habit: Habit
    @StateObject private var dataManager = SharedDataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(habit.tittle ?? "Untitled Habit")
                    .font(.headline)
                
                Spacer()
                
                if dataManager.isHabitCompleted(habit) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(dataManager.getHabitStreak(habit)) days")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Completion Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    let completionRate = calculateCompletionRate()
                    Text("\(Int(completionRate * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(completionRate >= 0.8 ? .green : completionRate >= 0.5 ? .orange : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func calculateCompletionRate() -> Double {
        guard let completionDates = habit.completionDates as? [Date],
              !completionDates.isEmpty else { return 0.0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        
        let daysInRange = calendar.dateComponents([.day], from: startDate, to: today).day ?? 1
        let completedDays = completionDates.filter { date in
            calendar.dateComponents([.day], from: startDate, to: date).day ?? 0 >= 0
        }.count
        
        return Double(completedDays) / Double(daysInRange)
    }
}

#Preview {
    StatsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
