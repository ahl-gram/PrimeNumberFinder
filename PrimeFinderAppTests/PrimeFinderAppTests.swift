//
//  PrimeFinderAppTests.swift
//  PrimeFinderAppTests
//
//  Created by Alexander Lee on 2/8/25.
//

import XCTest
import SwiftUI
@testable import PrimeFinderApp

final class PrimeFinderAppTests: XCTestCase {
    var contentView: ContentView!
    
    override func setUpWithError() throws {
        contentView = ContentView()
    }
    
    override func tearDownWithError() throws {
        contentView = nil
    }
    
    // MARK: - Input Validation Tests
    
    func testValidInput() {
        // Valid inputs
        XCTAssertTrue(contentView.isValidInput("1"))
        XCTAssertTrue(contentView.isValidInput("42"))
        XCTAssertTrue(contentView.isValidInput("999999999"))
        
        // Invalid inputs
        XCTAssertFalse(contentView.isValidInput(""))
        XCTAssertFalse(contentView.isValidInput("0"))
        XCTAssertFalse(contentView.isValidInput("-1"))
        XCTAssertFalse(contentView.isValidInput("abc"))
        XCTAssertFalse(contentView.isValidInput("1.5"))
    }
    
    // MARK: - Prime Number Tests
    
    func testIsPrime() {
        // Test prime numbers
        XCTAssertTrue(contentView.isPrime(2))
        XCTAssertTrue(contentView.isPrime(3))
        XCTAssertTrue(contentView.isPrime(5))
        XCTAssertTrue(contentView.isPrime(7))
        XCTAssertTrue(contentView.isPrime(11))
        XCTAssertTrue(contentView.isPrime(13))
        XCTAssertTrue(contentView.isPrime(17))
        XCTAssertTrue(contentView.isPrime(19))
        XCTAssertTrue(contentView.isPrime(23))
        XCTAssertTrue(contentView.isPrime(97))
        
        // Test non-prime numbers
        XCTAssertFalse(contentView.isPrime(1))
        XCTAssertFalse(contentView.isPrime(4))
        XCTAssertFalse(contentView.isPrime(6))
        XCTAssertFalse(contentView.isPrime(8))
        XCTAssertFalse(contentView.isPrime(9))
        XCTAssertFalse(contentView.isPrime(10))
        XCTAssertFalse(contentView.isPrime(12))
        XCTAssertFalse(contentView.isPrime(15))
        XCTAssertFalse(contentView.isPrime(100))
    }
    
    func testIsPrimeWithLargeNumbers() {
        // Test large prime numbers
        XCTAssertTrue(contentView.isPrime(7919))  // 1000th prime number
        XCTAssertTrue(contentView.isPrime(104729)) // 10000th prime number
        
        // Test large composite numbers
        XCTAssertFalse(contentView.isPrime(7917)) // 7917 = 3 × 2639
        XCTAssertFalse(contentView.isPrime(104730)) // 104730 = 2 × 52365
    }
    
    // MARK: - Prime Factorization Tests
    
    func testPrimeFactors() {
        // Test simple numbers
        XCTAssertEqual(contentView.primeFactors(2), [2])
        XCTAssertEqual(contentView.primeFactors(3), [3])
        XCTAssertEqual(contentView.primeFactors(4), [2, 2])
        XCTAssertEqual(contentView.primeFactors(6), [2, 3])
        XCTAssertEqual(contentView.primeFactors(8), [2, 2, 2])
        XCTAssertEqual(contentView.primeFactors(9), [3, 3])
        
        // Test larger numbers
        XCTAssertEqual(contentView.primeFactors(100), [2, 2, 5, 5])
        XCTAssertEqual(contentView.primeFactors(147), [3, 7, 7])
        XCTAssertEqual(contentView.primeFactors(330), [2, 3, 5, 11])
    }
    
    func testPrimeFactorsWithLargeNumbers() {
        // Test large numbers with multiple factors
        XCTAssertEqual(contentView.primeFactors(7917), [3, 7, 13, 29])
        XCTAssertEqual(contentView.primeFactors(104730), [2, 3, 5, 3491])
        
        // Test perfect powers
        XCTAssertEqual(contentView.primeFactors(1024), Array(repeating: 2, count: 10)) // 2^10
        XCTAssertEqual(contentView.primeFactors(6561), Array(repeating: 3, count: 8))  // 3^8
    }
    
    // MARK: - History Item Tests
    
    func testHistoryItemCreation() {
        let number = 17
        let result = "17 is a prime number"
        let timestamp = Date()
        
        let historyItem = HistoryItem(number: number, result: result, timestamp: timestamp)
        
        XCTAssertEqual(historyItem.number, number)
        XCTAssertEqual(historyItem.result, result)
        XCTAssertEqual(historyItem.timestamp, timestamp)
    }
    
    func testHistoryItemEquality() {
        let timestamp = Date()
        let item1 = HistoryItem(number: 17, result: "17 is a prime number", timestamp: timestamp)
        let item2 = HistoryItem(number: 17, result: "17 is a prime number", timestamp: timestamp)
        let item3 = HistoryItem(number: 18, result: "18 is not a prime number", timestamp: timestamp)
        
        XCTAssertEqual(item1, item1)  // Same instance
        XCTAssertNotEqual(item1, item2)  // Different instances, even with same values (due to UUID)
        XCTAssertNotEqual(item1, item3)  // Different values
    }
    
    // MARK: - UI Interaction Tests
    
    // Helper method to set @State value
    private func setInputNumber(_ value: String) {
        contentView.inputNumber = value
        // Simulate the onChange behavior that happens in the UI
        let filtered = value.filter { "0123456789".contains($0) }
        if filtered.count > contentView.maxInputLength {
            contentView.inputNumber = String(filtered.prefix(contentView.maxInputLength))
        } else {
            contentView.inputNumber = filtered
        }
    }
    
    private func clearHistory() {
        contentView.history = []
    }
    
    func testKeyboardDismissal() {
        // Test keyboard dismissal sets focus state
        contentView.isInputFocused = true
        contentView.dismissKeyboard()
        XCTAssertFalse(contentView.isInputFocused)
        
        // Test keyboard dismissal during input processing
        contentView.isInputFocused = true
        contentView.validateAndProcessInput()
        XCTAssertFalse(contentView.isInputFocused)
    }
}
