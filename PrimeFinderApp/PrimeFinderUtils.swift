//
//  PrimeFinderUtils.swift
//  PrimeFinderApp
//
//  Created by Alexander Lee on 2/8/25.
//

import Foundation

struct PrimeFinderUtils {
    // Constants
    static let maxNumberInput = 9999999999
    
    // MARK: - Prime Checking Functions
    static func isPrime(_ number: Int) -> Bool {
        if number < 2 { return false }
        if number == 2 || number == 3 { return true }
        if number % 2 == 0 || number % 3 == 0 { return false }
        
        // Precompute the square root of the number.
        // If number has a factor greater than its square root,
        // it must also have a corresponding factor smaller than its square root.
        // Therefore, it's enough to check for factors up to the square root of number.
        let limit = Int(Double(number).squareRoot())
        
        // Loop through potential factors starting at 5 using the 6k +- 1 optimization
        var i = 5
        while i <= limit {
            if number % i == 0 {
                // 6k - 1 is a divisor, so number is composite
                return false
            }
            
            if number % (i + 2) == 0 {
                // 6k + 1 is a divisor, so number is composite
                return false
            }
            
            // Move to the next potential set of divisors (6k +- 1)
            i += 6
        }
        
        // If no divisors are found, number is prime
        return true
    }
    
    static func isMersennePrime(_ number: Int) -> Bool {
        // A Mersenne prime is a prime number of the form 2^n - 1
        // First check if the number is prime
        if !isPrime(number) {
            return false
        }
        
        // Check if the number is one less than a power of 2
        let numberPlusOne = number + 1
        
        // If it's a power of 2, it will have exactly one bit set
        // Using bitwise AND to check: (n & (n-1)) == 0
        return (numberPlusOne & (numberPlusOne - 1)) == 0
    }
    
    // MARK: - Factor Functions
    static func allFactors(_ number: Int) -> [Int] {
        // Return empty array for invalid inputs
        if number < 1 {
            return []
        }
        
        // 1 only has itself as a factor
        if number == 1 {
            return []
        }
        
        var factors = Set<Int>() // Use Set to avoid duplicates
        
        // Find factors up to the square root
        let sqrtNum = Int(Double(number).squareRoot())
        for i in 2...sqrtNum {  // Start from 2 to exclude 1
            if number % i == 0 {
                factors.insert(i)
                let pair = number / i
                if pair != i && pair != number {  // Exclude the number itself
                    factors.insert(pair)
                }
            }
        }
        
        // Convert to array and sort
        return Array(factors).sorted()
    }
    
    static func primeFactors(_ number: Int) -> [Int] {
        var n = number
        var factors: [Int] = []
        var divisor = 2
        
        while n >= 2 {
            while n % divisor == 0 {
                factors.append(divisor)
                n /= divisor
            }
            divisor += (divisor == 2) ? 1 : 2
            
            if divisor * divisor > n {
                if n > 1 {
                    factors.append(n)
                }
                break
            }
        }
        
        return factors
    }
    
    // MARK: - Navigation Functions
    static func findNextPrime(_ from: Int) -> Int? {
        var current = from + 1
        // Prevent integer overflow
        while current <= Int.max && current <= maxNumberInput {
            if isPrime(current) {
                return current
            }
            current += 1
        }
        return nil
    }
    
    static func findPreviousPrime(_ from: Int) -> Int? {
        var current = from - 1
        while current >= 2 {
            if isPrime(current) {
                return current
            }
            current -= 1
        }
        return nil
    }
    
    // MARK: - Validation Functions
    static func isValidInput(_ input: String) -> Bool {
        guard let number = Int(input) else { return false }
        return number > 0
    }
} 