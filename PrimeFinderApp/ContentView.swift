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
    @State internal var inputNumber: String = ""
    @State internal var result: String = ""
    @State internal var history: [HistoryItem] = []
    @State internal var showingHistory = false
    @State internal var showingResetAlert = false
    @FocusState internal var isInputFocused: Bool
    
    // MARK: - Constants
    let maxInputLength = 10 // Prevent integer overflow
    
    // MARK: - Colors
    let primaryColor = Color.blue
    let backgroundColor = Color(.systemBackground)
    let secondaryBackgroundColor = Color(.systemGray6)
    
    // MARK: - Keyboard Dismissal
    func dismissKeyboard() {
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
    
    func addToHistory(number: Int, result: String) {
        let historyItem = HistoryItem(number: number, result: result, timestamp: Date())
        history.insert(historyItem, at: 0) // Add to beginning of array
    }
    
    func validateAndProcessInput() {
        dismissKeyboard()
        
        guard isValidInput(inputNumber) else {
            result = "Please enter a valid positive integer."
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        guard let number = Int(inputNumber) else { return }
        
        // Provide success haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Format number with thousands separator
        let formattedNumber = NumberFormatter.localizedString(from: NSNumber(value: number), number: .decimal)
        
        if number == 1 {
            result = "\(formattedNumber) is defined as not a prime."
        }
        else {
            if isPrime(number) {
                result = "\(formattedNumber) is a prime number."
            } else {
                let factors = primeFactors(number)
                result = "\(formattedNumber) is not a prime number.\nPrime factors: \(factors.map { String($0) }.joined(separator: " × "))"
            }
        }
        addToHistory(number: number, result: result)
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
                                result = ""
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                                    .imageScale(.medium)
                                    .padding(.trailing, 24)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
                }
            )
    }
    
    var checkButton: some View {
        HStack(spacing: 10) {
            // Minus Button
            Button(action: {
                if let number = Int(inputNumber) {
                    inputNumber = String(number - 1)
                    if !result.isEmpty {
                        validateAndProcessInput()
                    }
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(primaryColor)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .opacity(inputNumber.isEmpty || inputNumber <= "1" ? 0.5 : 1.0)
            }
            .disabled(inputNumber.isEmpty || inputNumber <= "1")
            .accessibilityLabel("Decrement Number")

            // Original Check Button
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
                .opacity(inputNumber.isEmpty ? 0.5 : 1.0)
            }
            .disabled(inputNumber.isEmpty)
            .accessibilityLabel("Check Number Button")

            // Plus Button
            Button(action: {
                if let number = Int(inputNumber) {
                    inputNumber = String(number + 1)
                    if !result.isEmpty {
                        validateAndProcessInput()
                    }
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(primaryColor)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .opacity(inputNumber.isEmpty || inputNumber >= "9999999999" ? 0.5 : 1.0)
            }
            .disabled(inputNumber.isEmpty || inputNumber >= "9999999999")
            .accessibilityLabel("Increment Number")
        }
        .padding(.horizontal)
    }
    
    var resultView: some View {
        Text(result)
            .font(.body)
            .padding()
            .multilineTextAlignment(.center)
            .accessibilityLabel("Result Text View")
            .foregroundColor(result.contains("is a prime")
                             ? .green
                             : result.contains("is not a prime") || result.contains("defined as not")
                                ? primaryColor
                                : .red)
            .animation(.easeInOut, value: result)
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
