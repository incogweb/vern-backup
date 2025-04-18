//
//  Theme.swift
//  Axer
//
//  Created by Oscar on 18/04/2025.
//

// Add this to a new file: Theme.swift
import SwiftUI

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark
    case blue
    case blueDark
    case green
    case greenDark
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light, .blue, .green: return .light
        case .dark, .blueDark, .greenDark: return .dark
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .blue, .blueDark:
            return Color(red: 0.1, green: 0.3, blue: 0.7)
        case .green, .greenDark:
            return Color(red: 0.2, green: 0.6, blue: 0.3)
        default:
            return .blue // Default accent color
        }
    }
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        case .blue: return "Blue"
        case .blueDark: return "Blue Dark"
        case .green: return "Green"
        case .greenDark: return "Green Dark"
        }
    }
    
    // Helper to get the base theme name without dark/light suffix
    var baseTheme: String {
        let str = self.rawValue
        if str.hasSuffix("Dark") {
            return String(str.dropLast(4))
        }
        return str
    }
}

class ThemeSettings: ObservableObject {
    @Published var selectedTheme: AppTheme = .system
    
    // Dynamic colors that adapt to dark/light mode
    func adaptiveColor(dark: Color, light: Color) -> Color {
        switch selectedTheme {
        case .system:
            return Color(UIColor { trait in
                trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
            })
        case .light, .blue, .green:
            return light
        case .dark, .blueDark, .greenDark:
            return dark
        }
    }
    
    // Background color based on theme
    var backgroundColor: Color {
        adaptiveColor(dark: Color(.systemBackground), light: Color(.systemBackground))
    }
    
    // Text color based on theme
    var textColor: Color {
        adaptiveColor(dark: Color(.label), light: Color(.label))
    }
}
