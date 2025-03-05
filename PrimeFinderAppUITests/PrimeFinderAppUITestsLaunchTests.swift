//
//  PrimeFinderAppUITestsLaunchTests.swift
//  PrimeFinderAppUITests
//
//  Route 12B Software.
//

import XCTest

/**
 * Launch Tests are specialized UI tests designed to:
 * 1. Verify the app launches successfully on all supported device configurations
 * 2. Capture screenshots of the app's launch state for documentation
 * 3. Detect issues that might only occur on specific device configurations
 */
final class PrimeFinderAppUITestsLaunchTests: XCTestCase {

    // This setting ensures the test runs for each supported device configuration
    // (e.g. different device sizes, orientations, and appearance modes)
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // You can add steps here to:
        // - Navigate to important screens
        // - Verify critical UI elements are displayed
        // - Capture screenshots at key points in the app

        // This captures and saves a screenshot of the app after launch
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Verify that the app launched successfully and shows its main UI
        // Example: XCTAssert(app.navigationBars["Prime Number Finder"].exists)
    }
}
