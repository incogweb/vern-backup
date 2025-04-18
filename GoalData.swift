//
//  GoalData.swift
//  Axer
//
//  Created by Oscar on 18/04/2025.
//

// GoalData.swift
import SwiftUI

class GoalManager: ObservableObject {
    @Published var goals: [Goal] = []
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
    }
}

struct Goal: Identifiable {
    let id: UUID
    let title: String
    let description: String
    var currentValue: Double
    let targetValue: Double
    let unit: String
    let startDate: Date
    let endDate: Date
    let color: Color
    let reminderEnabled: Bool
    let reminderTime: Date?
    
    var progress: CGFloat {
        min(CGFloat(currentValue / targetValue), 1.0)
    }
    
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
    }
    
    init(id: UUID = UUID(),
         title: String,
         description: String = "",
         currentValue: Double = 0,
         targetValue: Double,
         unit: String = "",
         startDate: Date = Date(),
         endDate: Date = Date().addingTimeInterval(30*24*3600),
         color: Color = .blue,
         reminderEnabled: Bool = false,
         reminderTime: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.unit = unit
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
    }
}
