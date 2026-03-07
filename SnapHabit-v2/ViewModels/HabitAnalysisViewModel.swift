import Foundation
import SwiftUI
import Observation

/// ViewModel for analyzing habits and generating insights using Google Gemini AI.
/// 
/// This ViewModel interacts with the `GoogleAIService` to send habit data and receives analysis.
/// It processes the AI response to create user-friendly insights. The insights are categorized by type and prioritized for display in the UI.
/// 
/// # Properties
///  - `insights`: An array of `HabitInsight` objects representing the generated insights.
///  - `isLoading`: A boolean indicating if the analysis is currently in progress.
///  - `errorMessage`: A string to hold any error messages encountered during analysis.
///  - `selectedHabit`: The habit currently being analyzed.
///  - `availableHabits`: A list of habits available for analysis.
/// # Methods
///  - `generateInsights()`: Initiates the analysis for a selected habit.
///  - `analyzeHabit()`: Sends habit data to the AI service and retrieves insights.
///  - `buildHabitContext()`: Constructs the context data required for analysis.
///  - `calculateCompletionRate()`: Calculates the completion rate of a habit.
///  - `parseInsights()`: Parses the AI response into structured insights.
///  - `determinePriority()`: Determines the priority of an insight based on its type.
/// 
/// - SeeAlso: `GoogleAIService`
/// 
@MainActor
@Observable
final class HabitAnalysisViewModel {
    private let database: database
    private let googleAIService: GoogleAIService
    
    var insights: [HabitInsight] = []
    var isLoading = false
    var errorMessage: String?
    var selectedHabit: Habit?
    var availableHabits: [Habit] = []
    
    init(database: database) {
        self.database = database
        self.googleAIService = GoogleAIService()
        self.availableHabits = database.items
    }
    
    /// This function generates insights for a given habit by analyzing its data using Google Gemini AI.
    /// - Parameter habit: The `Habit` object to be analyzed.
    /// 
    /// - SeeAlso: `analyzeHabit(habit:)`
    func generateInsights(for habit: Habit) async {
        isLoading = true
        errorMessage = nil
        insights.removeAll()
        selectedHabit = habit
        
        do {
            let habitInsights = try await analyzeHabit(habit)
            insights = habitInsights
        } catch {
            errorMessage = "Failed to analyze '\(habit.name)': \(error.localizedDescription)"
            print("Analysis error: \(error)")
        }
        
        isLoading = false
    }

    /// This function uses buildHabitContext to create the context for the habit analysis, sends it to the GoogleAIService, and parses the response into HabitInsight objects.
    ///
    /// - Parameter habit: The `Habit` object to be analyzed.
    /// - Returns: An array of `HabitInsight` objects generated from the analysis.
    /// - Throws: An error if the analysis fails.
    /// - SeeAlso: `buildHabitContext(habit:)`, `GoogleAIService.analyzeHabits(context:)`, `parseInsights(from:)`
    private func analyzeHabit(_ habit: Habit) async throws -> [HabitInsight] {
        let analysisContext = buildHabitContext(habit: habit)
        let response = try await googleAIService.analyzeHabits(context: analysisContext)
        
        return parseInsights(from: response)
    }

    /// This function builds the context for habit analysis by extracting relevant data from the habit object.
    /// - Parameter habit: The `Habit` object to be analyzed.
    /// - Returns: A `HabitAnalysisContext` object containing the context data.
    /// - SeeAlso: `HabitAnalysisContext`
    private func buildHabitContext(habit: Habit) -> HabitAnalysisContext {
        let habitData = HabitStreakData(
            name: habit.name,
            currentStreak: habit.streakCounter,
            category: habit.category.rawValue,
            frequency: habit.frequency.rawValue,
            completionRate: calculateCompletionRate(for: habit)
        )
        
        return HabitAnalysisContext(
            habitData: habitData,
            isCompletedToday: habit.isCompletedToday,
            analysisDate: Date(),
            habitCreatedAt: habit.createdAt
        )
    }
    
