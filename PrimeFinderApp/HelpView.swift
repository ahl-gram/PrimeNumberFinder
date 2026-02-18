//
//  HelpView.swift
//  PrimeFinderApp
//
//  Route 12B Software.
//

import SwiftUI

struct HelpView: View {
    let maxInputLength: Int

    // External URLs
    private let wikipediaURL = "https://en.wikipedia.org/wiki/Prime_number"
    private let oeisURL = "https://oeis.org/A000040"
    private let appStoreURL = "http://apps.apple.com/us/app/prime-finder-app/id6741829020"
    private let githubIssuesURL = "http://github.com/ahl-gram/PrimeNumberFinder/issues"

    var body: some View {
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
                LinkRow(title: "Wikipedia: Prime Numbers", urlString: wikipediaURL)
                LinkRow(title: "OEIS: List of Prime Numbers", urlString: oeisURL)
                LinkRow(title: "Rate this app!", urlString: appStoreURL)
                LinkRow(title: "Found a bug? Submit an issue", urlString: githubIssuesURL)
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
}

// MARK: - Supporting Views

struct LinkRow: View {
    let title: String
    let urlString: String

    var body: some View {
        if let url = URL(string: urlString) {
            VStack {
                HStack {
                    Text(title)
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
}

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
