//
//  HistoryView.swift
//  PrimeFinderApp
//
//  Route 12B Software.
//

import SwiftUI

struct HistoryItem: Identifiable, Equatable {
    let id = UUID()
    let number: UInt64
    let result: String
    let timestamp: Date
}

struct HistoryView: View {
    @Binding var history: [HistoryItem]
    @Binding var showingResetAlert: Bool
    let primaryColor: Color

    var body: some View {
        List {
            ForEach(history) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(item.number)")
                        .font(.headline)
                    Text(item.result)
                        .font(.subheadline)
                        .foregroundColor(item.result.contains("is a prime number") ? .indigo :
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
        .scrollEdgeEffectStyle(.soft, for: .all)
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
}
