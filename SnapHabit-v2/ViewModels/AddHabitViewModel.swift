import Foundation
import SwiftUI

/// ViewModel for adding a new habit.
/// 
/// This class manages the state and logic for adding a new habit, including input validation and interaction with the HomeViewModel to store the new habit.
/// It uses the `@MainActor` attribute to ensure that all UI updates are performed on the main thread.
/// 
/// # Properties:
///  - `name`: The name of the habit.
///  - `habitDescription`: A description of the habit.
///  - `time`: The time of day for the habit.
///  - `frequency`: The frequency of the habit (daily, weekly, etc.).
///  - `color`: The color associated with the habit.
///  - `category`: The category of the habit (general, health, etc.).
///  - `errorMessage`: An optional error message to display if validation fails.
///  - `successMessage`: An optional success message to display when a habit is added successfully.
/// 
/// # Methods:
/// - `addHabit(to:)`: Validates the input and adds the new habit to the provided HomeViewModel instance.
/// 
/// - SeeAlso: `HomeViewModel`, `Habit`
///
@MainActor
class AddHabitViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var habitDescription: String = ""
    @Published var time: Date = Date()
    @Published var frequency: Habit.HabitFrequency = .daily
    @Published var color: Habit.HabitColor = .blue
    @Published var category: Habit.HabitCategory = .general

    @Published var errorMessage: String?
    @Published var successMessage: String?


    /// Function to add a new habit.
    /// 
    /// This function validates the input fields and, if valid, creates a new `Habit` instance and adds it to the provided `HomeViewModel`.
    /// It also handles setting success and error messages based on the operation's outcome.
    /// 
    /// - Parameter homeViewModel: The `HomeViewModel` instance to which the new habit will be added.
    /// 
    /// - Returns: This function does not return a value but updates the state of the ViewModel.
    /// 
    /// - Throws: This function does not throw errors but sets error messages in the `errorMessage` property if validation fails.
    ///
    func addHabit(to homeViewModel: HomeViewModel) {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Habit name cannot be empty."
            successMessage = nil
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: time)

        let newHabit = Habit(
            name: name,
            habitDescription: habitDescription,  
            time: timeString,
            frequency: frequency,
            streakCounter: 0,
            longestStreak: 0,
            daysActive: 0,
            color: color,
            isCompletedToday: false,
            category: category,
            lastCompletedDate: nil
        )
        
        homeViewModel.addHabit(newHabit)
        successMessage = "Habit added successfully!"
        errorMessage = nil

        name = ""
        habitDescription = ""
        time = Date()
        frequency = .daily
        color = .blue
        category = .general
    }
}