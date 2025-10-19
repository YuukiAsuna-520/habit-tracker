//
//  StatsView.swift
//  HabitTracker
//
//  Created by Yash Patil on 17/10/2025.
//
import SwiftUI
import Charts

struct StatsView: View {
    @State private var data: [(Date, Int)] = [
        (Calendar.current.date(byAdding: .day, value: -6, to: Date())!, 3),
        (Calendar.current.date(byAdding: .day, value: -5, to: Date())!, 4),
        (Calendar.current.date(byAdding: .day, value: -4, to: Date())!, 2),
        (Calendar.current.date(byAdding: .day, value: -3, to: Date())!, 5),
        (Calendar.current.date(byAdding: .day, value: -2, to: Date())!, 4),
        (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 6),
        (Date(), 5)
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Stats")
                    .font(.largeTitle.bold())

                Text("Last 7 Days")
                    .font(.headline)

                Chart(data, id: \.0) { point in
                    BarMark(
                        x: .value("Date", point.0, unit: .day),
                        y: .value("Habits Done", point.1)
                    )
                    .foregroundStyle(.green)
                }
                .frame(height: 220)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                    }
                }

                Spacer()
                Text("🔥 Streak: 5 days").font(.headline)
                Text("Keep it up!").font(.subheadline).foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Stats")
        }
    }
}
