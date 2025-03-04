import XCTest
import SwiftUI
@testable import PrimeFinderApp

final class LargeNumberTests: XCTestCase {
    
    // MARK: - Type Conversion Tests
    
    func testLargeNumberStringConversion() {
        // Test the specific issue we fixed with very large numbers
        // The app was previously incorrectly displaying 9999999999999999 as 10000000000000000
        
        // 1. Verify string conversion is accurate for the problematic number
        let problemNumber = "9999999999999999"
        let asUInt64 = UInt64(problemNumber)
        XCTAssertNotNil(asUInt64, "Should be able to convert string to UInt64")
        XCTAssertEqual(asUInt64?.description, problemNumber, "Should convert back to same string")
        
        // 2. Verify formatting maintains precision
        let tempView = ContentView()
        let formatted = tempView.formatLargeNumber(problemNumber)
        XCTAssertEqual(formatted, "9,999,999,999,999,999", "Should format with commas without changing digits")
        
        // 3. Verify display formatter handles the value correctly
        if let number = asUInt64 {
            let display = tempView.formatDisplayNumber(number)
            XCTAssertEqual(display, "9,999,999,999,999,999", "Display formatting should preserve digits")
        }
    }
    
    func testPrecisionLimits() {
        // Test UInt64 range
        let maxUInt64 = UInt64.max
        let tempView = ContentView()
        let formatted = tempView.formatDisplayNumber(maxUInt64)
        
        // Verify we can handle full UInt64 range
        XCTAssertFalse(formatted.isEmpty, "Should be able to format maximum UInt64 value")
        XCTAssertFalse(formatted.contains("e+"), "Should not use scientific notation")
        
        // Verify we don't lose precision with our maximum input length
        let maxDigits = tempView.maxInputLength
        let maxAllowed = String(repeating: "9", count: maxDigits)
        let formattedMax = tempView.formatLargeNumber(maxAllowed)
        
        // Should have commas and correct length
        let expectedCommas = (maxDigits - 1) / 3
        let expectedLength = maxDigits + expectedCommas
        XCTAssertEqual(formattedMax.count, expectedLength, "Formatted length should match expected with commas")
    }
} 