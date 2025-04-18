//
//  DashboardView.swift
//  Axer
//
//  Created by Oscar on 18/04/2025.
//

import SwiftUI
import EventKit

struct DashboardView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        FixedHeader(
            title: "Dashboard",
            showAddButton: true,
            addAction: {},
            showCalendarMenu: true
        ) {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date.now.formatted(date: .complete, time: .omitted))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Updated Goals Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Goals")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    let screenWidth = UIScreen.main.bounds.width
                    let horizontalPadding: CGFloat = 32
                    let spacing: CGFloat = 20
                    let squareWidth = (screenWidth - horizontalPadding - spacing) / 2

                    HStack(spacing: spacing) {
                        GoalProgressSquare(title: "Books Read", progress: 0.4, current: 8, target: 20)
                            .frame(width: squareWidth, height: squareWidth)

                        GoalMoneySquare(amount: 6700, target: 10000, title: "Saved")
                            .frame(width: squareWidth, height: squareWidth)
                    }
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Tasks")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 10) {
                        ForEach(taskManager.incompleteTasks) { task in
                            TaskRow(task: task, isInCalendar: false)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

struct GoalProgressSquare: View {
    let title: String
    let progress: CGFloat
    let current: Int
    let target: Int

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(Int(progress * 100))%")
                    .font(.headline)
            }
            .frame(width: 60, height: 60)

            VStack(spacing: 4) {
                Text("\(current)/\(target)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct GoalMoneySquare: View {
    let amount: Int
    let target: Int
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("$\(amount)")
                    .font(.system(size: 22, weight: .bold))

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 2) {
                Text("Target")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("$\(target)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct TaskRow: View {
    @EnvironmentObject var taskManager: TaskManager
    let task: TaskItem
    let isInCalendar: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                taskManager.toggleCompletion(for: task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.system(size: isInCalendar ? 24 : 20))
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .gray : .primary)
            
            Spacer()
            
            if !task.time.isEmpty {
                Text(task.time)
                    .font(.subheadline)
                    .foregroundColor(task.isCompleted ? .gray : .gray)
            }
        }
        .padding(.vertical, 8)
        .opacity(task.isCompleted && !isInCalendar ? 0 : 1)
        .transition(.move(edge: .leading).combined(with: .opacity))
    }
}
