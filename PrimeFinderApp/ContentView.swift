//
//  ContentView.swift
//  PrimeFinderApp
//
//  Created by Alexander Lee on 2/8/25.
//

import SwiftUI

struct HistoryItem: Identifiable, Equatable {
    let id = UUID()
    let number: UInt64
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
    @State private var isCalculating = false
    @State private var calculationStartTime: Date?
    @State private var currentFactors: [UInt64] = []
    @State private var currentCalculationID: UUID = UUID()
    @FocusState internal var isInputFocused: Bool
    @State private var isUserTyping = true
    @State private var isButtonChange = false // Track if change is from a button
    
    // MARK: - Constants
    let maxInputLength = 18
    let maxNumberInput = PrimeFinderUtils.maxNumberInput
    
    // External URLs
    let wikipediaURL = "https://en.wikipedia.org/wiki/Prime_number"
    let oeisURL = "https://oeis.org/A000040"
    let appStoreURL = "http://apps.apple.com/us/app/prime-finder-app/id6741829020"
    let githubIssuesURL = "http://github.com/ahl-gram/PrimeFinder/issues"
    
    // MARK: - Colors
    let primaryColor = Color.blue
    let backgroundColor = Color(.systemBackground)
    let secondaryBackgroundColor = Color(.systemGray6)
    
    // MARK: - Computed Properties
    private var factorsForCurrentNumber: [UInt64] {
        return currentFactors
    }
    
    // MARK: - Helper Methods
    private func calculateFactors(for number: UInt64) {
        // Generate a new calculation ID to invalidate any current calculation
        if isCalculating {
            currentCalculationID = UUID()
        }
        
        // Reset any previous factors but don't show calculating state yet
        currentFactors = []
        calculationStartTime = Date()
        
        // Don't immediately show calculating state
        // We'll show it only if the calculation takes longer than 1 second
        
        // Capture the current calculation ID to check if this task is still valid later
        let thisCalculationID = currentCalculationID
        
        // Create a detached task to do the calculation in the background
        Task.detached(priority: .userInitiated) {
            // Start a timer to check if calculation takes > 1000ms
            let startTime = Date()
            
            // Set a timer to show the spinner if calculation takes > 1 second
            // This task will be cancelled if the calculation completes quickly
            let spinnerTask = Task {
                do {
                    // Wait 1 second before showing the spinner
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    
                    // After 1 second, show the spinner if this is still the current calculation
                    await MainActor.run {
                        if thisCalculationID == self.currentCalculationID {
                            self.isCalculating = true
                        }
                    }
                } catch {
                    // Task was cancelled, which is expected if calculation completes quickly
                }
            }
            
            // Perform the actual calculation
            let factors = PrimeFinderUtils.allFactors(number).sorted()
            
            // Calculate the duration
            let duration = Date().timeIntervalSince(startTime)
            
            // Cancel the spinner task if it hasn't triggered yet
            spinnerTask.cancel()
            
            // Update the UI on the main thread, but only if this is still the current calculation
            await MainActor.run {
                // Check if this task is still the current one
                if thisCalculationID == self.currentCalculationID {
                    // Update state with results
                    self.currentFactors = factors
                    self.isCalculating = false
                    self.calculationStartTime = nil
                }
            }
        }
    }
    
    // Helper function to calculate the width needed for the index column
    private func getIndexColumnWidth(totalCount: Int) -> CGFloat {
        if totalCount < 10 {
            return 24 // Single digit (plus dot)
        } else if totalCount < 100 {
            return 32 // Double digit (plus dot)
        } else if totalCount < 1000 {
            return 42 // Triple digit (plus dot)
        } else {
            return 52 // For very large collections
        }
    }
    
