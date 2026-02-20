//
//  ResultView.swift
//  PrimeFinderApp
//
//  Route 12B Software.
//

import SwiftUI

struct ResultView: View {
    let result: String
    let inputNumber: String
    @Binding var isResultExpanded: Bool
    let currentFactors: [UInt64]
    let isCalculating: Bool
    let primaryColor: Color
    let onExpandToggle: () -> Void
    let onFactorTapped: (UInt64) -> Void
    let calculateFactors: (UInt64) -> Void
    let formatLargeNumber: (String) -> String

    private var resultIcon: some View {
        Group {
            if result.contains("is a prime") {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                            .offset(x: 4, y: -4)
                    }
            } else if result.contains("is not a prime") || result.contains("defined as not") {
                Image(systemName: "xmark.seal.fill")
                    .imageScale(.large)
                    .foregroundStyle(.white)
            } else if result.contains("Please enter") {
                Image(systemName: "exclamationmark.triangle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.white)
            } else {
                Image(systemName: "info.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.white)
            }
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            if !result.isEmpty {
                let components = result.components(separatedBy: "\n")
                Button(action: {
                    onExpandToggle()
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let firstLine = components.first {
                            HStack {
                                resultIcon
                                Text(firstLine)
                                    .font(result.contains("Please enter") ? .body : .headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                if result.contains("is not a prime") {
                                    Image(systemName: isResultExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                        .foregroundStyle(.white)
                                        .imageScale(.large)
                                }
                            }
                        }

                        if components.count > 1 {
                            Text(components.dropFirst().joined(separator: "\n"))
                                .font(.body)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .glassEffect(
                        .regular.tint(result.contains("is a prime") ? .indigo
                                      : result.contains("is not a prime") || result.contains("defined as not") ? .blue
                                      : .red),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)

                if isResultExpanded {
                    if let number = UInt64(inputNumber), !PrimeFinderUtils.isPrime(number), number > 1 {
                        allFactorsSection(for: number)
                    }
                }
            }
        }
        .padding(.horizontal)
        .multilineTextAlignment(.leading)
        .accessibilityLabel("Result Text View")
        .animation(.easeInOut, value: result)
    }

    // MARK: - All Factors Section

    private func allFactorsSection(for number: UInt64) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("All factors", systemImage: "number.square.fill")
                .font(.headline)
                .foregroundColor(primaryColor)

            ZStack {
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
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(currentFactors.enumerated()), id: \.element) { index, factor in
                            factorRow(index: index, factor: factor)
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
                .fill(primaryColor.opacity(0.15))
        )
        .padding(.top, 4)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            calculateFactors(number)
        }
        .onChange(of: number) {
            calculateFactors(number)
        }
    }

    private func factorRow(index: Int, factor: UInt64) -> some View {
        let indexWidth = getIndexColumnWidth(totalCount: currentFactors.count)

        return HStack(spacing: 12) {
            Text("\(index + 1).")
                .font(.body)
                .foregroundColor(primaryColor)
                .frame(width: indexWidth, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: factor > 1_000_000) {
                Button(action: {
                    onFactorTapped(factor)
                }) {
                    Group {
                        if factor > 9_999_999_999_999_000 {
                            Text(formatLargeNumber(String(factor)))
                        } else {
                            Text(NumberFormatter.localizedString(
                                from: NSNumber(value: factor), number: .decimal))
                        }
                    }
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(primaryColor)
                    )
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }

    private func getIndexColumnWidth(totalCount: Int) -> CGFloat {
        if totalCount < 10 {
            return 24
        } else if totalCount < 100 {
            return 32
        } else if totalCount < 1000 {
            return 42
        } else {
            return 52
        }
    }
}
