import Foundation
import SwiftUI

/// This struct encapsulates the context data required for habit analysis.
/// It includes the habit's streak data, whether it was completed today, and the date of analysis.
/// - SeeAlso: `HabitStreakData`
struct HabitAnalysisContext {
    let habitData: HabitStreakData
    let isCompletedToday: Bool
    let analysisDate: Date
    let habitCreatedAt: Date
}

/// This struct represents the streak data of a habit.
/// It includes the habit's name, current streak count, category, frequency, and completion rate.
struct HabitStreakData {
    let name: String
    let currentStreak: Int
    let category: String
    let frequency: String
    let completionRate: Double
}

/// This struct represents an insight generated from habit analysis.
/// It includes the type of insight, title, description, priority, along with a unique identifier.
struct HabitInsight: Identifiable {
    let id = UUID()
    let type: HabitInsightType
    let title: String
    let description: String
    let priority: InsightPriority
}

/// This enum defines the types of insights that can be generated from habit analysis.
/// Each type has associated properties for color and icon representation in the UI.
/// 
/// # Types
///  - `critical`: Indicates a critical issue with the habit that needs immediate attention.
///  - `improvement`: Suggests areas where the habit can be improved.
///  - `success`: Highlights successful aspects of the habit to celebrate achievements.
///  - `trend`: Identifies interesting patterns or trends in habit performance.
/// 
/// # Properties
///  - `color`: A SwiftUI `Color` associated with the insight type for visual representation.
///  - `icon`: A string representing the system icon name associated with the insight type.
/// 
/// - SeeAlso: `HabitInsight`
enum HabitInsightType: String, CaseIterable {
    case critical
    case improvement
    case success
    case trend
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .improvement: return .orange
        case .success: return .green
        case .trend: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .critical: return "exclamationmark.triangle.fill"
        case .improvement: return "arrow.up.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .trend: return "chart.line.uptrend.xyaxis"
        }
    }
}

/// This enum defines the priority levels for insights generated from habit analysis.
/// 
/// # Levels
///  - high: Indicates high priority insights that require immediate attention.
///  - medium: Indicates medium priority insights that are important but not urgent.
///  - low: Indicates low priority insights that are less critical.
/// 
/// - SeeAlso: `HabitInsight`
enum InsightPriority {
    case high, medium, low
}


