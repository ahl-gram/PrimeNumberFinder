//
//  ScreenshotGenerator.swift
//  PrimeFinderAppUITests
//
//  Generates App Store screenshots by driving the app through key scenarios.
//

import XCTest

final class ScreenshotGenerator: XCTestCase {

    let screenshotDir = "/tmp/PrimeFinderScreenshots"
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        try FileManager.default.createDirectory(
            atPath: screenshotDir,
            withIntermediateDirectories: true
        )
    }

    private func saveScreenshot(named name: String) {
        Thread.sleep(forTimeInterval: 0.5)
        let screenshot = XCUIScreen.main.screenshot()
        let data = screenshot.pngRepresentation
        let path = "\(screenshotDir)/\(name).png"
        FileManager.default.createFile(atPath: path, contents: data)
    }

    private func tapInputField() {
        let inputField = app.staticTexts["Input Number Field"]
        XCTAssertTrue(inputField.waitForExistence(timeout: 3))
        inputField.tap()
        Thread.sleep(forTimeInterval: 0.5)
    }

    private func enterNumber(_ number: String) {
        tapInputField()
        for char in number {
            let key = app.keys[String(char)]
            XCTAssertTrue(key.waitForExistence(timeout: 3), "Key '\(char)' not found")
            key.tap()
        }
    }

    private func dismissKeyboard() {
        // Tap the navigation bar area to dismiss
        let navBar = app.navigationBars["Prime Number Finder"]
        if navBar.exists {
            navBar.tap()
        }
        Thread.sleep(forTimeInterval: 0.3)
    }

    private func clearInput() {
        // The clear button (xmark.circle.fill) only appears when there's input
        let clearButton = app.buttons.matching(identifier: "xmark.circle.fill").firstMatch
        if clearButton.exists && clearButton.isHittable {
            clearButton.tap()
            Thread.sleep(forTimeInterval: 0.3)
        }
    }

    private func tapCheck() {
        dismissKeyboard()
        let checkButton = app.buttons["Check Button"]
        XCTAssertTrue(checkButton.waitForExistence(timeout: 3))
        checkButton.tap()
        Thread.sleep(forTimeInterval: 0.5)
    }

    private func tapResultToExpand() {
        // Find the chevron down button on the result card for composite numbers
        let chevron = app.images["chevron.down.circle.fill"]
        if chevron.waitForExistence(timeout: 3) {
            chevron.tap()
        } else {
            // Fallback: tap by coordinate in the result card area
            let resultArea = app.otherElements["Result Text View"]
            if resultArea.waitForExistence(timeout: 3) {
                resultArea.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3)).tap()
            }
        }
        // Wait for factors to compute and animate in
        Thread.sleep(forTimeInterval: 2.0)
    }

    // MARK: - iPhone Screenshots

    @MainActor
    func testGenerateAppStoreScreenshots() throws {
        app.launch()
        Thread.sleep(forTimeInterval: 1.0)

        // Screenshot 1: 5040 with all factors expanded (60 factors, computes fast)
        enterNumber("5040")
        tapCheck()
        tapResultToExpand()
        saveScreenshot(named: "01_composite_5040_factors")

        // Screenshot 2: 1976 composite result
        clearInput()
        enterNumber("1976")
        tapCheck()
        saveScreenshot(named: "02_composite_1976")

        // Screenshot 3: Large prime
        clearInput()
        enterNumber("541500763259071739")
        tapCheck()
        saveScreenshot(named: "03_large_prime")

        // Screenshot 4: 7 - small prime
        clearInput()
        enterNumber("7")
        tapCheck()
        saveScreenshot(named: "04_prime_7")

        // Screenshot 5: 2520 with all factors expanded
        clearInput()
        enterNumber("2520")
        tapCheck()
        tapResultToExpand()
        saveScreenshot(named: "05_composite_2520_factors")

        // Screenshot 6: 42 composite result
        clearInput()
        enterNumber("42")
        tapCheck()
        saveScreenshot(named: "06_composite_42")

        // Screenshot 7: History view
        let historyButton = app.buttons["clock.arrow.circlepath"]
        XCTAssertTrue(historyButton.waitForExistence(timeout: 3))
        historyButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        saveScreenshot(named: "07_history")
    }

    // MARK: - iPad Screenshots

    @MainActor
    func testGenerateIPadScreenshots() throws {
        app.launch()
        Thread.sleep(forTimeInterval: 1.0)

        // Ensure portrait orientation
        XCUIDevice.shared.orientation = .portrait
        Thread.sleep(forTimeInterval: 1.0)

        // Screenshot 1: 941 in portrait
        enterNumber("941")
        tapCheck()
        saveScreenshot(named: "ipad_01_portrait_941")

        // Rotate to landscape
        XCUIDevice.shared.orientation = .landscapeLeft
        Thread.sleep(forTimeInterval: 1.0)

        // Screenshot 2: 942 in landscape
        clearInput()
        enterNumber("942")
        tapCheck()
        saveScreenshot(named: "ipad_02_landscape_942")

        // Screenshot 3: History in landscape
        let historyButton = app.buttons["clock.arrow.circlepath"]
        XCTAssertTrue(historyButton.waitForExistence(timeout: 3))
        historyButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        saveScreenshot(named: "ipad_03_landscape_history")
    }
}
