//
//  SettingsView.swift
//  Axer
//
//  Created by Oscar on 18/04/2025.
//

import SwiftUI
import EventKit

struct SettingsView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    NavigationLink {
                        ThemeSelectionView()
                            .environmentObject(themeSettings)
                    } label: {
                        HStack {
                            Text("Theme")
                            Spacer()
                            Text(themeSettings.selectedTheme.rawValue.capitalized)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Toggle("Use System Appearance", isOn: Binding(
                        get: { themeSettings.selectedTheme == .system },
                        set: { newValue in
                            themeSettings.selectedTheme = newValue ? .system : .light
                        }
                    ))
                }
                
                Section(header: Text("Data")) {
                    NavigationLink("Backup & Export", destination: BackupView())
                    NavigationLink("Sync", destination: SyncSettingsView())
                }
                
                Section(header: Text("About")) {
                    NavigationLink("Help", destination: HelpView())
                    NavigationLink("Version", destination: VersionView())
                    NavigationLink("Privacy Policy", destination: PrivacyPolicyView())
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


// Placeholder for Backup View
struct BackupView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Backup Options")) {
                    Button("Create Backup") {
                        // Backup functionality will go here
                    }
                    
                    Button("Restore from Backup") {
                        // Restore functionality will go here
                    }
                }
                
                Section {
                    Text("Backups are stored in your iCloud account.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Backup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Placeholder for Sync Settings
struct SyncSettingsView: View {
    @State private var syncEnabled = true
    @State private var syncFrequency = "Daily"
    let frequencies = ["Hourly", "Daily", "Weekly"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Enable Sync", isOn: $syncEnabled)
                    
                    if syncEnabled {
                        Picker("Sync Frequency", selection: $syncFrequency) {
                            ForEach(frequencies, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }
                
                Section {
                    Text("Syncing keeps your data updated across all your devices.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Sync Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Placeholder for Help View
struct HelpView: View {
    let faqs = [
        ("How do I add a task?", "Tap the + button and select 'Add Task'."),
        ("Where are my backups stored?", "Backups are stored in iCloud if enabled."),
        ("How do I change the theme?", "Go to Settings > Appearance > Theme.")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Frequently Asked Questions")) {
                    ForEach(faqs, id: \.0) { question, answer in
                        NavigationLink {
                            Text(answer)
                                .padding()
                                .navigationTitle(question)
                        } label: {
                            Text(question)
                        }
                    }
                }
                
                Section {
                    Button("Contact Support") {
                        // Support functionality will go here
                    }
                }
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Placeholder for Version View
struct VersionView: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1234")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Check for Updates") {
                        // Update check functionality will go here
                    }
                }
            }
            .navigationTitle("Version Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Placeholder for Privacy Policy View
struct PrivacyPolicyView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .padding(.bottom)
                    
                    Text("""
                    Your privacy is important to us. This app collects minimal data required for functionality.
                    
                    Data Collection:
                    - Tasks and goals you create
                    - App preferences and settings
                    
                    Data Usage:
                    - To provide app functionality
                    - For personalization
                    
                    We do not sell your data to third parties.
                    """)
                    .font(.body)
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct ThemeSelectionView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    
    // Group themes by their base name
    private var groupedThemes: [String: [AppTheme]] {
        Dictionary(grouping: AppTheme.allCases.filter { $0 != .system }, by: { $0.baseTheme })
    }
    
    var body: some View {
        List {
            Section {
                Button {
                    themeSettings.selectedTheme = .system
                } label: {
                    HStack {
                        Text("System Default")
                        Spacer()
                        if themeSettings.selectedTheme == .system {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            ForEach(groupedThemes.keys.sorted(), id: \.self) { key in
                Section(header: Text(key.capitalized)) {
                    ForEach(groupedThemes[key]!, id: \.self) { theme in
                        Button {
                            themeSettings.selectedTheme = theme
                        } label: {
                            HStack {
                                Circle()
                                    .fill(theme.primaryColor)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: theme == themeSettings.selectedTheme ? 2 : 0)
                                    )
                                
                                Text(theme.displayName)
                                
                                Spacer()
                                
                                if theme == themeSettings.selectedTheme {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("App Theme")
    }
}
