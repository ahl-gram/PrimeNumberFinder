import XCTest
import SwiftUI
@testable import PrimeFinderApp

final class FontScalingTests: XCTestCase {
    // Test helper to invoke the font scaling function in ContentView
    private func calculateFontSize(for inputLength: Int) -> CGFloat {
        let tempView = ContentView()
        return tempView.calculateFontSize(for: inputLength)
    }
    
    // MARK: - Font Scaling Tests
    
    func testFontScalingForShortInput() {
        // For short inputs, should use the title size
        let titleSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
        
        // Test with single digit
        let size1 = calculateFontSize(for: 1)
        XCTAssertEqual(size1, titleSize, "Font size for single digit should match the title size")
        
        // Test with 10 digits (below threshold for all font sizes)
        let size10 = calculateFontSize(for: 10)
        XCTAssertEqual(size10, titleSize, "Font size for 10 digits should match the title size")
    }
    
    func testFontScalingForLongInput() {
        // Get the base sizes for comparison
        let titleSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
        let minSize = UIFont.preferredFont(forTextStyle: .callout).pointSize
        
        // Test with very long input (significantly above threshold)
        let size30 = calculateFontSize(for: 30)
        
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
        let sizeAtThreshold = calculateFontSize(for: expectedThreshold)
        let sizeAboveThreshold = calculateFontSize(for: expectedThreshold + 1)
        
        // At threshold, should be full size; above threshold, should be reduced
        XCTAssertEqual(sizeAtThreshold, titleSize, "Font size at threshold should match title size")
        XCTAssertLessThan(sizeAboveThreshold, titleSize, "Font size above threshold should be reduced")
    }
    
    func testScalingRate() {
        // Get the title size to determine which scaling rate applies
        let titleSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
        
        // Determine expected scaling rates
        let expectedRate: CGFloat
        if titleSize <= 20 {
            expectedRate = 0.015  // 1.5% for very small text
        } else if titleSize <= 25 {
            expectedRate = 0.02   // 2% for small text
        } else {
            expectedRate = min(0.025, 0.02 + (titleSize / 1000)) // Up to 2.5% for larger text
        }
        
        // Get the threshold
        let threshold: Int
        if titleSize <= 20 {
            threshold = 18  // Very small text threshold
        } else if titleSize <= 25 {
            threshold = 16  // Small text threshold
        } else if titleSize <= 30 {
            threshold = 14  // Medium text threshold
        } else {
            threshold = 12  // Large text threshold
        }
        
        // Calculate expected size with scaling
        let extraDigits: CGFloat = 5.0 // Test with 5 extra digits
        let expected = titleSize * (1.0 - (extraDigits * expectedRate))
        
        // Get actual size
        let actual = calculateFontSize(for: threshold + Int(extraDigits))
        
        // Should be reasonably close 
        // (there might be slight differences due to minimum size constraints)
        XCTAssertEqual(actual / expected, 1.0, accuracy: 0.1, 
                       "Scaling rate should match expected value within 10% margin")
    }
} 