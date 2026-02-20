//
//  ContentView.swift
//  PrimeFinderApp
//
//  Route 12B Software.
//

import SwiftUI

struct ContentView: View {
    @State internal var inputNumber: String = ""
    @State internal var result: String = ""
    @State internal var history: [HistoryItem] = []
    @State internal var showingHistory = false
    @State internal var showingHelp = false
    @State internal var showingResetAlert = false
    @State internal var isResultExpanded = false
    @State private var editMode = EditMode.inactive
    @State internal var isCalculating = false
    @State internal var calculationStartTime: Date?
    @State internal var currentFactors: [UInt64] = []
    @State internal var currentCalculationID: UUID = UUID()
    @FocusState internal var isInputFocused: Bool
    @State internal var isUserTyping = true
    @State internal var isButtonChange = false

    // MARK: - Constants
    let maxInputLength = 18
    let maxNumberInput = PrimeFinderUtils.maxNumberInput

    // MARK: - Colors
    let primaryColor = Color.blue
    let backgroundColor = Color(.systemBackground)
    let secondaryBackgroundColor = Color(.systemGray6)

    // MARK: - Font Scaling
    internal func calculateFontSize(for inputLength: Int) -> CGFloat {
        let titleSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
        let minSize = UIFont.preferredFont(forTextStyle: .callout).pointSize

        let digitsThreshold: Int
        if titleSize <= 20 {
            digitsThreshold = 18
        } else if titleSize <= 25 {
            digitsThreshold = 16
        } else if titleSize <= 30 {
            digitsThreshold = 14
        } else {
            digitsThreshold = 12
        }

        if inputLength <= digitsThreshold {
            return titleSize
        } else {
            let scaleRate: CGFloat
            if titleSize <= 20 {
                scaleRate = 0.015
            } else if titleSize <= 25 {
                scaleRate = 0.02
            } else {
                scaleRate = min(0.025, 0.02 + (titleSize / 1000))
            }

            let extraDigits = CGFloat(inputLength - digitsThreshold)
            let scaleFactor = 1.0 - (extraDigits * scaleRate)
            let scaledSize = titleSize * max(scaleFactor, minSize/titleSize)
            return max(scaledSize, minSize)
        }
    }

    // MARK: - Formatting Helpers
    internal func formatLargeNumber(_ numberString: String) -> String {
        var result = ""
        var remainingDigits = numberString

        while remainingDigits.count > 3 {
            let endIndex = remainingDigits.index(remainingDigits.endIndex, offsetBy: -3)
            let lastThree = String(remainingDigits[endIndex...])
            result = "," + lastThree + result
            remainingDigits = String(remainingDigits[..<endIndex])
        }

        if !remainingDigits.isEmpty {
            return remainingDigits + result
        } else {
            return String(result.dropFirst())
        }
    }

    internal func formatDisplayNumber(_ number: UInt64) -> String {
        if number > 9_999_999_999_999_000 {
            return formatLargeNumber(String(number))
        } else {
            return NumberFormatter.localizedString(from: NSNumber(value: number), number: .decimal)
        }
    }

