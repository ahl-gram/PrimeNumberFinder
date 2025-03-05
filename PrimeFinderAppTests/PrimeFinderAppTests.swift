//
//  PrimeFinderAppTests.swift
//  PrimeFinderAppTests
//
//  Route 12B Software.
//

import XCTest
import SwiftUI
@testable import PrimeFinderApp

// Mock class for testing button actions
class MockContentView {
    var inputNumber: String = ""
    var result: String = ""
    var history: [HistoryItem] = []
    var isUserTyping: Bool = true
    var isProgrammaticChange: Bool = false
    
    // Track function calls
    var validateAndProcessInputCalled = false
    var findNextPrimeCalled = false
    var findPreviousPrimeCalled = false
    var incrementCalled = false
    var decrementCalled = false
    
    // Simulate button actions
    func incrementNumber() {
        if let number = Int(inputNumber) {
            isUserTyping = false
            isProgrammaticChange = true
            inputNumber = String(number + 1)
            incrementCalled = true
            validateAndProcessInput()
        }
    }
    
    func decrementNumber() {
        if let number = Int(inputNumber), number > 1 {
            isUserTyping = false
            isProgrammaticChange = true
            inputNumber = String(number - 1)
            decrementCalled = true
            validateAndProcessInput()
        }
    }
    
    func findNextPrime() {
        if let number = UInt64(inputNumber),
           let nextPrime = PrimeFinderUtils.findNextPrime(number) {
            isUserTyping = false
            isProgrammaticChange = true
            inputNumber = String(nextPrime)
            findNextPrimeCalled = true
            validateAndProcessInput()
        }
    }
    
    func findPreviousPrime() {
        if let number = UInt64(inputNumber),
           let previousPrime = PrimeFinderUtils.findPreviousPrime(number) {
            isUserTyping = false
            isProgrammaticChange = true
            inputNumber = String(previousPrime)
            findPreviousPrimeCalled = true
            validateAndProcessInput()
        }
    }
    
    // Simulate user typing in the input field
    func simulateInputChange(to newValue: String, isUserTyping: Bool = true) {
        // Always set isUserTyping to true by default, just like the real onChange handler
        self.isUserTyping = isUserTyping
        
        // Set isProgrammaticChange based on isUserTyping
        self.isProgrammaticChange = !isUserTyping
        
        inputNumber = newValue
        
        // Reset isProgrammaticChange after the change
        self.isProgrammaticChange = false
        
        // Clear result if user is typing and there's a result
        if self.isUserTyping && !result.isEmpty {
            result = ""
        }
    }
    
    func validateAndProcessInput() {
        validateAndProcessInputCalled = true
        
        guard PrimeFinderUtils.isValidInput(inputNumber) else {
            result = "Please enter a valid positive integer."
            return
        }
        
        guard let number = UInt64(inputNumber) else { return }
        
        // Format number with thousands separator
        let formattedNumber = NumberFormatter.localizedString(from: NSNumber(value: number), number: .decimal)
        
        if number == 1 {
            result = "\(formattedNumber) is defined as not a prime."
        }
        else {
            if PrimeFinderUtils.isPrime(number) {
                result = "✅ \(formattedNumber) is a prime number."
            } else {
                let factors = PrimeFinderUtils.primeFactors(number)
                let formattedFactors = factors.map { NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) }
                result = "☑️ \(formattedNumber) is not a prime number.\nPrime factors: \(formattedFactors.joined(separator: " × "))"
            }
        }
        
        let historyItem = HistoryItem(number: number, result: result, timestamp: Date())
        history.insert(historyItem, at: 0)
    }
    
    // Reset tracking variables
    func resetTracking() {
        validateAndProcessInputCalled = false
        findNextPrimeCalled = false
        findPreviousPrimeCalled = false
        incrementCalled = false
        decrementCalled = false
    }
}

final class PrimeFinderAppTests: XCTestCase {
    var contentView: ContentView!
    var mockContentView: MockContentView!
    
    override func setUpWithError() throws {
        contentView = ContentView()
        mockContentView = MockContentView()
    }
    
