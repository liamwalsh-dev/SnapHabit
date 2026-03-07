//
//  ThemeManager.swift
//  SnapHabit
//
//  Created by Agam Singh on 18/8/2025.
//

import SwiftUI

/// ThemeManager class to handle light and dark mode preferences.
///
/// This class manages the user's theme preference, allowing toggling between light and dark modes.
/// The selected theme is persisted using UserDefaults to maintain the preference across app launches.
///
final class ThemeManager: ObservableObject {
    static let sharedTheme = ThemeManager()
    @Published var colorScheme: ColorScheme? {
        didSet {
                UserDefaults.standard.set(colorScheme?.rawValue, forKey: "selectedColorScheme")
            }
    }

    private init() {
        if let savedScheme = UserDefaults.standard.string(forKey: "selectedColorScheme") {
            self.colorScheme = ColorScheme(rawValue: savedScheme)
        } else {
            self.colorScheme = nil // System default
        }
    }
    /// Toggles the current theme between light and dark modes and saves the preference.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    /// - SeeAlso: saveTheme()
    ///
    func toggleTheme() {
        switch colorScheme {
        case .light:
            colorScheme = .dark
        case .dark:
            colorScheme = nil // System default
        case .none:
            colorScheme = .light
        }
    }
}

/// Extension to convert ColorScheme to and from a raw string value for persistence.
/// 
/// This extension provides a way to serialize and deserialize the ColorScheme enum,
/// allowing it to be stored in UserDefaults.
///
extension ColorScheme {
    var rawValue: String {
        switch self {
        case .light: return "light"
        case .dark: return "dark"
        @unknown default: return "light"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "light": self = .light
        case "dark": self = .dark
        default: return nil
        }
    }
}