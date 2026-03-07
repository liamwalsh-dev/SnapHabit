//
//  database.swift
//  SnapHabit
//
//  Created by Agam Singh on 15/8/2025.
//

import Foundation
import SwiftUI
import Observation
import SwiftData
import WidgetKit

/// Database Class that manages CRUD operations for Habit entities using SwiftData.
/// 
/// This class provides an interface for interacting with the habit data model,
/// allowing for the creation, retrieval, updating, and deletion of habit records.
/// 
/// When instantiated, it requires a ModelContext to perform data operations.
/// 
/// - Parameters:
///  - modelContext: The SwiftData ModelContext used for data operations.
///  - items: An array of Habit objects representing the current habits in the database.
/// 
/// - SeeAlso: Habit
/// 
/// # Methods:
///  - loadHabits(): Fetches all Habit records from the database and updates the `
///  - addHabit(_ habit: Habit): Inserts a new Habit record into the database.
///  - updateHabit(_ habit: Habit): Saves changes made to an existing Habit record.
///  - deleteHabit(_ habit: Habit): Removes a Habit record from the database.
///  - saveHabit(): Commits changes to the database.
/// 
/// - Returns: None
/// 
/// - Throws: Errors related to data fetching and saving are caught and logged.
///
@MainActor
final class database: ObservableObject {
    @Published var items: [Habit] = []
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadHabits()
    }

    /// Sets the ModelContext for the database operations.
    /// - Parameter context: The ModelContext to be used for data operations.
    /// - Returns: None
    /// 
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadHabits()
    }
    /// Retrieves the current ModelContext.
    /// - Returns: The current ModelContext.
    /// 
    func getModelContext() -> ModelContext? {
        return modelContext
    }
    
    /// Loads all Habit records from the database and updates the `items` array.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: Error if fetching fails.
    ///
    func loadHabits() {
        guard let context = modelContext else {
            #if DEBUG
            print("❌ Model context not available")
            #endif
            return
        }
        
        do {
            let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.name)])
            items = try context.fetch(descriptor)
        } catch {
            #if DEBUG
            print("❌ Failed to fetch habits:", error)
            #endif
            items = []
        }
    }

    /// Adds a new Habit record to the database.
    /// Loads the updated list of habits after insertion.
    /// 
    /// - Parameter habit: The Habit object to be added.
    /// - Returns: None
    /// 
    func addHabit(_ habit: Habit) {
        guard let context = modelContext else {
            #if DEBUG
            print("❌ Model context not available for adding habit")
            #endif
            return
        }
        
        context.insert(habit)
        saveHabit()
        loadHabits()
        
        // Refresh WidgetKit timelines
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Updates an existing Habit record in the database.
    /// Saves changes and reloads the list of habits.
    /// 
    /// - Parameter habit: The Habit object with updated information.
    /// - Returns: None
    ///
    func updateHabit(_ habit: Habit) {
        saveHabit()
        loadHabits()
        
        // Refresh WidgetKit timelines
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Deletes a Habit record from the database.
    /// Saves changes and reloads the list of habits.
    /// 
    /// - Parameter habit: The Habit object to be deleted.
    /// - Returns: None
    ///
    func deleteHabit(_ habit: Habit) {
        guard let context = modelContext else {
            #if DEBUG
            print("❌ Model context not available")
            #endif
            return
        }
        
        context.delete(habit)
        saveHabit()
        loadHabits()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Saves the habit to the database.
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: Error if saving fails.
    ///
    private func saveHabit() {
        guard let context = modelContext else {
            #if DEBUG
            print("❌ Model context not available")
            #endif
            return
        }
        
        do {
            try context.save()
        } catch {
            #if DEBUG
            print("❌ Failed to save habits:", error)
            #endif
        }
    }
}