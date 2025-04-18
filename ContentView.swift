import SwiftUI
import EventKit

@main
struct MainAppEntry: App {
    @StateObject var themeSettings = ThemeSettings()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(themeSettings)
                .preferredColorScheme(themeSettings.selectedTheme.colorScheme)
                .accentColor(themeSettings.selectedTheme.primaryColor)
        }
    }
}

struct MainTabView: View {
    @StateObject var taskManager = TaskManager()
    @StateObject var calendarManager = CalendarManager()
    @StateObject var themeSettings = ThemeSettings()
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(taskManager)
                .environmentObject(calendarManager)
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
            
            CalendarView()
                .environmentObject(taskManager)
                .environmentObject(calendarManager)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
        }
        .onAppear {
            calendarManager.requestAccessAndLoadEvents()
        }
    }
}
