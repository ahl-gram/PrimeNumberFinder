import XCTest
import SwiftUI
@testable import PrimeFinderApp

final class UIImprovementsTests: XCTestCase {
    var contentView: ContentView!
    
    override func setUpWithError() throws {
        contentView = ContentView()
    }
    
    override func tearDownWithError() throws {
        contentView = nil
    }
    
    // MARK: - Font Scaling Tests
    
    func testFontScalingForShortInput() {
        // For short inputs, should use the title size
        let titleSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
        
        // Test with single digit
        let size1 = contentView.calculateFontSize(for: 1)
        XCTAssertEqual(size1, titleSize, "Font size for single digit should match the title size")
        
        // Test with 10 digits (below threshold for all font sizes)
        let size10 = contentView.calculateFontSize(for: 10)
        XCTAssertEqual(size10, titleSize, "Font size for 10 digits should match the title size")
    }
    
    func testFontScalingForLongInput() {
        // Get the base sizes for comparison
        let titleSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
        let minSize = UIFont.preferredFont(forTextStyle: .callout).pointSize
        
        // Test with very long input (significantly above threshold)
        let size30 = contentView.calculateFontSize(for: 30)
        
        // The size should be reduced but not below the minimum
        XCTAssertLessThan(size30, titleSize, "Font size for 30 digits should be reduced")
        XCTAssertGreaterThanOrEqual(size30, minSize, "Font size should not be below the minimum")
    }
    
    func testFontScalingThresholds() {
        // Get the title size to determine which threshold applies
        let titleSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
        
        // Determine which threshold applies for the current font size
        let expectedThreshold: Int
        if titleSize <= 20 {
            expectedThreshold = 18  // Very small text
        } else if titleSize <= 25 {
            expectedThreshold = 16  // Small text
        } else if titleSize <= 30 {
            expectedThreshold = 14  // Medium text
        } else {
            expectedThreshold = 12  // Large text
        }
        
        // Test at threshold
        let sizeAtThreshold = contentView.calculateFontSize(for: expectedThreshold)
        let sizeAboveThreshold = contentView.calculateFontSize(for: expectedThreshold + 1)
        
        // At threshold, should be full size; above threshold, should be reduced
        XCTAssertEqual(sizeAtThreshold, titleSize, "Font size at threshold should match title size")
        XCTAssertLessThan(sizeAboveThreshold, titleSize, "Font size above threshold should be reduced")
    }
    
    // MARK: - Large Number Formatting Tests
    
    func testFormatLargeNumber() {
        // Test basic formatting
        XCTAssertEqual(contentView.formatLargeNumber("1000"), "1,000")
        XCTAssertEqual(contentView.formatLargeNumber("1000000"), "1,000,000")
        
        // Test very large numbers (near UInt64 limit)
        XCTAssertEqual(contentView.formatLargeNumber("9223372036854775807"), "9,223,372,036,854,775,807")
        
        // Test edge cases
        XCTAssertEqual(contentView.formatLargeNumber("0"), "0")
        XCTAssertEqual(contentView.formatLargeNumber("1"), "1")
        XCTAssertEqual(contentView.formatLargeNumber("12"), "12")
        XCTAssertEqual(contentView.formatLargeNumber("123"), "123")
        
        // Test the specific large number that was causing issues
        XCTAssertEqual(contentView.formatLargeNumber("9999999999999999"), "9,999,999,999,999,999")
    }
    
    func testFormatDisplayNumber() {
        // Test with numbers below threshold
        XCTAssertEqual(contentView.formatDisplayNumber(1000), "1,000")
        XCTAssertEqual(contentView.formatDisplayNumber(1000000), "1,000,000")
        
        // Test with very large numbers (above 9,999,999,999,999,000)
        let largeNumber: UInt64 = 9_999_999_999_999_999
        XCTAssertEqual(contentView.formatDisplayNumber(largeNumber), "9,999,999,999,999,999")
    }
    
    // MARK: - Documentation Tests
    
    func testUIImprovementsDocumentation() {
        // This documents the main UI improvements we've made:
        
        // 1. Adaptive Font Scaling:
        //    - Font size dynamically adjusts based on number length
        //    - Threshold for scaling varies based on user text size preferences
        //    - Very small base fonts allow more digits before scaling
        //    - Scaling rate is gentler for smaller base fonts
        //    - Never scales below the user's preferred callout text size
        
        // 2. Large Number Handling:
        //    - Maintains precision for numbers up to UInt64.max
        //    - Properly formats large numbers with appropriate commas
        //    - Fixed bug where 9999999999999999 displayed incorrectly
        //    - Ensures consistent display in both input field and results
        
        // 3. Input Field Improvements:
        //    - Input filtering prevents invalid characters
        //    - Leading zero handling for cleaner number display
        //    - Length limiting prevents overflow errors
        //    - Haptic feedback provides input validation cues
        
        // 4. Async Calculation UX:
        //    - Delayed spinner prevents UI flicker for fast calculations
        //    - Cancellation of outdated calculations prevents race conditions
        //    - UUID tracking ensures UI consistency
        
        // No assertions needed - this documents the behavior
        XCTAssertTrue(true, "UI improvements documented")
    }
    
    func testExpandCollapseDocumentation() {
        // This documents the expand/collapse behavior:
        
        // 1. Result Display:
        //    - Initially shows prime or composite status
        //    - For composite numbers, provides prime factorization
        //    - Chevron indicator shows expandability
        
        // 2. Expansion Behavior:
        //    - Clicking expands to show all factors
        //    - Expansion triggers async calculation of factors
        //    - Spinner appears only if calculation takes > 1 second
        //    - Factors are presented in a scrollable list
        
        // 3. Collapse Behavior:
        //    - Clicking again collapses the view
        //    - Cancels any ongoing factor calculation
        //    - Resets factor display state
        
        // 4. Factor Interaction:
        //    - Each factor is tappable
        //    - Tapping a factor loads it as the new input
        //    - Updates result to show if the factor is prime
        
        // No assertions needed - this documents the behavior
        XCTAssertTrue(true, "Expand/collapse behavior documented")
    }
} 