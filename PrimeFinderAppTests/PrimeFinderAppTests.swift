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
        XCTAssertTrue(contentView.isPrime(101))
        XCTAssertTrue(contentView.isPrime(103))
        XCTAssertTrue(contentView.isPrime(107))
        XCTAssertTrue(contentView.isPrime(109))
        XCTAssertTrue(contentView.isPrime(149))
        XCTAssertTrue(contentView.isPrime(151))
        XCTAssertTrue(contentView.isPrime(3019))
        XCTAssertTrue(contentView.isPrime(3037))
        XCTAssertTrue(contentView.isPrime(7919))  // 1000th prime number
        XCTAssertTrue(contentView.isPrime(104729)) // 10000th prime number
        XCTAssertTrue(contentView.isPrime(1000151))
        XCTAssertTrue(contentView.isPrime(20000003))
        XCTAssertTrue(contentView.isPrime(1000000007))
        XCTAssertTrue(contentView.isPrime(1000000009))
        
        
        
        // Test non-prime numbers
        XCTAssertFalse(contentView.isPrime(1))
        XCTAssertFalse(contentView.isPrime(4))
        XCTAssertFalse(contentView.isPrime(6))
        XCTAssertFalse(contentView.isPrime(8))
        XCTAssertFalse(contentView.isPrime(9))
        XCTAssertFalse(contentView.isPrime(10))
        XCTAssertFalse(contentView.isPrime(12))
        XCTAssertFalse(contentView.isPrime(15))
        XCTAssertFalse(contentView.isPrime(51))
        XCTAssertFalse(contentView.isPrime(100))
        XCTAssertFalse(contentView.isPrime(7917)) // 7917 = 3 × 2639
        XCTAssertFalse(contentView.isPrime(104730)) // 104730 = 2 × 52365
        XCTAssertFalse(contentView.isPrime(1000001))
        XCTAssertFalse(contentView.isPrime(1000002))
        XCTAssertFalse(contentView.isPrime(1000006))
        XCTAssertFalse(contentView.isPrime(1000129))
        XCTAssertFalse(contentView.isPrime(1000137))
        XCTAssertFalse(contentView.isPrime(1000000000))
        XCTAssertFalse(contentView.isPrime(1000000011))
    }

    
    // MARK: - Mersenne Prime Tests
    
    func testIsMersennePrime() {
        // Test known Mersenne primes
        XCTAssertTrue(contentView.isMersennePrime(3))    // 2^2 - 1
        XCTAssertTrue(contentView.isMersennePrime(7))    // 2^3 - 1
        XCTAssertTrue(contentView.isMersennePrime(31))   // 2^5 - 1
        XCTAssertTrue(contentView.isMersennePrime(127))  // 2^7 - 1
        
        // Test numbers that are prime but not Mersenne primes
        XCTAssertFalse(contentView.isMersennePrime(2))
        XCTAssertFalse(contentView.isMersennePrime(5))
        XCTAssertFalse(contentView.isMersennePrime(11))
        XCTAssertFalse(contentView.isMersennePrime(13))
        
        // Test composite numbers
        XCTAssertFalse(contentView.isMersennePrime(4))
        XCTAssertFalse(contentView.isMersennePrime(15))
        XCTAssertFalse(contentView.isMersennePrime(63))  // 2^6 - 1 (composite)
        
        // Test edge cases
        XCTAssertFalse(contentView.isMersennePrime(1))
        XCTAssertFalse(contentView.isMersennePrime(0))
        XCTAssertFalse(contentView.isMersennePrime(-1))
    }
    
    // MARK: - All Factors Tests
    
    func testAllFactors() {
        // Test composite numbers
        XCTAssertEqual(contentView.allFactors(4), [2])
        XCTAssertEqual(contentView.allFactors(6), [2, 3])
        XCTAssertEqual(contentView.allFactors(8), [2, 4])
        XCTAssertEqual(contentView.allFactors(12), [2, 3, 4, 6])
        XCTAssertEqual(contentView.allFactors(15), [3, 5])
        XCTAssertEqual(contentView.allFactors(16), [2, 4, 8])
        XCTAssertEqual(contentView.allFactors(28), [2, 4, 7, 14])
        
        // Test perfect squares
        XCTAssertEqual(contentView.allFactors(9), [3])
        XCTAssertEqual(contentView.allFactors(25), [5])
        XCTAssertEqual(contentView.allFactors(100), [2, 4, 5, 10, 20, 25, 50])
        
        // Test edge cases
        XCTAssertEqual(contentView.allFactors(1), [])
        XCTAssertEqual(contentView.allFactors(0), [])
        XCTAssertEqual(contentView.allFactors(-1), [])
                                                    
        // Test some larger numbers
        XCTAssertEqual(contentView.allFactors(120), [2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 24, 30, 40, 60])
        XCTAssertEqual(contentView.allFactors(128), [2, 4, 8, 16, 32, 64])  // Power of 2
        XCTAssertEqual(contentView.allFactors(1000), [2, 4, 5, 8, 10, 20, 25, 40, 50, 100, 125, 200, 250, 500])
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
        let result = "17 is a prime number."
        let timestamp = Date()
        
        let historyItem = HistoryItem(number: number, result: result, timestamp: timestamp)
        
        XCTAssertEqual(historyItem.number, number)
        XCTAssertEqual(historyItem.result, result)
        XCTAssertEqual(historyItem.timestamp, timestamp)
    }
    
    func testHistoryItemEquality() {
        let timestamp = Date()
        let item1 = HistoryItem(number: 17, result: "17 is a prime number.", timestamp: timestamp)
        let item2 = HistoryItem(number: 17, result: "17 is a prime number.", timestamp: timestamp)
        let item3 = HistoryItem(number: 18, result: "18 is not a prime number.", timestamp: timestamp)
        
        XCTAssertEqual(item1, item1)  // Same instance
        XCTAssertNotEqual(item1, item2)  // Different instances, even with same values (due to UUID)
        XCTAssertNotEqual(item1, item3)  // Different values
    }
    
    // MARK: - UI Interaction Tests
    
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
