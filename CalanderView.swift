//
//  CalanderView.swift
//  Axer
//
//  Created by Oscar on 18/04/2025.
//

import SwiftUI
import EventKit

class CalendarManager: ObservableObject {
    @Published var events: [EKEvent] = []
    let eventStore = EKEventStore()
    
    func requestAccessAndLoadEvents() {
        eventStore.requestAccess(to: .event) { granted, error in
            if granted && error == nil {
                self.loadEvents()
            }
        }
    }
    
    func loadEvents() {
        let calendars = eventStore.calendars(for: .event)
        let oneMonthAgo = Date(timeIntervalSinceNow: -30*24*3600)
        let oneMonthAfter = Date(timeIntervalSinceNow: +30*24*3600)
        
        let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.events = events
        }
    }
    
    func addEvent(title: String, startDate: Date, endDate: Date, isAllDay: Bool = false, notes: String = "") {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            loadEvents() // Refresh events
        } catch {
            print("Error saving event: \(error.localizedDescription)")
        }
    }
}

class TaskManager: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var habits: [HabitItem] = []
    
    func toggleCompletion(for task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tasks[index].isCompleted.toggle()
                
                if tasks[index].isCompleted && tasks[index].originalPosition == nil {
                    tasks[index].originalPosition = index
                }
                
                tasks.sort {
                    if $0.isCompleted == $1.isCompleted {
                        if $0.time.isEmpty && $1.time.isEmpty {
                            return ($0.originalPosition ?? 0) < ($1.originalPosition ?? 0)
                        } else if $0.time.isEmpty {
                            return false
                        } else if $1.time.isEmpty {
                            return true
                        } else {
                            return $0.time < $1.time
                        }
                    } else {
                        return !$0.isCompleted && $1.isCompleted
                    }
                }
            }
        }
    }
    
    var incompleteTasks: [TaskItem] {
        tasks.filter { !$0.isCompleted }
    }
    
    func addTask(_ task: TaskItem) {
        tasks.append(task)
    }
    
    func addHabit(_ habit: HabitItem) {
        habits.append(habit)
        // For demo purposes, add the habit as a task for today
        let task = TaskItem(title: habit.title, time: habit.time)
        tasks.append(task)
    }
}

struct TaskItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let time: String
    var isCompleted: Bool = false
    var originalPosition: Int? = nil
    
    init(title: String, time: String = "", isCompleted: Bool = false) {
        self.title = title
        self.time = time
        self.isCompleted = isCompleted
    }
}

struct HabitItem: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let days: [Int] // Days of week (1-7, Sunday=1)
}