    // MARK: - Keyboard Dismissal
    func dismissKeyboard() {
        isInputFocused = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - History
    func addToHistory(number: UInt64, result: String) {
        let historyItem = HistoryItem(number: number, result: result, timestamp: Date())
        history.insert(historyItem, at: 0)
    }

    // MARK: - Business Logic
    func validateAndProcessInput() {
        dismissKeyboard()

        guard PrimeFinderUtils.isValidInput(inputNumber) else {
            result = "Please enter a valid positive integer."
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        guard let number: UInt64 = UInt64(inputNumber) else { return }

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        if isResultExpanded {
            currentFactors = []
            if !PrimeFinderUtils.isPrime(number) && number > 1 {
                calculateFactors(for: number)
            }
        }

        let formattedNumber: String
        if number > 9_999_999_999_999_000 {
            formattedNumber = formatLargeNumber(String(number))
        } else {
            formattedNumber = NumberFormatter.localizedString(from: NSNumber(value: number), number: .decimal)
        }

        if number == 1 {
            result = "\(formattedNumber) is defined as not a prime number."
        }
        else {
            if PrimeFinderUtils.isPrime(number) {
                result = "\(formattedNumber) is a prime number."
            } else {
                let factors = PrimeFinderUtils.primeFactors(number)
                let formattedFactors = factors.map {
                    let factor = $0
                    if factor > 9_999_999_999_999_000 {
                        return formatLargeNumber(String(factor))
                    } else {
                        return NumberFormatter.localizedString(from: NSNumber(value: factor), number: .decimal)
                    }
                }
                result = "\(formattedNumber) is not a prime number.\nPrime factors: \(formattedFactors.joined(separator: " × "))"
            }
        }
        addToHistory(number: number, result: result)
    }

    internal func calculateFactors(for number: UInt64) {
        if isCalculating {
            currentCalculationID = UUID()
        }

        currentFactors = []
        calculationStartTime = Date()

        let thisCalculationID = currentCalculationID

        Task.detached(priority: .userInitiated) {
            let startTime = Date()

            let spinnerTask = Task {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    await MainActor.run {
                        if thisCalculationID == self.currentCalculationID {
                            self.isCalculating = true
                        }
                    }
                } catch {
                    // Task was cancelled
                }
            }

            let factors = PrimeFinderUtils.allFactors(number).sorted()
            let _ = Date().timeIntervalSince(startTime)
            spinnerTask.cancel()

            await MainActor.run {
                if thisCalculationID == self.currentCalculationID {
                    self.currentFactors = factors
                    self.isCalculating = false

                    if result.isEmpty && !inputNumber.isEmpty, let number = UInt64(inputNumber) {
                        if number == 1 {
                            result = "\(number) is defined as not a prime number."
                        }
                        else {
                            if PrimeFinderUtils.isPrime(number) {
                                let formattedNumber: String
                                if number > 9_999_999_999_999_000 {
                                    formattedNumber = formatLargeNumber(String(number))
                                } else {
                                    formattedNumber = NumberFormatter.localizedString(from: NSNumber(value: number), number: .decimal)
                                }
                                result = "\(formattedNumber) is a prime number."
                            } else {
                                let primeFactors = PrimeFinderUtils.primeFactors(number)
                                let formattedNumber: String
                                if number > 9_999_999_999_999_000 {
                                    formattedNumber = formatLargeNumber(String(number))
                                } else {
                                    formattedNumber = NumberFormatter.localizedString(from: NSNumber(value: number), number: .decimal)
                                }
                                let formattedFactors = primeFactors.map {
                                    let factor = $0
                                    if factor > 9_999_999_999_999_000 {
                                        return formatLargeNumber(String(factor))
                                    } else {
                                        return NumberFormatter.localizedString(from: NSNumber(value: factor), number: .decimal)
                                    }
                                }
                                result = "\(formattedNumber) is not a prime number.\nPrime factors: \(formattedFactors.joined(separator: " × "))"
                            }
                        }
                        addToHistory(number: number, result: result)
                    }
                }
            }
        }
    }

    // MARK: - Input Field
    var inputField: some View {
        HStack {
            if !inputNumber.isEmpty {
                Button(action: {
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
                }
            }

            Spacer()

            if inputNumber.isEmpty {
                Text("0")
                    .foregroundColor(.gray)
                    .font(.system(size: UIFont.preferredFont(forTextStyle: .title1).pointSize, weight: .medium, design: .rounded))
                    .padding(.trailing, 16)
            } else if let number = UInt64(inputNumber) {
                Text(formatDisplayNumber(number))
                    .foregroundColor(.primary)
                    .font(.system(size: calculateFontSize(for: inputNumber.count), weight: .medium, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 56)
        .background(
            secondaryBackgroundColor
                .cornerRadius(12)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
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
                .onChange(of: inputNumber) {
                    if isButtonChange {
                        isButtonChange = false
                    } else {
                        isUserTyping = true
                    }

                    let filtered = inputNumber.filter { "0123456789".contains($0) }

                    if filtered != inputNumber {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }

                    var processedInput = filtered
                    if processedInput.count > 1 && processedInput.first == "0" {
                        processedInput = String(Int(processedInput) ?? 0)
                    }

                    if processedInput.count > maxInputLength {
                        inputNumber = String(processedInput.prefix(maxInputLength))
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    } else {
                        inputNumber = processedInput
                    }

                    if isUserTyping && !result.isEmpty {
                        result = ""
                        if isResultExpanded {
                            isResultExpanded = false
                            currentFactors = []
                            isCalculating = false
                            currentCalculationID = UUID()
                        }
                    }
                }
        )
        .onTapGesture {
            isInputFocused = true
        }
        .accessibilityLabel("Input Number Field")
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 20) {
                    inputField

                    ButtonBarView(
                        inputNumber: inputNumber,
                        isCalculating: isCalculating,
                        maxNumberInput: maxNumberInput,
                        onPreviousPrime: {
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
                        },
                        onDecrement: {
                            isUserTyping = false
                            isButtonChange = true
                            if let number = Int(inputNumber) {
                                inputNumber = String(number - 1)
                                validateAndProcessInput()
                            }
                        },
                        onCheck: {
                            validateAndProcessInput()
                        },
                        onIncrement: {
                            isUserTyping = false
                            isButtonChange = true
                            if let number = Int(inputNumber) {
                                inputNumber = String(number + 1)
                                validateAndProcessInput()
                            }
                        },
                        onNextPrime: {
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
                        }
                    )

                    ScrollView {
                        VStack {
                            ResultView(
                                result: result,
                                inputNumber: inputNumber,
                                isResultExpanded: $isResultExpanded,
                                currentFactors: currentFactors,
                                isCalculating: isCalculating,
                                primaryColor: primaryColor,
                                onExpandToggle: {
                                    withAnimation(.spring()) {
                                        isResultExpanded.toggle()

                                        if !isResultExpanded {
                                            currentFactors = []
                                            isCalculating = false
                                            currentCalculationID = UUID()
                                        } else if let number = UInt64(inputNumber),
                                                  !PrimeFinderUtils.isPrime(number),
                                                  number > 1 {
                                            calculateFactors(for: number)
                                        }
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                },
                                onFactorTapped: { factor in
                                    isUserTyping = false
                                    isButtonChange = true
                                    inputNumber = String(factor)
                                    validateAndProcessInput()
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                },
                                calculateFactors: { number in
                                    if !isUserTyping {
                                        calculateFactors(for: number)
                                    }
                                },
                                formatLargeNumber: formatLargeNumber
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollEdgeEffectStyle(.soft, for: .all)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.top)
                .scenePadding(.horizontal)
            }
            .navigationTitle("Prime Number Finder")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingHelp = true }) {
                        Image(systemName: "info.circle")
                            .imageScale(.large)
                            .foregroundColor(primaryColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingHistory = true }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .imageScale(.large)
                            .foregroundColor(primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                NavigationStack {
                    HistoryView(
                        history: $history,
                        showingResetAlert: $showingResetAlert,
                        primaryColor: primaryColor
                    )
                    .navigationTitle("History")
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
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
                                    .foregroundColor(.blue)
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            if editMode == .inactive {
                                Button("Done") {
                                    showingHistory = false
                                }
                            }
                        }
                    }
                    .environment(\.editMode, $editMode)
                }
            }
            .sheet(isPresented: $showingHelp) {
                NavigationStack {
                    HelpView(maxInputLength: maxInputLength)
                        .navigationTitle("About")
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    showingHelp = false
                                }
                            }
                        }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isInputFocused {
                    dismissKeyboard()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
