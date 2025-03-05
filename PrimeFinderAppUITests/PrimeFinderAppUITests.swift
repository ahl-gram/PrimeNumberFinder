//
//  PrimeFinderAppUITests.swift
//  PrimeFinderAppUITests
//
//  Route 12B Software.
//

import XCTest

final class PrimeFinderAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Always stop immediately when a failure occurs in UI tests
        continueAfterFailure = false
        
        // UI tests should set up any required initial state before running
        // Examples:
        // - Interface orientation
        // - Permissions
        // - Initial app data
    }

    override func tearDownWithError() throws {
        // Clean up after each test if needed
        // Examples:
        // - Restore app state
        // - Clear any test data
    }

    // MARK: - Test Templates
    
    // This section previously contained example tests that didn't test actual functionality.
    // When adding new UI tests, consider the following patterns:
    
    /*
    @MainActor
    func testSpecificFeature() throws {
        // 1. Set up test prerequisites
        let app = XCUIApplication()
        app.launch()
        
        // 2. Perform UI interactions
        // app.buttons["Button Name"].tap()
        // app.textFields["Field Name"].typeText("Test input")
        
        // 3. Verify results with assertions
        // XCTAssert(app.staticTexts["Result Text"].exists)
    }
    */
    
    // Add your actual UI tests below
}

// Helper extension to tap at coordinates
extension XCUIApplication {
    func tapCoordinate(at point: CGPoint) {
        let normalized = coordinate(withNormalizedOffset: .zero)
        let coordinate = normalized.withOffset(CGVector(dx: point.x, dy: point.y))
        coordinate.tap()
    }
}
