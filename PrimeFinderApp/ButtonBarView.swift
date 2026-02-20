//
//  ButtonBarView.swift
//  PrimeFinderApp
//
//  Route 12B Software.
//

import SwiftUI

struct ButtonBarView: View {
    let inputNumber: String
    let isCalculating: Bool
    let maxNumberInput: UInt64
    let onPreviousPrime: () -> Void
    let onDecrement: () -> Void
    let onCheck: () -> Void
    let onIncrement: () -> Void
    let onNextPrime: () -> Void

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 10) {
                // Left Arrow Button
                Button(action: onPreviousPrime) {
                    Image(systemName: "arrowtriangle.left.circle.fill")
                        .imageScale(.large)
                }
                .buttonStyle(.glass)
                .tint(.blue)
                .disabled(inputNumber.isEmpty || (Int(inputNumber) ?? 0) <= 2)
                .accessibilityLabel("Previous Prime")

                // Minus Button
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle.fill")
                        .imageScale(.large)
                }
                .buttonStyle(.glass)
                .tint(.blue)
                .disabled(inputNumber.isEmpty || inputNumber <= "1")
                .accessibilityLabel("Decrement Number")

                // Check Button
                Button(action: onCheck) {
                    HStack {
                        ZStack {
                            if isCalculating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .transition(.opacity)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .transition(.opacity)
                            }
                        }
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
                    .fixedSize()
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .tint(.blue)
                .disabled(inputNumber.isEmpty)
                .accessibilityLabel("Check Button")

                // Plus Button
                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                }
                .buttonStyle(.glass)
                .tint(.blue)
                .disabled(inputNumber.isEmpty || inputNumber >= String(maxNumberInput))
                .accessibilityLabel("Increment Number")

                // Right Arrow Button
                Button(action: onNextPrime) {
                    Image(systemName: "arrowtriangle.right.circle.fill")
                        .imageScale(.large)
                }
                .buttonStyle(.glass)
                .tint(.blue)
                .disabled(inputNumber.isEmpty || inputNumber >= String(maxNumberInput))
                .accessibilityLabel("Next Prime")
            }
        }
        .padding(.horizontal)
    }
}
