//
//  HabitTrackerTests.swift
//  HabitTrackerTests
//
//  Created by Tingxuan Zhang on 15/10/2025.
//

import XCTest
import CoreData
@testable import HabitTracker

final class HabitTrackerTests: XCTestCase {

    var controller: PersistenceController!
    var ctx: NSManagedObjectContext!

    override func setUpWithError() throws {
        controller = PersistenceController(inMemory: true)
        ctx = controller.container.viewContext
    }

    override func tearDownWithError() throws {
        controller = nil
        ctx = nil
    }

    func testCreateHabitAndFetch() throws {
        let h = Habit(context: ctx)
        h.id = UUID()
        h.tittle = "Read"
        h.createdAt = Date()
        h.isArchived = false

        try ctx.save()

        let req: NSFetchRequest<Habit> = Habit.fetchRequest()
        req.predicate = NSPredicate(format: "tittle == %@", "Read")

        let result = try ctx.fetch(req)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.tittle, "Read")
    }

    func testMarkCompleteAndIncomplete() throws {
        let h = Habit(context: ctx)
        h.id = UUID()
        h.tittle = "Drink"
        h.createdAt = Date()
        h.isArchived = false
        h.completionDates = [] as NSArray
        try ctx.save()

        // Stimulate SharedDataManager done/calcelled
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        // done
        var dates = (h.completionDates as? [Date]) ?? []
        dates.append(today)
        h.completionDates = dates as NSArray
        try ctx.save()

        let afterComplete = (h.completionDates as? [Date])?.contains(where: { cal.isDate($0, inSameDayAs: today) }) ?? false
        XCTAssertTrue(afterComplete)

        // cancelled
        dates.removeAll { cal.isDate($0, inSameDayAs: today) }
        h.completionDates = dates as NSArray
        try ctx.save()

        let afterUndo = (h.completionDates as? [Date])?.contains(where: { cal.isDate($0, inSameDayAs: today) }) ?? false
        XCTAssertFalse(afterUndo)
    }

    func testStreakCalculation() throws {
        let h = Habit(context: ctx)
        h.id = UUID()
        h.tittle = "Walk"
        h.createdAt = Date()
        h.isArchived = false

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = cal.date(byAdding: .day, value: -2, to: today)!

        // 3 days streak
        h.completionDates = [twoDaysAgo, yesterday, today] as NSArray
        try ctx.save()

        var streak = 0
        var cursor = today
        let dates = h.completionDates as! [Date]
        while dates.contains(where: { cal.isDate($0, inSameDayAs: cursor) }) {
            streak += 1
            cursor = cal.date(byAdding: .day, value: -1, to: cursor)!
        }
        XCTAssertEqual(streak, 3)
    }

    func testCompletionRate30DaysWindow() throws {
        let h = Habit(context: ctx)
        h.id = UUID()
        h.tittle = "Meditate"
        h.createdAt = Date()
        h.isArchived = false

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // completed 3 says in past month
        h.completionDates = [
            today,
            cal.date(byAdding: .day, value: -5, to: today)!,
            cal.date(byAdding: .day, value: -12, to: today)!
        ] as NSArray

        let start = cal.date(byAdding: .day, value: -30, to: today)!
        let days = max((cal.dateComponents([.day], from: start, to: today).day ?? 1), 1)
        let completed = (h.completionDates as! [Date]).filter {
            (cal.dateComponents([.day], from: start, to: $0).day ?? -1) >= 0
        }.count
        let rate = Double(completed) / Double(days)

        XCTAssertGreaterThan(rate, 0)      // have progress
        XCTAssertLessThan(rate, 1)         // won't be full
    }
}