    override func tearDownWithError() throws {
        contentView = nil
        mockContentView = nil
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
        //XCTAssertFalse(PrimeFinderUtils.isMersennePrime(-1))
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
        //XCTAssertEqual(PrimeFinderUtils.allFactors(-1), [])
                                                    
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
        let number: UInt64 = 17
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
    
    // MARK: - Button Functionality Tests
    
    func testIncrementDecrementButtons() {
        // Test increment button
        mockContentView.inputNumber = "42"
        mockContentView.resetTracking()
        
        // Call the method that simulates pressing the plus button
        mockContentView.incrementNumber()
        
        XCTAssertTrue(mockContentView.incrementCalled, "Increment function should be called")
        XCTAssertTrue(mockContentView.validateAndProcessInputCalled, "validateAndProcessInput should be called")
        XCTAssertEqual(mockContentView.inputNumber, "43", "Input number should be incremented")
        XCTAssertTrue(mockContentView.result.contains("43"), "Result should contain the new number")
        
        // Test decrement button
        mockContentView.resetTracking()
        mockContentView.decrementNumber()
        
        XCTAssertTrue(mockContentView.decrementCalled, "Decrement function should be called")
        XCTAssertTrue(mockContentView.validateAndProcessInputCalled, "validateAndProcessInput should be called")
        XCTAssertEqual(mockContentView.inputNumber, "42", "Input number should be decremented")
        XCTAssertTrue(mockContentView.result.contains("42"), "Result should contain the new number")
        
        // Test edge case: decrementing 1 should not work
        mockContentView.inputNumber = "1"
        mockContentView.resetTracking()
        mockContentView.decrementNumber()
        
        XCTAssertFalse(mockContentView.decrementCalled, "Decrement function should not be called for 1")
        XCTAssertFalse(mockContentView.validateAndProcessInputCalled, "validateAndProcessInput should not be called")
        XCTAssertEqual(mockContentView.inputNumber, "1", "Input number should remain unchanged")
    }
    
    func testPrimeNavigationButtons() {
        // Test next prime button
        mockContentView.inputNumber = "10"
        mockContentView.resetTracking()
        
        // Call the method that simulates pressing the next prime button
        mockContentView.findNextPrime()
        
        XCTAssertTrue(mockContentView.findNextPrimeCalled, "findNextPrime function should be called")
        XCTAssertTrue(mockContentView.validateAndProcessInputCalled, "validateAndProcessInput should be called")
        XCTAssertEqual(mockContentView.inputNumber, "11", "Input number should be updated to next prime")
        XCTAssertTrue(mockContentView.result.contains("11"), "Result should contain the new prime number")
        XCTAssertTrue(mockContentView.result.contains("is a prime"), "Result should indicate the number is prime")
        
        // Test previous prime button
        mockContentView.resetTracking()
        mockContentView.findPreviousPrime()
        
        XCTAssertTrue(mockContentView.findPreviousPrimeCalled, "findPreviousPrime function should be called")
        XCTAssertTrue(mockContentView.validateAndProcessInputCalled, "validateAndProcessInput should be called")
        XCTAssertEqual(mockContentView.inputNumber, "7", "Input number should be updated to previous prime")
        XCTAssertTrue(mockContentView.result.contains("7"), "Result should contain the new prime number")
        XCTAssertTrue(mockContentView.result.contains("is a prime"), "Result should indicate the number is prime")
        
        // Test edge case: finding previous prime from 2 should not work
        mockContentView.inputNumber = "2"
        mockContentView.resetTracking()
        mockContentView.findPreviousPrime()
        
        XCTAssertFalse(mockContentView.findPreviousPrimeCalled, "findPreviousPrime function should not be called for 2")
        XCTAssertFalse(mockContentView.validateAndProcessInputCalled, "validateAndProcessInput should not be called")
        XCTAssertEqual(mockContentView.inputNumber, "2", "Input number should remain unchanged")
    }
    
    // MARK: - Input Modification Tests
    
    func testInputModificationClearsResult() {
        // Setup
        mockContentView.inputNumber = "10"
        mockContentView.validateAndProcessInput()
        XCTAssertFalse(mockContentView.result.isEmpty, "Result should not be empty after validation")
        
        // Test 1: Direct user typing should clear the result
        mockContentView.simulateInputChange(to: "11", isUserTyping: true)
        XCTAssertTrue(mockContentView.result.isEmpty, "Result should be cleared when user is typing")
        
        // Setup again
        mockContentView.inputNumber = "10"
        mockContentView.validateAndProcessInput()
        XCTAssertFalse(mockContentView.result.isEmpty, "Result should not be empty after validation")
        
        // Test 2: Button actions should not clear the result
        mockContentView.simulateInputChange(to: "11", isUserTyping: false)
        XCTAssertFalse(mockContentView.result.isEmpty, "Result should not be cleared when using buttons")
        
        // Test 3: Increment button should not clear the result
        mockContentView.inputNumber = "10"
        mockContentView.validateAndProcessInput()
        mockContentView.incrementNumber()
        XCTAssertFalse(mockContentView.result.isEmpty, "Result should not be cleared when using increment button")
        
        // Test 4: Next prime button should not clear the result
        mockContentView.inputNumber = "10"
        mockContentView.validateAndProcessInput()
        mockContentView.findNextPrime()
        XCTAssertFalse(mockContentView.result.isEmpty, "Result should not be cleared when using next prime button")
    }
    
    func testInputModificationAfterButtonAction() {
        // Setup - use a button action first
        mockContentView.inputNumber = "10"
        mockContentView.validateAndProcessInput()
        
        // Before button action, isProgrammaticChange should be false
        XCTAssertFalse(mockContentView.isProgrammaticChange, "isProgrammaticChange should be false initially")
        
        mockContentView.incrementNumber()
        
        // Verify isUserTyping was set to false by the button action
        XCTAssertFalse(mockContentView.isUserTyping, "isUserTyping should be false after button action")
        XCTAssertTrue(mockContentView.isProgrammaticChange, "isProgrammaticChange should be reset to true after button action")
        XCTAssertFalse(mockContentView.result.isEmpty, "Result should not be empty after button action")
        
        // Now simulate user typing after the button action
        mockContentView.simulateInputChange(to: "12", isUserTyping: true)
        
        // Verify result was cleared
        XCTAssertTrue(mockContentView.isUserTyping, "isUserTyping should be true after user typing")
        XCTAssertFalse(mockContentView.isProgrammaticChange, "isProgrammaticChange should be false after user typing")
        XCTAssertTrue(mockContentView.result.isEmpty, "Result should be cleared when user types after button action")
    }
}