enum EventType {
    case habit, todo, event
}

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var calendarManager: CalendarManager
    
    let type: EventType
    @State private var title = ""
    @State private var time = Date()
    @State private var date = Date()
    @State private var notes = ""
    @State private var selectedDays: [Int] = []
    @State private var isAllDay = false
    
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(type == .event ? "Event Title" : type == .habit ? "Habit Name" : "Task Name", text: $title)
                    
                    if type != .habit {
                        Toggle("All Day", isOn: $isAllDay)
                    }
                    
                    if type == .event || !isAllDay {
                        if type == .habit {
                            DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                        } else {
                            DatePicker("Starts", selection: type == .event ? $date : Binding(get: { time }, set: { time = $0 }), displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                            
                            if type == .event {
                                DatePicker("Ends", selection: Binding(get: { date.addingTimeInterval(3600) }, set: { _ in }), displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                            }
                        }
                    }
                    
                    if type == .habit {
                        Text("Repeat on:")
                        HStack {
                            ForEach(1...7, id: \.self) { day in
                                Button(action: {
                                    if selectedDays.contains(day) {
                                        selectedDays.removeAll { $0 == day }
                                    } else {
                                        selectedDays.append(day)
                                    }
                                }) {
                                    Text(daysOfWeek[day-1])
                                        .font(.caption)
                                        .padding(8)
                                        .background(selectedDays.contains(day) ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    
                    if type == .event {
                        TextField("Notes", text: $notes)
                    }
                }
                
                Section {
                    Button("Save") {
                        saveItem()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle(type == .habit ? "New Habit" : type == .todo ? "New Task" : "New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveItem() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        switch type {
        case .habit:
            let habit = HabitItem(
                title: title,
                time: formatter.string(from: time),
                days: selectedDays.isEmpty ? Array(1...7) : selectedDays
            )
            taskManager.addHabit(habit)
            
        case .todo:
            let task = TaskItem(
                title: title,
                time: isAllDay ? "" : formatter.string(from: time)
            )
            taskManager.addTask(task)
            
        case .event:
            let endDate = isAllDay ?
                Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date.addingTimeInterval(24*3600) :
                date.addingTimeInterval(3600)
            
            calendarManager.addEvent(
                title: title,
                startDate: date,
                endDate: endDate,
                isAllDay: isAllDay,
                notes: notes
            )
        }
    }
}

struct FixedHeader<Content: View>: View {
    let title: String
    let showAddButton: Bool
    let addAction: (() -> Void)?
    let showCalendarMenu: Bool
    @ViewBuilder let content: Content
    
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var showingHabitSheet = false
    @State private var showingTodoSheet = false
    @State private var showingEventSheet = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Fixed Header
                HStack(spacing: 0) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        // Plus button with menu or direct action
                        if showAddButton {
                            if showCalendarMenu {
                                // Calendar menu
                                Menu {
                                    Button(action: { showingHabitSheet.toggle() }) {
                                        Label("Add Daily Habit", systemImage: "repeat")
                                    }
                                    Button(action: { showingTodoSheet.toggle() }) {
                                        Label("Add To-Do", systemImage: "checkmark.circle")
                                    }
                                    Button(action: { showingEventSheet.toggle() }) {
                                        Label("Add Event", systemImage: "calendar")
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 20, weight: .medium))
                                        .frame(width: 24, height: 24)
                                }
                            } else {
                                // Direct action button
                                Button(action: {
                                    if let action = addAction {
                                        action()
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 20, weight: .medium))
                                        .frame(width: 24, height: 24)
                                }
                            }
                        }
                        
                        // Settings menu
                        Menu {
                            Button(action: { showingHistory.toggle() }) {
                                Label("History", systemImage: "book")
                            }
                            Button(action: { showingSettings.toggle() }) {
                                Label("Settings", systemImage: "gear")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 20, weight: .medium))
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.trailing, 16)
                }
                .frame(height: 44)
                .background(Color(.systemBackground).ignoresSafeArea(edges: .top))
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $showingHistory) {
                    HistoryView()
                }
                .sheet(isPresented: $showingHabitSheet) {
                    AddEventView(type: .habit)
                }
                .sheet(isPresented: $showingTodoSheet) {
                    AddEventView(type: .todo)
                }
                .sheet(isPresented: $showingEventSheet) {
                    AddEventView(type: .event)
                }
                
                // Scrollable Content
                ScrollView {
                    content
                        .frame(width: geometry.size.width)
                }
                .background(Color(.systemBackground))
            }
        }
    }
}

struct CalendarView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var calendarManager: CalendarManager
    
    // Computed property to filter today's events
    private var todaysEvents: [EKEvent] {
        calendarManager.events.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: Date())
        }
    }
    
    // Computed property to filter today's tasks
    private var todaysTasks: [TaskItem] {
        taskManager.tasks.filter { task in
            // For tasks without specific dates, we'll assume they're for today
            true // Modify this if you add dates to tasks
        }
    }
    
    var body: some View {
        FixedHeader(
            title: "Calendar",
            showAddButton: true,
            addAction: nil,
            showCalendarMenu: true
        ) {
            VStack(spacing: 0) {
                DatePicker("", selection: .constant(Date()), displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding()
                    .padding(.top, 8)
                
                // Display iOS Calendar Events
                if !todaysEvents.isEmpty {
                    calendarEventsSection
                }
                
                // Display Tasks
                if !todaysTasks.isEmpty {
                    tasksSection
                }
                
                Spacer()
                    .frame(height: 20)
            }
            .padding(.vertical)
        }
    }
    
    private var calendarEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calendar Events")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(todaysEvents, id: \.eventIdentifier) { event in
                    calendarEventRow(event: event)
                    
                    if event.eventIdentifier != todaysEvents.last?.eventIdentifier {
                        Divider()
                            .padding(.leading, 30)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private func calendarEventRow(event: EKEvent) -> some View {
        HStack {
            Circle()
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading) {
                Text(event.title)
                if !event.isAllDay {
                    Text(event.startDate.formatted(date: .omitted, time: .shortened) + " - " + event.endDate.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text("All Day")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Tasks")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(todaysTasks) { task in
                    TaskRow(task: task, isInCalendar: true)
                    
                    if task.id != todaysTasks.last?.id {
                        Divider()
                            .padding(.leading, 40)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}
