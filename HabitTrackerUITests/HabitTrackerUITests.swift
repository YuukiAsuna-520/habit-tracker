//
//  HabitTrackerUITests.swift
//  HabitTrackerUITests
//
//  Created by Tingxuan Zhang on 15/10/2025.
//

import XCTest

final class HabitTrackerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCreateEditDeleteHabitFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // 1) create a new one
        app.buttons["addHabitButton"].tap()
        let nameField = app.textFields["habitNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Read Book")
        app.buttons["saveHabitButton"].tap()

        // should appear in the list
        XCTAssertTrue(app.staticTexts["Read Book"].waitForExistence(timeout: 2))

        // 2) Edit（swap left → Edit）
        let cellLabel = app.staticTexts["Read Book"]
        cellLabel.swipeLeft()
        app.buttons["Edit"].tap()

        let nameField2 = app.textFields["habitNameField"]
        XCTAssertTrue(nameField2.waitForExistence(timeout: 2))
        nameField2.tap()
        nameField2.clearAndType("Read Novel")
        app.buttons["saveHabitButton"].tap()

        XCTAssertTrue(app.staticTexts["Read Novel"].waitForExistence(timeout: 2))

        // 3) Delete（swap left → Delete）
        let edited = app.staticTexts["Read Novel"]
        edited.swipeLeft()
        app.buttons["Delete"].tap()

        // won't appear
        XCTAssertFalse(edited.waitForExistence(timeout: 1.5))
    }
}

// delete input
private extension XCUIElement {
    func clearAndType(_ text: String) {
        guard self.exists, self.isHittable else { return }
        self.tap()
        if let value = self.value as? String {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count)
            self.typeText(deleteString)
        }
        self.typeText(text)
    }
}
