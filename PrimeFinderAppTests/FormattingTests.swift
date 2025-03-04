import XCTest
import SwiftUI
@testable import PrimeFinderApp

final class FormattingTests: XCTestCase {
    // Test helper to invoke the formatting function in ContentView
    private func formatLargeNumber(_ input: String) -> String {
        let tempView = ContentView()
        return tempView.formatLargeNumber(input)
    }
    
    private func formatDisplayNumber(_ input: UInt64) -> String {
        let tempView = ContentView()
        return tempView.formatDisplayNumber(input)
    }
    
    // MARK: - Large Number Formatting Tests
    
    func testFormatLargeNumber() {
        // Test basic formatting
        XCTAssertEqual(formatLargeNumber("1000"), "1,000")
        XCTAssertEqual(formatLargeNumber("1000000"), "1,000,000")
        
        // Test very large numbers (near UInt64 limit)
        XCTAssertEqual(formatLargeNumber("9223372036854775807"), "9,223,372,036,854,775,807")
        
        // Test edge cases
        XCTAssertEqual(formatLargeNumber("0"), "0")
        XCTAssertEqual(formatLargeNumber("1"), "1")
        XCTAssertEqual(formatLargeNumber("12"), "12")
        XCTAssertEqual(formatLargeNumber("123"), "123")
        
        // Test the specific large number that was causing issues
        XCTAssertEqual(formatLargeNumber("9999999999999999"), "9,999,999,999,999,999")
    }
    
    func testFormatDisplayNumber() {
        // Test with numbers below threshold
        XCTAssertEqual(formatDisplayNumber(1000), "1,000")
        XCTAssertEqual(formatDisplayNumber(1000000), "1,000,000")
        
        // Test with very large numbers (above 9,999,999,999,999,000)
        let largeNumber: UInt64 = 9_999_999_999_999_999
        XCTAssertEqual(formatDisplayNumber(largeNumber), "9,999,999,999,999,999")
    }
} 