    /// This function calculates the completion rate of a habit based on its streak and creation date.
    /// - Parameter habit: The `Habit` object for which to calculate the completion rate.
    /// - Returns: A `Double` representing the completion rate (0.0 to 1.0).
    /// - SeeAlso: `Habit`
    private func calculateCompletionRate(for habit: Habit) -> Double {
        let daysSinceCreated = Calendar.current.dateComponents([.day], 
            from: habit.createdAt, to: Date()).day ?? 1
        return Double(habit.streakCounter) / Double(max(daysSinceCreated, 1))
    }
    
    /// This function parses the AI response string into an array of HabitInsight objects.
    ///
    /// The parsing logic looks for specific keywords (---) to determine the type of insight and extracts the title and description accordingly. 
    ///
    /// - Parameter response: The raw response string from the AI service.
    /// - Returns: An array of `HabitInsight` objects.
    /// - SeeAlso: `HabitInsight`, `HabitInsightType`, `InsightPriority`
    private func parseInsights(from response: String) -> [HabitInsight] {
        
        let separator = "---"
        var components: [String] = response.components(separatedBy: separator)

        // If no separators found, treat the entire response as one insight
        if components.count <= 1 {
            components = [response]
        }
        
        return components.compactMap { component in
            let trimmedComponent = component.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty components
            guard !trimmedComponent.isEmpty else { return nil }
            
            let lines = trimmedComponent.components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            var type: HabitInsightType = .improvement 
            var title = "Habit Analysis"
            var description = trimmedComponent
            
            if let firstLine = lines.first {
                let lowercaseFirst = firstLine.lowercased()
                
                if let detectedType = HabitInsightType.allCases.first(where: { 
                    lowercaseFirst.contains($0.rawValue) || 
                    lowercaseFirst.contains($0.displayName.lowercased()) 
                }) {
                    type = detectedType
                    
                    // If we detected a type, use remaining lines
                    if lines.count >= 2 {
                        title = lines[1]
                        if lines.count >= 3 {
                            description = lines[2...].joined(separator: "\n")
                        }
                    } else if lines.count == 1 {
                        // Only one line, use it as both title and description
                        title = "Analysis Result"
                        description = firstLine
                    }
                } else {
                    // No type detected, use first line as title
                    title = firstLine
                    if lines.count >= 2 {
                        description = lines[1...].joined(separator: "\n")
                    }
                }
            }
            
            // Ensure we have meaningful content
            if description.isEmpty || description.count < 10 {
                description = "Analysis completed for your habit. Continue tracking for more detailed insights."
            }
            
            return HabitInsight(
                type: type,
                title: title,
                description: description,
                priority: determinePriority(for: type)
            )
        }
    }
    
    /// This function determines the priority of an insight based on its type.
    /// 
    /// The priority levels are defined as follows:
    /// - `high` for `critical` insights
    /// - `medium` for `improvement` and `trend` insights
    /// - `low` for `success` insights
    /// 
    /// - Parameter type: The `HabitInsightType` of the insight.
    /// - Returns: An `InsightPriority` value representing the priority level.
    /// - SeeAlso: `HabitInsightType`, `InsightPriority`
    private func determinePriority(for type: HabitInsightType) -> InsightPriority {
        switch type {
            case .critical: return .high
            case .improvement: return .medium
            case .success: return .low
            case .trend: return .medium
        }
    }
    
    /// This function refreshes the list of available habits from the database.
    /// If the currently selected habit is no longer available, it clears the selection and insights.
    /// - SeeAlso: `database`
    func refreshAvailableHabits() {
        self.availableHabits = database.items
        if let selected = selectedHabit, !availableHabits.contains(where: { $0.id == selected.id }) {
            selectedHabit = nil
            insights = []
        }
    }
}
