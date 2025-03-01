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
        XCTAssertTrue(PrimeFinderUtils.isValidInput("1"))
        XCTAssertTrue(PrimeFinderUtils.isValidInput("42"))
        XCTAssertTrue(PrimeFinderUtils.isValidInput("999999999"))
        
        // Invalid inputs
        XCTAssertFalse(PrimeFinderUtils.isValidInput(""))
        XCTAssertFalse(PrimeFinderUtils.isValidInput("0"))
        XCTAssertFalse(PrimeFinderUtils.isValidInput("-1"))
        XCTAssertFalse(PrimeFinderUtils.isValidInput("abc"))
        XCTAssertFalse(PrimeFinderUtils.isValidInput("1.5"))
    }
    
    // MARK: - Prime Number Tests
    
    func testIsPrime() {
        // Test prime numbers
        XCTAssertTrue(PrimeFinderUtils.isPrime(2))
        XCTAssertTrue(PrimeFinderUtils.isPrime(3))
        XCTAssertTrue(PrimeFinderUtils.isPrime(5))
        XCTAssertTrue(PrimeFinderUtils.isPrime(7))
        XCTAssertTrue(PrimeFinderUtils.isPrime(11))
        XCTAssertTrue(PrimeFinderUtils.isPrime(13))
        XCTAssertTrue(PrimeFinderUtils.isPrime(17))
        XCTAssertTrue(PrimeFinderUtils.isPrime(19))
        XCTAssertTrue(PrimeFinderUtils.isPrime(23))
        XCTAssertTrue(PrimeFinderUtils.isPrime(97))
        XCTAssertTrue(PrimeFinderUtils.isPrime(101))
        XCTAssertTrue(PrimeFinderUtils.isPrime(103))
        XCTAssertTrue(PrimeFinderUtils.isPrime(107))
        XCTAssertTrue(PrimeFinderUtils.isPrime(109))
        XCTAssertTrue(PrimeFinderUtils.isPrime(149))
        XCTAssertTrue(PrimeFinderUtils.isPrime(151))
        XCTAssertTrue(PrimeFinderUtils.isPrime(3019))
        XCTAssertTrue(PrimeFinderUtils.isPrime(3037))
        XCTAssertTrue(PrimeFinderUtils.isPrime(7919))  // 1000th prime number
        XCTAssertTrue(PrimeFinderUtils.isPrime(104729)) // 10000th prime number
        XCTAssertTrue(PrimeFinderUtils.isPrime(1000151))
        XCTAssertTrue(PrimeFinderUtils.isPrime(20000003))
        XCTAssertTrue(PrimeFinderUtils.isPrime(1000000007))
        XCTAssertTrue(PrimeFinderUtils.isPrime(1000000009))
        
        
        
        // Test non-prime numbers
        XCTAssertFalse(PrimeFinderUtils.isPrime(1))
        XCTAssertFalse(PrimeFinderUtils.isPrime(4))
        XCTAssertFalse(PrimeFinderUtils.isPrime(6))
        XCTAssertFalse(PrimeFinderUtils.isPrime(8))
        XCTAssertFalse(PrimeFinderUtils.isPrime(9))
        XCTAssertFalse(PrimeFinderUtils.isPrime(10))
        XCTAssertFalse(PrimeFinderUtils.isPrime(12))
        XCTAssertFalse(PrimeFinderUtils.isPrime(15))
        XCTAssertFalse(PrimeFinderUtils.isPrime(51))
        XCTAssertFalse(PrimeFinderUtils.isPrime(100))
        XCTAssertFalse(PrimeFinderUtils.isPrime(7917)) // 7917 = 3 × 2639
        XCTAssertFalse(PrimeFinderUtils.isPrime(104730)) // 104730 = 2 × 52365
        XCTAssertFalse(PrimeFinderUtils.isPrime(1000001))
        XCTAssertFalse(PrimeFinderUtils.isPrime(1000002))
        XCTAssertFalse(PrimeFinderUtils.isPrime(1000006))
        XCTAssertFalse(PrimeFinderUtils.isPrime(1000129))
        XCTAssertFalse(PrimeFinderUtils.isPrime(1000137))
        XCTAssertFalse(PrimeFinderUtils.isPrime(1000000000))
        XCTAssertFalse(PrimeFinderUtils.isPrime(1000000011))
    }

    
    // MARK: - Mersenne Prime Tests
    
    func testIsMersennePrime() {
        // Test known Mersenne primes
        XCTAssertTrue(PrimeFinderUtils.isMersennePrime(3))    // 2^2 - 1
        XCTAssertTrue(PrimeFinderUtils.isMersennePrime(7))    // 2^3 - 1
        XCTAssertTrue(PrimeFinderUtils.isMersennePrime(31))   // 2^5 - 1
        XCTAssertTrue(PrimeFinderUtils.isMersennePrime(127))  // 2^7 - 1
        
        // Test numbers that are prime but not Mersenne primes
        XCTAssertFalse(PrimeFinderUtils.isMersennePrime(2))
        XCTAssertFalse(PrimeFinderUtils.isMersennePrime(5))
        XCTAssertFalse(PrimeFinderUtils.isMersennePrime(11))
        XCTAssertFalse(PrimeFinderUtils.isMersennePrime(13))
        
        // Test composite numbers
        XCTAssertFalse(PrimeFinderUtils.isMersennePrime(4))
        XCTAssertFalse(PrimeFinderUtils.isMersennePrime(15))
        XCTAssertFalse(PrimeFinderUtils.isMersennePrime(63))  // 2^6 - 1 (composite)
        
        // Test edge cases
        XCTAssertFalse(PrimeFinderUtils.isMersennePrime(1))
        XCTAssertFalse(PrimeFinderUtils.isMersennePrime(0))
        XCTAssertFalse(PrimeFinderUtils.isMersennePrime(-1))
    }
    
    // MARK: - All Factors Tests
    
    func testAllFactors() {
        // Test composite numbers
        XCTAssertEqual(PrimeFinderUtils.allFactors(4), [2])
        XCTAssertEqual(PrimeFinderUtils.allFactors(6), [2, 3])
        XCTAssertEqual(PrimeFinderUtils.allFactors(8), [2, 4])
        XCTAssertEqual(PrimeFinderUtils.allFactors(12), [2, 3, 4, 6])
        XCTAssertEqual(PrimeFinderUtils.allFactors(15), [3, 5])
        XCTAssertEqual(PrimeFinderUtils.allFactors(16), [2, 4, 8])
        XCTAssertEqual(PrimeFinderUtils.allFactors(28), [2, 4, 7, 14])
        
        // Test perfect squares
        XCTAssertEqual(PrimeFinderUtils.allFactors(9), [3])
        XCTAssertEqual(PrimeFinderUtils.allFactors(25), [5])
        XCTAssertEqual(PrimeFinderUtils.allFactors(100), [2, 4, 5, 10, 20, 25, 50])
        
        // Test edge cases
        XCTAssertEqual(PrimeFinderUtils.allFactors(1), [])
        XCTAssertEqual(PrimeFinderUtils.allFactors(0), [])
        XCTAssertEqual(PrimeFinderUtils.allFactors(-1), [])
                                                    
        // Test some larger numbers
        XCTAssertEqual(PrimeFinderUtils.allFactors(120), [2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 24, 30, 40, 60])
        XCTAssertEqual(PrimeFinderUtils.allFactors(128), [2, 4, 8, 16, 32, 64])  // Power of 2
        XCTAssertEqual(PrimeFinderUtils.allFactors(1000), [2, 4, 5, 8, 10, 20, 25, 40, 50, 100, 125, 200, 250, 500])
    }
    
    // MARK: - Prime Factorization Tests
    
    func testPrimeFactors() {
        // Test simple numbers
        XCTAssertEqual(PrimeFinderUtils.primeFactors(2), [2])
        XCTAssertEqual(PrimeFinderUtils.primeFactors(3), [3])
        XCTAssertEqual(PrimeFinderUtils.primeFactors(4), [2, 2])
        XCTAssertEqual(PrimeFinderUtils.primeFactors(6), [2, 3])
        XCTAssertEqual(PrimeFinderUtils.primeFactors(8), [2, 2, 2])
        XCTAssertEqual(PrimeFinderUtils.primeFactors(9), [3, 3])
        
        // Test larger numbers
        XCTAssertEqual(PrimeFinderUtils.primeFactors(100), [2, 2, 5, 5])
        XCTAssertEqual(PrimeFinderUtils.primeFactors(147), [3, 7, 7])
        XCTAssertEqual(PrimeFinderUtils.primeFactors(330), [2, 3, 5, 11])
        
        // Test large numbers with multiple factors
        XCTAssertEqual(PrimeFinderUtils.primeFactors(7917), [3, 7, 13, 29])
        XCTAssertEqual(PrimeFinderUtils.primeFactors(104730), [2, 3, 5, 3491])
        
        // Test perfect powers
        XCTAssertEqual(PrimeFinderUtils.primeFactors(1024), Array(repeating: 2, count: 10)) // 2^10
        XCTAssertEqual(PrimeFinderUtils.primeFactors(6561), Array(repeating: 3, count: 8))  // 3^8
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
