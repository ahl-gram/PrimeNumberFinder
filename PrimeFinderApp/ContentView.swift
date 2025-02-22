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
    @State internal var showingHelp = false
    @State internal var showingResetAlert = false
    @State internal var isResultExpanded = false
    @State private var editMode = EditMode.inactive
    @State private var showingFactorAlert = false
    @State private var selectedFactor: Int = 0
    @FocusState internal var isInputFocused: Bool
    
    // MARK: - Constants
    let maxInputLength = 10 // Prevent integer overflow
    
    // External URLs
    let wikipediaURL = "https://en.wikipedia.org/wiki/Prime_number"
    let oeisURL = "https://oeis.org/A000040"
    let appStoreURL = "http://apps.apple.com/us/app/prime-finder-app/id6741829020"
    let githubIssuesURL = "http://github.com/ahl-gram/PrimeFinder/issues"
    
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
    
    func isMersennePrime(_ number: Int) -> Bool {
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
    
    func allFactors(_ number: Int) -> [Int] {
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
    
    func findNextPrime(_ from: Int) -> Int? {
        var current = from + 1
        // Prevent integer overflow
        while current <= Int.max && current <= 9999999999 {
            if isPrime(current) {
                return current
            }
            current += 1
        }
        return nil
    }
    
    func findPreviousPrime(_ from: Int) -> Int? {
        var current = from - 1
        while current >= 2 {
            if isPrime(current) {
                return current
            }
            current -= 1
        }
        return nil
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
                result = "✅ \(formattedNumber) is a prime number."
            } else {
                let factors = primeFactors(number)
                let formattedFactors = factors.map { NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) }
                result = "🔹 \(formattedNumber) is not a prime number.\nPrime factors: \(formattedFactors.joined(separator: " × "))"
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
                
                // Remove leading zeros unless the entire input is "0"
                var processedInput = filtered
                if processedInput.count > 1 && processedInput.first == "0" {
                    processedInput = String(Int(processedInput) ?? 0)
                }
                
                // Enforce maximum length
                if processedInput.count > maxInputLength {
                    inputNumber = String(processedInput.prefix(maxInputLength))
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                } else {
                    inputNumber = processedInput
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
            // Left Arrow Button
            Button(action: {
                if let number = Int(inputNumber),
                   let previousPrime = findPreviousPrime(number) {
                    inputNumber = String(previousPrime)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    validateAndProcessInput()
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }) {
                Image(systemName: "arrowtriangle.left.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(primaryColor)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .opacity(inputNumber.isEmpty || (Int(inputNumber) ?? 0) <= 2 ? 0.5 : 1.0)
            }
            .disabled(inputNumber.isEmpty || (Int(inputNumber) ?? 0) <= 2)
            .accessibilityLabel("Previous Prime")

            // Minus Button
            Button(action: {
                if let number = Int(inputNumber) {
                    inputNumber = String(number - 1)
                    validateAndProcessInput()
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
                    Text("Check")
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
            .accessibilityLabel("Check Button")

            // Plus Button
            Button(action: {
                if let number = Int(inputNumber) {
                    inputNumber = String(number + 1)
                    validateAndProcessInput()
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

            // Right Arrow Button
            Button(action: {
                if let number = Int(inputNumber),
                   let nextPrime = findNextPrime(number) {
                    inputNumber = String(nextPrime)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    validateAndProcessInput()
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }) {
                Image(systemName: "arrowtriangle.right.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(primaryColor)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .opacity(inputNumber.isEmpty || inputNumber >= "9999999999" ? 0.5 : 1.0)
            }
            .disabled(inputNumber.isEmpty || inputNumber >= "9999999999")
            .accessibilityLabel("Next Prime")
        }
        .padding(.horizontal)
    }
    
    var resultView: some View {
        VStack(spacing: 8) {
            if !result.isEmpty {
                let components = result.components(separatedBy: "\n")
                Button(action: {
                    withAnimation(.spring()) {
                        isResultExpanded.toggle()
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let firstLine = components.first {
                            HStack {
                                Text(firstLine)
                                    .font(result.contains("Please enter") ? .body : .headline)
                                    .foregroundColor(result.contains("is a prime")
                                                   ? .green
                                                   : result.contains("is not a prime") || result.contains("defined as not")
                                                   ? primaryColor
                                                   : .red)
                                Spacer()
                                if !result.contains("Please enter") {
                                    Image(systemName: isResultExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                        .foregroundColor(result.contains("is a prime")
                                                       ? .green
                                                       : primaryColor)
                                        .imageScale(.large)
                                }
                            }
                        }
                        
                        if components.count > 1 {
                            Text(components.dropFirst().joined(separator: "\n"))
                                .font(.body)
                                .foregroundColor(primaryColor)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
                
                if isResultExpanded {
                    if let number = Int(inputNumber) {
                        VStack(alignment: .leading, spacing: 12) {
                            if !isPrime(number) && number > 1 {
                                Text("🔢 All Factors")
                                    .font(.headline)
                                    .foregroundColor(primaryColor)
                                
                                let factors = allFactors(number).sorted()
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(Array(factors.enumerated()), id: \.element) { index, factor in
                                        HStack(spacing: 12) {
                                            Text("\(index + 1).")
                                                .font(.body)
                                                .foregroundColor(.gray)
                                            Button(action: {
                                                inputNumber = String(factor)
                                                validateAndProcessInput()
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }) {
                                                Text("\(factor)")
                                                    .font(.system(.body, design: .monospaced))
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 12)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .fill(primaryColor.opacity(0.1))
                                                    )
                                                    .foregroundColor(primaryColor)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 100) // Changed to minHeight instead of fixed height
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.top, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
        }
        .padding(.horizontal)
        .multilineTextAlignment(.leading)
        .accessibilityLabel("Result Text View")
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
    
    var helpButton: some View {
        Button(action: {
            showingHelp = true
        }) {
            Image(systemName: "info.circle")
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
                                            item.result.contains("is not a prime number") || item.result.contains("defined as not") ? primaryColor : .red)
                    Text(item.timestamp, formatter: {
                        let formatter = DateFormatter()
                        formatter.timeStyle = .medium
                        return formatter
                    }())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .onDelete { indexSet in
                history.remove(atOffsets: indexSet)
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
    
    var helpView: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                           let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
                            Text("Prime Number Finder v\(version) (\(build))")
                                .font(.body)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Description")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Prime Number Finder helps you explore prime numbers and their factorization.")
                        .font(.body)
                    Text("A prime number is a natural number greater than 1 that is only divisible by 1 and itself.")
                        .font(.body)
                    Text("A composite number is any natural number greater than 1 that is not prime.")
                        .font(.body)
                    Text("The number 1 is a special case in which it is defined as not prime.")
                        .font(.body)
                        .padding(.top, 4)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Links")) {
                if let url = URL(string: wikipediaURL) {
                    VStack {
                        HStack {
                            Text("Wikipedia: Prime Numbers")
                                .font(.body)
                            Spacer()
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                Image(systemName: "arrow.up.right.square")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                if let url = URL(string: oeisURL) {
                    VStack {
                        HStack {
                            Text("OEIS: List of Prime Numbers")
                                .font(.body)
                            Spacer()
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                Image(systemName: "arrow.up.right.square")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                if let url = URL(string: appStoreURL) {
                    VStack {
                        HStack {
                            Text("Rate this app!")
                                .font(.body)
                            Spacer()
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                Image(systemName: "arrow.up.right.square")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                if let url = URL(string: githubIssuesURL) {
                    VStack {
                        HStack {
                            Text("Found a bug? Submit an issue")
                                .font(.body)
                            Spacer()
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                Image(systemName: "arrow.up.right.square")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            
            Section(header: Text("Features")) {
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "checkmark.circle.fill", title: "Check Numbers", description: "Enter any positive integer to check if it's prime")
                    FeatureRow(icon: "function", title: "Prime Factorization", description: "Composite numbers will automatically display their prime factorization")
                    FeatureRow(icon: "plus.circle.fill", title: "Increment/Decrement", description: "Use + and - buttons to check nearby numbers")
                    FeatureRow(icon: "arrowtriangle.right.circle.fill", title: "Prime Navigation", description: "Use arrow buttons to find the next or previous prime number")
                    FeatureRow(icon: "chevron.down.circle.fill", title: "Interactive Results", description: "Tap on results to view additional information and all factors for composite numbers")
                    FeatureRow(icon: "number.circle", title: "Interactive Factors", description: "Tap on any factor to instantly check if it's prime")
                    FeatureRow(icon: "clock.arrow.circlepath", title: "History", description: "View your previous number checks")
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Tips")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Numbers are limited to 10 digits to prevent overflow")
                    Text("• Clear the input field using the X button")
                    Text("• Tap anywhere to dismiss the keyboard")
                    Text("• Green results indicate prime numbers")
                    Text("• Blue results indicate composite numbers")
                    Text("• Tap any result to explore more details")
                    Text("• Rotate your device to landscape mode for more horizontal space")
                }
                .font(.body)
                .padding(.vertical, 4)
            }
            
            Section {
                HStack {
                    Spacer()
                    Text("© 2025 Alexander Lee - Route 12B Software")
                        .font(.caption)
                        .foregroundColor(.green)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    inputField
                    checkButton
                    
                    ScrollView {
                        resultView
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationBarTitle("Prime Number Finder", displayMode: .large)
            .navigationBarItems(
                leading: helpButton,
                trailing: historyButton
            )
            .sheet(isPresented: $showingHistory) {
                NavigationView {
                    historyView
                        .navigationTitle("History")
                        .navigationBarItems(
                            leading: Group {
                                HStack(spacing: 16) {
                                    if !history.isEmpty {
                                        Button(action: {
                                            showingResetAlert = true
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    Button(action: {
                                        withAnimation {
                                            editMode = editMode.isEditing ? .inactive : .active
                                        }
                                    }) {
                                        Image(systemName: editMode.isEditing ? "checkmark" : "square.and.pencil")
                                            .foregroundColor(editMode.isEditing ? .blue : .blue)
                                    }
                                }
                            },
                            trailing: Group {
                                if editMode == .inactive {
                                    Button("Done") {
                                        showingHistory = false
                                    }
                                }
                            }
                        )
                        .environment(\.editMode, $editMode)
                }
            }
            .sheet(isPresented: $showingHelp) {
                NavigationView {
                    helpView
                        .navigationTitle("About")
                        .navigationBarItems(trailing: Button("Done") {
                            showingHelp = false
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

// Helper view for feature rows in help screen
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .imageScale(.large)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}
