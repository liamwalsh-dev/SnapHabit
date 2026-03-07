import SwiftUI
import Foundation

/// ViewModel for editing an existing habit.
/// 
/// This class manages the state and logic for editing a habit, including input validation and interaction with the HomeViewModel to update the habit.
/// It uses the `@MainActor` attribute to ensure that all UI updates are performed on the main thread.
/// 
/// # Properties:
///  - `name`: The name of the habit.
///  - `habitDescription`: A description of the habit.
///  - `time`: The time of day for the habit.
///  - `frequency`: The frequency of the habit (daily, weekly, or monthly).
///  - `color`: The color associated with the habit.
///  - `category`: The category of the habit (general, health, etc.).
///  - `errorMessage`: An optional error message to display if validation fails.
///  - `successMessage`: An optional success message to display when a habit is updated successfully.
/// 
/// # Methods:
///  - `loadHabit(_:)`: Loads the details of the given habit into the ViewModel's properties.
///  - `saveChanges(to:habit:)`: Validates the input and updates the given habit in the provided HomeViewModel instance.
/// 
/// - SeeAlso: `HomeViewModel`, `Habit`
///
@MainActor
class EditHabitViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var habitDescription: String = ""
    @Published var time: Date = Date()
    @Published var frequency: Habit.HabitFrequency = .daily
    @Published var color: Habit.HabitColor = .blue
    @Published var category: Habit.HabitCategory = .general

    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    let formatter = DateFormatter()
    
    init() {
        formatter.dateFormat = "HH:mm"
    }
    
    /// Function to load an existing habit's details into the ViewModel.
    /// 
    /// This function populates the ViewModel's properties with the details of the provided `Habit` instance.
    /// 
    /// - Parameter habit: The `Habit` instance whose details are to be loaded.
    /// 
    /// - Returns: This function does not return a value but updates the state of the ViewModel.
    /// 
    /// - Throws: This function does not throw errors.
    ///
    func loadHabit(_ habit: Habit) {
        name = habit.name
        habitDescription = habit.habitDescription
        frequency = habit.frequency
        color = habit.color
        category = habit.category
        time = formatter.date(from: habit.time) ?? Date()
    }

    /// Function to save changes made to an existing habit.
    /// 
    /// This function validates the input fields and, if valid, updates the provided `Habit` instance in the given `HomeViewModel`.
    /// It also handles setting success and error messages based on the operation's outcome.
    /// 
    /// - Parameters:
    ///   - homeViewModel: The `HomeViewModel` instance where the habit will be updated.
    ///   - habit: The `Habit` instance to be updated.
    /// 
    /// - Returns: This function does not return a value but updates the state of the ViewModel.
    /// 
    /// - Throws: This function does not throw errors but sets error messages in the `errorMessage` property if validation fails.
    ///
    func saveChanges(to homeViewModel: HomeViewModel, habit: Habit) {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Habit name cannot be empty."
            successMessage = nil
            return
        }
    
        let timeString = formatter.string(from: time)

        var habitToUpdate = habit
        habitToUpdate.name = name
        habitToUpdate.habitDescription = habitDescription
        habitToUpdate.time = timeString
        habitToUpdate.frequency = frequency
        habitToUpdate.color = color
        habitToUpdate.category = category

        homeViewModel.updateHabit(habitToUpdate)
        successMessage = "Habit updated successfully!"
        errorMessage = nil
    }
}