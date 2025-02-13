//
//  ContentView.swift
//  PrimeFinderApp
//
//  Created by Alexander Lee on 2/8/25.
//

import SwiftUI

struct HistoryItem: Identifiable, Equatable {
    let id = UUID()
    let number: Int
    let result: String
    let timestamp: Date
}

struct ContentView: View {
    @State private var inputNumber: String = ""
    @State private var result: String = ""
    @State private var isLoading = false
    @State private var history: [HistoryItem] = []
    @State private var showingHistory = false
    @State private var showingResetAlert = false
    @FocusState private var isInputFocused: Bool
    
    // MARK: - Constants
    private let maxInputLength = 9 // Prevent integer overflow
    
    // MARK: - Colors
    private let primaryColor = Color.blue
    private let backgroundColor = Color(.systemBackground)
    private let secondaryBackgroundColor = Color(.systemGray6)
    
    // MARK: - Keyboard Dismissal
    private func dismissKeyboard() {
        isInputFocused = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Validation and Calculation Functions
    func isValidInput(_ input: String) -> Bool {
        guard let number = Int(input) else { return false }
        return number > 0
    }
    
    func isPrime(_ number: Int) -> Bool {
        if number < 2 { return false }
        if number == 2 || number == 3 { return true }
        if number % 2 == 0 || number % 3 == 0 { return false }
        
        var i = 5
        while i * i <= number {
            if number % i == 0 || number % (i + 2) == 0 {
                return false
            }
            i += 6
        }
        return true
    }
    
    func primeFactors(_ number: Int) -> [Int] {
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
    
    private func addToHistory(number: Int, result: String) {
        let historyItem = HistoryItem(number: number, result: result, timestamp: Date())
        history.insert(historyItem, at: 0) // Add to beginning of array
    }
    
    func validateAndProcessInput() {
        dismissKeyboard()
        
        guard isValidInput(inputNumber) else {
            result = "Please enter a valid positive integer"
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        guard let number = Int(inputNumber) else { return }
        
        // Provide success haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        if number > 10000 {
            isLoading = true
            
            DispatchQueue.global(qos: .userInitiated).async {
                let isPrimeResult = isPrime(number)
                
                DispatchQueue.main.async {
                    if isPrimeResult {
                        result = "\(number) is a prime number"
                    } else {
                        let factors = primeFactors(number)
                        result = "\(number) is not a prime number\nPrime factors: \(factors.map { String($0) }.joined(separator: " × "))"
                    }
                    addToHistory(number: number, result: result)
                    isLoading = false
                }
            }
        } else {
            if isPrime(number) {
                result = "\(number) is a prime number"
            } else {
                let factors = primeFactors(number)
                result = "\(number) is not a prime number\nPrime factors: \(factors.map { String($0) }.joined(separator: " × "))"
            }
            addToHistory(number: number, result: result)
        }
    }
    
    // MARK: - View Components
    var inputField: some View {
        TextField("Enter a positive integer", text: $inputNumber)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
            .padding()
            .background(secondaryBackgroundColor)
            .cornerRadius(12)
            .padding(.horizontal)
            .focused($isInputFocused)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        dismissKeyboard()
                    }
                }
            }
            .accessibilityLabel("Input Number Field")
            .onChange(of: inputNumber) { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                
                // Provide haptic feedback if input was filtered
                if filtered != newValue {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                // Enforce maximum length
                if filtered.count > maxInputLength {
                    inputNumber = String(filtered.prefix(maxInputLength))
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                } else {
                    inputNumber = filtered
                }
            }
            .overlay(
                Group {
                    if !inputNumber.isEmpty {
                        HStack {
                            Spacer()
                            Button(action: {
                                inputNumber = ""
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                }
            )
    }
    
    var checkButton: some View {
        Button(action: {
            validateAndProcessInput()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large)
                Text("Check Number")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(primaryColor)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .padding(.horizontal)
        .disabled(isLoading || inputNumber.isEmpty)
        .accessibilityLabel("Check Number Button")
    }
    
    var resultView: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                    .scaleEffect(1.2)
                    .padding()
            }
            
            Text(result)
                .font(.body)
                .padding()
                .multilineTextAlignment(.center)
                .accessibilityLabel("Result Text View")
                .foregroundColor(result.contains("is a prime number") ? .green : 
                               result.contains("is not a prime number") ? primaryColor : .red)
                .animation(.easeInOut, value: result)
        }
        .padding(.vertical)
    }
    
    var historyButton: some View {
        Button(action: {
            showingHistory = true
        }) {
            Image(systemName: "clock.arrow.circlepath")
                .imageScale(.large)
                .foregroundColor(primaryColor)
        }
    }
    
    var historyView: some View {
        List {
            ForEach(history) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(item.number)")
                        .font(.headline)
                    Text(item.result)
                        .font(.subheadline)
                        .foregroundColor(item.result.contains("is a prime number") ? .green :
                                       item.result.contains("is not a prime number") ? primaryColor : .red)
                    Text(item.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !history.isEmpty {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .alert("Clear History", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                history.removeAll()
            }
        } message: {
            Text("Are you sure you want to clear all history?")
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        inputField
                        checkButton
                        resultView
                    }
                    .padding(.top)
                }
            }
            .navigationBarTitle("Prime Finder", displayMode: .large)
            .navigationBarItems(trailing: historyButton)
            .sheet(isPresented: $showingHistory) {
                NavigationView {
                    historyView
                        .navigationTitle("History")
                        .navigationBarItems(trailing: Button("Done") {
                            showingHistory = false
                        })
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isInputFocused {
                    dismissKeyboard()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
