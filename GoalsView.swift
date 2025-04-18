// GoalsView.swift
import SwiftUI

struct GoalsView: View {
    @State private var showingAddGoal = false
    @StateObject private var goalManager = GoalManager()
    
    var body: some View {
        FixedHeader(
            title: "Goals",
            showAddButton: true,
            addAction: { showingAddGoal.toggle() },
            showCalendarMenu: false  // Add this parameter
        ) {
            if goalManager.goals.isEmpty {
                EmptyGoalsView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(goalManager.goals) { goal in
                            GoalWidget(
                                title: goal.title,
                                percent: goal.progress,
                                currentValue: goal.currentValue,
                                targetValue: goal.targetValue,
                                unit: goal.unit,
                                color: goal.color
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView()
                .environmentObject(goalManager)
        }
    }
}

struct EmptyGoalsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No Goals Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add your first goal to get started")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct GoalWidget: View {
    let title: String
    let percent: CGFloat
    let currentValue: Double
    let targetValue: Double
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: percent)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(percent * 100))%")
                    .font(.caption)
            }
            .frame(width: 50, height: 50)

            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.medium)
                Text("\(currentValue.formatted()) \(unit) of \(targetValue.formatted()) \(unit)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if percent > 0 {
                    Text(String(format: "%.0f%% remaining", ((targetValue - currentValue)/targetValue * 100)))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
    }
}

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var goalManager: GoalManager
    
    @State private var title = ""
    @State private var goalDescription = ""
    @State private var targetValue = ""
    @State private var unit = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(30*24*3600)
    @State private var colorIndex = 0
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    
    let colors: [Color] = [.blue, .green, .orange, .purple, .red]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Info")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $goalDescription)
                }
                
                Section(header: Text("Target")) {
                    HStack {
                        TextField("Target Value", text: $targetValue)
                            .keyboardType(.decimalPad)
                        TextField("Unit (e.g., $, kg)", text: $unit)
                    }
                }
                
                Section(header: Text("Timeline")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Color", selection: $colorIndex) {
                        ForEach(0..<colors.count, id: \.self) { index in
                            colors[index]
                                .frame(width: 30, height: 30)
                                .tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Toggle("Enable Reminders", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section {
                    Button("Save Goal") {
                        saveGoal()
                        dismiss()
                    }
                    .disabled(title.isEmpty || targetValue.isEmpty)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let target = Double(targetValue) else { return }
        
        let newGoal = Goal(
            title: title,
            description: goalDescription,
            targetValue: target,
            unit: unit,
            startDate: startDate,
            endDate: endDate,
            color: colors[colorIndex],
            reminderEnabled: reminderEnabled,
            reminderTime: reminderEnabled ? reminderTime : nil
        )
        
        goalManager.addGoal(newGoal)
    }
}
