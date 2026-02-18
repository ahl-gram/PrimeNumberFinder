//
//  PrimeNavigationTests.swift
//  PrimeFinderAppTests
//
//  Route 12B Software.
//

import XCTest
@testable import PrimeFinderApp

final class PrimeNavigationTests: XCTestCase {

    // MARK: - findPreviousPrime Tests

    func testFindPreviousPrimeFromZero() {
        // 0 - 1 would underflow UInt64; should safely return nil
        XCTAssertNil(PrimeFinderUtils.findPreviousPrime(0))
    }

    func testFindPreviousPrimeFromOne() {
        XCTAssertNil(PrimeFinderUtils.findPreviousPrime(1))
    }

    func testFindPreviousPrimeFromTwo() {
        // 2 is the smallest prime; no previous prime exists
        XCTAssertNil(PrimeFinderUtils.findPreviousPrime(2))
    }

    func testFindPreviousPrimeFromThree() {
        XCTAssertEqual(PrimeFinderUtils.findPreviousPrime(3), 2)
    }

    func testFindPreviousPrimeFromComposite() {
        XCTAssertEqual(PrimeFinderUtils.findPreviousPrime(10), 7)
        XCTAssertEqual(PrimeFinderUtils.findPreviousPrime(100), 97)
        XCTAssertEqual(PrimeFinderUtils.findPreviousPrime(50), 47)
    }

    func testFindPreviousPrimeFromPrime() {
        // From a prime, should return the prime before it
        XCTAssertEqual(PrimeFinderUtils.findPreviousPrime(13), 11)
        XCTAssertEqual(PrimeFinderUtils.findPreviousPrime(29), 23)
        XCTAssertEqual(PrimeFinderUtils.findPreviousPrime(7919), 7907)
    }

    // MARK: - findNextPrime Tests

    func testFindNextPrimeFromZero() {
        XCTAssertEqual(PrimeFinderUtils.findNextPrime(0), 2)
    }

    func testFindNextPrimeFromOne() {
        XCTAssertEqual(PrimeFinderUtils.findNextPrime(1), 2)
    }

    func testFindNextPrimeFromTwo() {
        XCTAssertEqual(PrimeFinderUtils.findNextPrime(2), 3)
    }

    func testFindNextPrimeFromComposite() {
        XCTAssertEqual(PrimeFinderUtils.findNextPrime(10), 11)
        XCTAssertEqual(PrimeFinderUtils.findNextPrime(100), 101)
        XCTAssertEqual(PrimeFinderUtils.findNextPrime(50), 53)
    }

    func testFindNextPrimeFromPrime() {
        XCTAssertEqual(PrimeFinderUtils.findNextPrime(13), 17)
        XCTAssertEqual(PrimeFinderUtils.findNextPrime(29), 31)
        XCTAssertEqual(PrimeFinderUtils.findNextPrime(7919), 7927)
    }

    func testFindNextPrimeNearMax() {
        // Should return nil when no prime exists below maxNumberInput
        let result = PrimeFinderUtils.findNextPrime(PrimeFinderUtils.maxNumberInput)
        XCTAssertNil(result, "Should return nil when at or above maxNumberInput")
    }

    // MARK: - primeFactors Edge Cases

    func testPrimeFactorsOfZero() {
        XCTAssertEqual(PrimeFinderUtils.primeFactors(0), [])
    }

    func testPrimeFactorsOfOne() {
        XCTAssertEqual(PrimeFinderUtils.primeFactors(1), [])
    }

    func testPrimeFactorsOfPrime() {
        // A prime number's only prime factor is itself
        XCTAssertEqual(PrimeFinderUtils.primeFactors(2), [2])
        XCTAssertEqual(PrimeFinderUtils.primeFactors(97), [97])
        XCTAssertEqual(PrimeFinderUtils.primeFactors(7919), [7919])
    }

    func testPrimeFactorsOfLargeNumber() {
        // 1000000007 is prime
        XCTAssertEqual(PrimeFinderUtils.primeFactors(1000000007), [1000000007])

        // 1000000006 = 2 × 500000003
        let factors = PrimeFinderUtils.primeFactors(1000000006)
        XCTAssertEqual(factors, [2, 500000003])
    }

}
