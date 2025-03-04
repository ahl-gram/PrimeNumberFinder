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
} 