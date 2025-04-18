//
//  HistoryView.swift
//  Axer
//
//  Created by Oscar on 18/04/2025.
//

import SwiftUI
import EventKit

struct HistoryView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Completed Goals")) {
                    Text("Saved $10K - Jan 2023")
                    Text("Read 20 books - Dec 2022")
                }
                
                Section(header: Text("Habit Streaks")) {
                    Text("Meditation - 120 days")
                    Text("Exercise - 90 days")
                }
                
                Section(header: Text("Workouts")) {
                    Text("Chest Day - 50 sessions")
                    Text("Leg Day - 30 sessions")
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: .constant(""), prompt: "Search history")
        }
    }
}
