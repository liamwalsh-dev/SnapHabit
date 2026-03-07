//
//  HomeViewModel.swift
//  SnapHabit
//
//  Created by Agam Singh on 28/8/2025.
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel for managing habits and their state.
///
/// This ViewModel handles loading, adding, updating, and deleting habits, as well as managing their order and resetting their state for a new day.
/// It also provides filtering capabilities based on search text and manages the reordering of pending habits.
/// 
/// # Properties:
///  - `habits`: An array of `Habit` objects representing the user's habits.
///  - `isReorderingEnabled`: A boolean indicating if reordering of habits is enabled.
///  - `searchText`: A string for filtering habits based on their names.
///  - `filteredHabits`: A computed property that returns habits filtered by the search text.
///  - `modelContext`: The SwiftData model context for database operations.
///  - `db`: An instance of the `database` class for interacting with the database.
/// # Methods:
///  - `loadHabits()`: Loads habits from the database and checks for daily resets.
///  - `refreshHabits()`: Refreshes the list of habits from the database.
///  - `checkAndResetForNewDay()`: Checks if a new day has started and resets habits accordingly.
///  - `movePendingHabit(from:to:)`: Moves a pending habit from one position to another.
///  - `enableReordering()`: Enables reordering of pending habits for the gesture.
///  - `disableReordering()`: Disables reordering of pending habits for the gesture.
///  - `setModelContext(_:)`: Sets the model context for database operations.
///  - `getHabits()`: Returns the list of all habits.
///  - `addHabit(_:)`: Adds a new habit to the database.
///  - `updateHabit(_:)`: Updates an existing habit in the database.
///  - `deleteHabit(_:)`: Deletes a habit from the database.
///  - `pendingHabits()`: Returns a list of pending (not completed today) habits.
///  - `completedHabits()`: Returns a list of completed (completed today) habits.
///
@MainActor
class HomeViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    private let db: database

    @Published var searchText: String = ""
    @Published var isReorderingEnabled = false
    
    var filteredHabits: [Habit] {
        if searchText.isEmpty {
            return habits
        } else {
            return habits.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var modelContext: ModelContext? {
        return db.getModelContext()
    }

    init(modelContext: ModelContext? = nil) {
        self.db = database(modelContext: modelContext)
        loadHabits()
    }
    
    /// Function to set the model context for database operations.
    /// 
    /// This function sets the model context for the database instance and reloads the habits.
    /// 
    /// - Parameters:
    ///   - context: The `ModelContext` to be set for database operations.
    /// - Returns: None
    /// - Throws: None
    func setModelContext(_ context: ModelContext) {
        db.setModelContext(context)
        loadHabits()
    }
    // MARK: - Daily Reset Tracking

    /// This property uses `UserDefaults` to persist the last reset date across app launches.
    ///
    /// This property tracks the last date when habits were reset to ensure daily resets occur only once per day.
    /// It is stored as a string in the format "yyyy-MM-dd".
    /// 
    /// - Returns: The last reset date as a string, or `nil` if not set.
    /// - Parameters: None
    /// - Throws: None
    /// 
    private var lastResetDate: String? {
        get {
            UserDefaults.standard.string(forKey: "lastResetDate")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastResetDate")
        }
    }

    // MARK: - Reordering Habits

    /// Function to move a pending habit from one position to another.
    ///
    /// This function updates the order of pending habits when they are moved in the UI by drag-and-drop.
    /// It ensures that only pending habits (not completed today) are reordered and updates their order accordingly. The new order is then saved to `UserDefaults`.
    ///
    ///  - Parameters:
    ///   - source: The source index set of the habit being moved.
    ///   - destination: The destination index where the habit is moved to.
    /// - Returns: None
    /// - Throws: None
    ///
    func movePendingHabit(from source: IndexSet, to destination: Int) {
        var pendingHabits = habits.filter { !$0.isCompletedToday }
        
        pendingHabits.move(fromOffsets: source, toOffset: destination)
        
        for (index, habit) in pendingHabits.enumerated() {
            if let habitIndex = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[habitIndex].order = index
            }
        }
        
        savePendingHabitsOrder()
        saveHabits()
    }
    
    /// Function to enable reordering of pending habits.
    ///
    /// This function toggles the `isReorderingEnabled` property to allow reordering of pending habits in the UI.
    /// 
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    /// 
    func enableReordering() {
        isReorderingEnabled = true
    }
    
    /// Function to disable reordering of pending habits.
    /// 
    /// This function toggles the `isReorderingEnabled` property to prevent reordering
    /// of pending habits in the UI.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    /// 
    func disableReordering() {
        isReorderingEnabled = false
    }
    
    // MARK: - Persistence for Pending Habits Order

    /// Function to save the order of pending habits to UserDefaults.
    /// 
    /// This function saves the current order of pending habits (not completed today) to UserDefaults.
    /// It stores the habit IDs along with their order to maintain the order across app launches.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    ///
    private func savePendingHabitsOrder() {
        let pendingHabits = habits.filter { !$0.isCompletedToday }
        let orderData = pendingHabits.compactMap { habit -> [String: Any]? in
            guard let order = habit.order else { return nil }
            return ["id": habit.id.uuidString, "order": order]
        }
        UserDefaults.standard.set(orderData, forKey: "pendingHabitsOrder")
    }
    
    /// Function to load the order of pending habits from UserDefaults.
    /// 
    /// This function retrieves the saved order of pending habits from UserDefaults and updates the habits array accordingly.
    /// It ensures that the order is applied only to pending habits and maintains the correct order.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    /// 
    private func loadPendingHabitsOrder() {
        guard let orderData = UserDefaults.standard.array(forKey: "pendingHabitsOrder") as? [[String: Any]] else { return }
        
        for orderItem in orderData {
            guard let idString = orderItem["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let order = orderItem["order"] as? Int,
                  let habitIndex = habits.firstIndex(where: { $0.id == id }) else { continue }
            
            habits[habitIndex].order = order
        }
        
        sortPendingHabitsByOrder()
    }
    
    /// Function to sort pending habits by their assigned order.
    /// 
    /// This function sorts the pending habits based on their assigned order.
    /// It ensures that pending habits are displayed in the correct order, followed by completed habits.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    ///
    private func sortPendingHabitsByOrder() {
        let pendingHabits = habits.filter { !$0.isCompletedToday }
        let completedHabits = habits.filter { $0.isCompletedToday }
        
        let sortedPending = pendingHabits.sorted { habit1, habit2 in
            let order1 = habit1.order ?? Int.max
            let order2 = habit2.order ?? Int.max
            return order1 < order2
        }
        
        habits = sortedPending + completedHabits
    }
    
    /// Function to assign initial order to pending habits that do not have an order assigned.
    /// 
    /// This function assigns an initial order to pending habits that do not have an order assigned.
    /// It ensures that all pending habits have a defined order, which is then saved to UserDefaults.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    ///
    private func assignInitialOrderToPendingHabits() {
        let pendingHabits = habits.filter { !$0.isCompletedToday && $0.order == nil }
        var currentOrder = habits.filter { !$0.isCompletedToday && $0.order != nil }.count
        
        for habit in pendingHabits {
            if let habitIndex = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[habitIndex].order = currentOrder
                currentOrder += 1
            }
        }
        
        if !pendingHabits.isEmpty {
            savePendingHabitsOrder()
        }
    }
    
    /// Function to save the current state of habits to the database.
    /// 
    /// This function attempts to save the current state of habits to the database using the model context.
    /// It handles any errors that may occur during the save operation and logs them.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    ///
    private func saveHabits() {
        if let context = modelContext {
            do {
                try context.save()
            } catch {
                print("Error saving habits: \(error)")
            }
        }
    }

    /// Function to load habits from the database.
    ///
    /// This function loads habits from the database and updates the local habits array.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    ///
    func loadHabits() {
        db.loadHabits()
        habits = db.items
        loadPendingHabitsOrder()
        assignInitialOrderToPendingHabits()
        sortPendingHabitsByOrder()
        checkAndResetForNewDay()
    }
    
    /// Function to refresh the list of habits from the database.
    /// 
    /// This function reloads the habits from the database and updates the local habits array.
    /// It ensures that the latest data is reflected in the ViewModel.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    ///
    func refreshHabits() {
        db.loadHabits()
        habits = db.items
        sortPendingHabitsByOrder()
    }

    /// Function to check if a new day has started and reset habits accordingly.
    /// 
    /// This function checks the last reset date against the current date.
    /// If a new day has started, it resets the `isCompletedToday` status of habits
    /// and updates their streak counters based on their completion status and frequency.
    /// It also saves any changes to the database and updates the last reset date.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    ///
    func checkAndResetForNewDay() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        var needsUpdate = false
        
        for habit in habits {
            // If habit is marked as completed but lastCompletedDate is not today, reset it
            if habit.isCompletedToday && habit.lastCompletedDate != today {
                habit.isCompletedToday = false
                needsUpdate = true
            }
            
            // Check streak reset for daily habits regardless of completion status
            if habit.frequency == .daily {
                if let lastCompleted = habit.lastCompletedDate {
                    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                    let yesterdayString = dateFormatter.string(from: yesterday)
                    
                    // Reset streak if the habit wasn't completed yesterday
                    if lastCompleted != yesterdayString && lastCompleted != today {
                        if habit.streakCounter > 0 {
                            habit.streakCounter = 0
                            needsUpdate = true
                        }
                    }
                } else {
                    // If there's no lastCompletedDate and it's not completed today, reset streak
                    if !habit.isCompletedToday && habit.streakCounter > 0 {
                        habit.streakCounter = 0
                        needsUpdate = true
                    }
                }
            }
        }
        
        if needsUpdate {
            if let context = modelContext {
                do {
                    try context.save()
                    refreshHabits()
                } catch {
                    print("Error saving context: \(error)")
                }
            }
        }
        
        lastResetDate = today
    }

    /// Function to retrieve all habits.
    /// - Parameters: None
    /// - Returns: An array of all habits.
    /// - Throws: None
    ///
    func getHabits() -> [Habit] {
        return habits
    }
    
    /// Function to retrieve a habit by its ID.
    /// 
    /// - Parameters:
    ///   - id: The UUID of the habit to retrieve.
    /// - Returns: The habit with the specified ID, or `nil` if not found.
    /// - Throws: None
    ///
    func getHabit(by id: UUID) -> Habit? {
        return habits.first(where: { $0.id == id })
    }

    /// Function to add a new habit.
    /// 
    /// - Parameters:
    ///   - habit: The habit to add.
    /// - Returns: None
    /// - Throws: None
    ///
    func addHabit(_ habit: Habit) {
        db.addHabit(habit)
        habits = db.items
        assignInitialOrderToPendingHabits()
        sortPendingHabitsByOrder()
    }
    
    /// Function to update an existing habit.
    /// 
    /// - Parameters:
    ///   - habit: The habit to update.
    /// - Returns: None
    /// - Throws: None
    ///
    func updateHabit(_ habit: Habit) {
        db.updateHabit(habit)
        habits = db.items
        sortPendingHabitsByOrder()
    }
    
    /// Function to delete a habit.
    /// 
    /// - Parameters:
    ///   - habit: The habit to delete.
    /// - Returns: None
    /// - Throws: None
    ///
    func deleteHabit(_ habit: Habit) {
        db.deleteHabit(habit)
        habits = db.items
    }
    
    /// Function to get a list of pending habits (not completed today).
    /// 
    /// - Parameters: None
    /// - Returns: An array of pending habits.
    /// - Throws: None
    ///
    func pendingHabits() -> [Habit] {
        return habits.filter { !$0.isCompletedToday }
    }
    
    /// Function to get a list of completed habits (completed today).
    /// 
    /// - Parameters: None
    /// - Returns: An array of completed habits.
    /// - Throws: None
    ///
    func completedHabits() -> [Habit] {
        return habits.filter { $0.isCompletedToday }
    }
}