    // MARK: - Keyboard Dismissal
    func dismissKeyboard() {
        isInputFocused = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func addToHistory(number: UInt64, result: String) {
        let historyItem = HistoryItem(number: number, result: result, timestamp: Date())
        history.insert(historyItem, at: 0) // Add to beginning of array
    }
    
    func validateAndProcessInput() {
        dismissKeyboard()
        
        guard PrimeFinderUtils.isValidInput(inputNumber) else {
            result = "Please enter a valid positive integer."
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        guard let number: UInt64 = UInt64(inputNumber) else { return }
        
        // Provide success haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Reset factors if the results area is expanded
        if isResultExpanded {
            currentFactors = []
            if !PrimeFinderUtils.isPrime(number) && number > 1 {
                // Don't immediately set isCalculating - our calculation method will handle it
                // if the operation takes more than 1 second
                calculateFactors(for: number)
            }
        }
        
        // Format number with thousands separator
        let formattedNumber = NumberFormatter.localizedString(from: NSNumber(value: number), number: .decimal)
        
        if number == 1 {
            result = "\(formattedNumber) is defined as not a prime number."
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
        addToHistory(number: number, result: result)
    }
    
    // MARK: - View Components
    var inputField: some View {
        ZStack(alignment: .leading) {
            // Background
            secondaryBackgroundColor
                .cornerRadius(12)
                .padding(.horizontal)
            
            HStack {
                // Clear button
                if !inputNumber.isEmpty {
                    Button(action: {
                        // This is a direct user action, so set isUserTyping to true
                        isUserTyping = true
                        isButtonChange = true
                        inputNumber = ""
                        result = ""
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .imageScale(.medium)
                            .padding(.leading, 16)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 8)
                    }
                }
                
                Spacer()
                
                // This is a custom view that displays the formatted number
                // but allows editing with the number pad
                if inputNumber.isEmpty {
                    Text("0")
                        .foregroundColor(.gray)
                        .padding(.trailing, 16)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .font(.title)
                        .multilineTextAlignment(.trailing)
                } else if let number = UInt64(inputNumber) {
                    // Format with thousands separators
                    Text(NumberFormatter.localizedString(from: NSNumber(value: number), number: .decimal))
                        .padding(.trailing, 16)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .foregroundColor(.primary)
                        .font(.title)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .frame(height: 56)
        .padding(.vertical, 4)
        .onTapGesture {
            isInputFocused = true
        }

        // Invisible TextField to handle the actual input
        .overlay(
            TextField("", text: $inputNumber)
                .keyboardType(.numberPad)
                .focused($isInputFocused)
                .opacity(0)
                .frame(width: 0, height: 0)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            dismissKeyboard()
                        }
                    }
                }
                .onChange(of: inputNumber) { newValue in
                    // Only set isUserTyping to true if this is not a programmatic change
                    if isButtonChange {
                        // Reset the flag for the next change
                        isButtonChange = false
                    } else {
                        isUserTyping = true
                    }
                    
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
                    
                    // Clear result only when user is directly typing
                    if isUserTyping && !result.isEmpty {
                        result = ""
                        if isResultExpanded {
                            isResultExpanded = false
                            currentFactors = []
                            isCalculating = false
                            // Generate a new ID to invalidate any ongoing calculations
                            currentCalculationID = UUID()
                        }
                    }
                }
        )
        .accessibilityLabel("Input Number Field")
    }
    
    var checkButton: some View {
        HStack(spacing: 10) {
            // Left Arrow Button
            Button(action: {
                // Set flags to indicate this is not direct user typing
                isUserTyping = false
                isButtonChange = true
                
                if let number = UInt64(inputNumber),
                   let previousPrime = PrimeFinderUtils.findPreviousPrime(number) {
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
                // Set flags to indicate this is not direct user typing
                isUserTyping = false
                isButtonChange = true
                
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
                    ZStack {
                        if isCalculating {
                            // Show spinner when calculation is in progress
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .tint(.white)
                                .transition(.opacity)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .transition(.opacity)
                        }
                    }
                    .frame(width: 20, height: 20)
                    .animation(.easeInOut(duration: 0.3), value: isCalculating)
                    
                    ZStack {
                        if isCalculating {
                            Text("Calculating...")
                                .font(.headline)
                                .transition(.opacity)
                        } else {
                            Text("Check")
                                .font(.headline)
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: isCalculating)
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
                // Set flags to indicate this is not direct user typing
                isUserTyping = false
                isButtonChange = true
                
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
                    .opacity(inputNumber.isEmpty || inputNumber >= String(maxNumberInput) ? 0.5 : 1.0)
            }
            .disabled(inputNumber.isEmpty || inputNumber >= String(maxNumberInput))
            .accessibilityLabel("Increment Number")

            // Right Arrow Button
            Button(action: {
                // Set flags to indicate this is not direct user typing
                isUserTyping = false
                isButtonChange = true
                
                if let number = UInt64(inputNumber),
                   let nextPrime = PrimeFinderUtils.findNextPrime(number) {
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
                    .opacity(inputNumber.isEmpty || inputNumber >= String(maxNumberInput) ? 0.5 : 1.0)
            }
            .disabled(inputNumber.isEmpty || inputNumber >= String(maxNumberInput))
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
                        
                        // If collapsing the results, clear the factors and calculation state
                        if !isResultExpanded {
                            currentFactors = []
                            isCalculating = false
                            // Generate a new ID to invalidate any ongoing calculations
                            currentCalculationID = UUID()
                        } else if let number = UInt64(inputNumber), 
                                  !PrimeFinderUtils.isPrime(number), 
                                  number > 1 {
                            // When expanding, start the calculation
                            // The calculateFactors method will handle showing the spinner
                            // only if the calculation takes more than 1 second
                            calculateFactors(for: number)
                        }
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
                                if result.contains("is not a prime") {
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
                    if let number = UInt64(inputNumber), !PrimeFinderUtils.isPrime(number), number > 1 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🔢 All factors")
                                .font(.headline)
                                .foregroundColor(primaryColor)
                            
                            // Wrap both states in an animation container for smooth transitions
                            ZStack {
                                // If factors are still being calculated, show a loading indicator
                                if isCalculating {
                                    HStack {
                                        Spacer()
                                        VStack {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                            Text("Calculating...")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.top, 8)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 20)
                                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
                                } else {
                                    // Use a computed property for the factors array
                                    // This way, we're not recalculating every time the view redraws
                                    let factors = factorsForCurrentNumber
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(Array(factors.enumerated()), id: \.element) { index, factor in
                                            // Format large numbers with thousands separator for display
                                            let formattedNumber = NumberFormatter.localizedString(
                                                from: NSNumber(value: factor), number: .decimal)
                                            
                                            HStack(spacing: 12) {
                                                // Use a dynamic width based on the number of digits in the index
                                                let indexWidth = getIndexColumnWidth(totalCount: factors.count)
                                                
                                                Text("\(index + 1).")
                                                    .font(.body)
                                                    .foregroundColor(.gray)
                                                    .frame(width: indexWidth, alignment: .leading)
                                                
                                                // For very large factors, use scrolling
                                                ScrollView(.horizontal, showsIndicators: factor > 1_000_000) {
                                                    Button(action: {
                                                        isUserTyping = false
                                                        isButtonChange = true
                                                        inputNumber = String(factor)
                                                        validateAndProcessInput()
                                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                    }) {
                                                        Text(formattedNumber)
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
                                                
                                                Spacer(minLength: 0)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: isCalculating)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.top, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            // When this view appears, start calculating factors in the background
                            calculateFactors(for: number)
                        }
                        .onChange(of: number) { newNumber in
                            // Recalculate factors when the number changes while view is expanded
                            calculateFactors(for: newNumber)
                        }
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
                    FeatureRow(icon: "number.circle", title: "Interactive Factors", description: "Tap on any factor in the list to instantly check if it's prime")
                    FeatureRow(icon: "clock.arrow.circlepath", title: "History", description: "View your previous number checks")
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Tips")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Numbers are limited to \(maxInputLength) digits to prevent overflow")
                    Text("• Clear the input field using the 🅧 button")
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
                    //Text("Prime Number Finder").font(.largeTitle).bold()
                    inputField
                    checkButton
                    
                    ScrollView {
                        VStack {
                            resultView
                        }
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
