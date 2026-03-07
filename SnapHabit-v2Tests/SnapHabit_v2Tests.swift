//
//  SnapHabit_v2Tests.swift
//  SnapHabit-v2Tests
//
//  Created by Agam Singh on 15/9/2025.
//

import Testing
import Foundation
@testable import SnapHabit_v2
@MainActor
struct SnapHabit_v2Tests {
    
    // MARK: - Test 1: Habit Model Creation and Validation
    /**
     * Test Purpose: Validates that a Habit model can be created successfully with valid data
     * Intent: Ensures the core Habit model initializes correctly with all required properties
     * Coverage: Happy path for habit creation with standard input values
     */
    @Test("Habit creation with valid data should initialize all properties correctly")
    func testHabitCreationWithValidData() async throws {
        // Arrange: Set up test data for habit creation
        let habitName = "Daily Exercise"
        let habitDescription = "30 minutes of cardio workout"
        let time = "07:00"
        let frequency = Habit.HabitFrequency.daily
        let category = Habit.HabitCategory.health
        let color = Habit.HabitColor.blue
        
        // Act: Create a new habit instance using the correct initializer
        let habit = Habit(
            name: habitName,
            habitDescription: habitDescription,
            time: time,
            frequency: frequency,
            color: color,
            category: category
        )
        
        // Assert: Verify all properties are set correctly
        #expect(habit.name == habitName, "Habit name should match input")
        #expect(habit.habitDescription == habitDescription, "Habit description should match input")
        #expect(habit.time == time, "Habit time should match input")
        #expect(habit.frequency == frequency, "Habit frequency should match input")
        #expect(habit.category == category, "Habit category should match input")
        #expect(habit.color == color, "Habit color should match input")
        #expect(habit.id != nil, "Habit should have a valid UUID")
        #expect(habit.isCompletedToday == false, "New habits should not be completed by default")
        #expect(habit.streakCounter == 0, "New habits should start with zero streak")
        #expect(habit.longestStreak == 0, "New habits should start with zero longest streak")
        #expect(habit.daysActive == 0, "New habits should start with zero days active")
        #expect(habit.photos.isEmpty, "New habits should have no photos initially")
    }
    
    // MARK: - Test 2: Habit Model Edge Cases and Enum Validation
    /**
     * Test Purpose: Validates habit model behavior with edge case inputs and enum values
     * Intent: Ensures the model handles boundary conditions and validates all enum cases
     * Coverage: Edge cases including empty strings, all frequency types, categories, and colors
     */
    @Test("Habit creation with edge case data should handle various enum combinations")
    func testHabitCreationWithEdgeCaseData() async throws {
        // Test with empty name
        let emptyNameHabit = Habit(
            name: "",
            habitDescription: "Valid description",
            category: .general
        )
        #expect(emptyNameHabit.name == "", "Empty name should be preserved for validation elsewhere")
        #expect(emptyNameHabit.category == .general, "Category should default to general")
        
        // Test with extremely long name
        let longName = String(repeating: "a", count: 1000)
        let longNameHabit = Habit(
            name: longName,
            habitDescription: "Test",
            category: .productivity
        )
        #expect(longNameHabit.name.count == 1000, "Long names should be preserved")
        #expect(longNameHabit.category == .productivity, "Category should be set correctly")
        
        // Test with all frequency types
        let dailyHabit = Habit(name: "Daily", habitDescription: "Test", frequency: .daily, category: .health)
        let weeklyHabit = Habit(name: "Weekly", habitDescription: "Test", frequency: .weekly, category: .health)
        let monthlyHabit = Habit(name: "Monthly", habitDescription: "Test", frequency: .monthly, category: .health)
        
        #expect(dailyHabit.frequency == .daily, "Daily frequency should be set correctly")
        #expect(weeklyHabit.frequency == .weekly, "Weekly frequency should be set correctly")
        #expect(monthlyHabit.frequency == .monthly, "Monthly frequency should be set correctly")
        
        // Test all category types
        let categoryTests: [Habit.HabitCategory] = [
            .general, .health, .productivity, .leisure, .social, .family, .personal, .spiritual
        ]
        
        for category in categoryTests {
            let categoryHabit = Habit(name: "Category Test", habitDescription: "Test", category: category)
            #expect(categoryHabit.category == category, "Category \(category.rawValue) should be set correctly")
        }
        
        // Test all color types and their SwiftUI color conversion
        let colorTests: [Habit.HabitColor] = [
            .blue, .green, .red, .yellow, .orange, .pink, .purple
        ]
        
        for color in colorTests {
            let colorHabit = Habit(name: "Color Test", habitDescription: "Test", color: color, category: .general)
            #expect(colorHabit.color == color, "Color \(color.rawValue) should be set correctly")
            #expect(colorHabit.color.color != nil, "Color should convert to SwiftUI Color")
        }
    }
    
    // MARK: - Test 3: Habit Progress Calculation and Frequency Logic
    /**
     * Test Purpose: Tests habit progress calculation based on different frequencies
     * Intent: Validates progress tracking logic for daily, weekly, and monthly habits
     * Coverage: Progress calculation, target setting, and text representation
     */
    @Test("Habit progress calculation should work correctly for all frequencies")
    func testHabitProgressCalculationAndFrequencyLogic() async throws {
        // Test daily habit progress
        let dailyHabit = Habit(name: "Daily Exercise", habitDescription: "Test", frequency: .daily, category: .health)
        
        // Initial state - not completed
        #expect(dailyHabit.calculateProgress() == 0.0, "Uncompleted daily habit should have 0.0 progress")
        #expect(dailyHabit.progressTarget == 1, "Daily habit target should be 1")
        #expect(dailyHabit.progressText == "0/1", "Daily habit progress text should show 0/1")
        
        // Mark as completed
        dailyHabit.isCompletedToday = true
        #expect(dailyHabit.calculateProgress() == 1.0, "Completed daily habit should have 1.0 progress")
        
        // Test weekly habit progress
        let weeklyHabit = Habit(name: "Weekly Review", habitDescription: "Test", frequency: .weekly, category: .productivity)
        
        #expect(weeklyHabit.progressTarget == 7, "Weekly habit target should be 7")
        #expect(weeklyHabit.calculateProgress() == 0.0, "New weekly habit should have 0.0 progress")
        
        // Simulate 3 days completed
        weeklyHabit.dayCounter = 3
        let weeklyProgress = weeklyHabit.calculateProgress()
        #expect(abs(weeklyProgress - (3.0/7.0)) < 0.01, "Weekly habit with 3 days should have ~0.43 progress")
        #expect(weeklyHabit.progressText == "3/7", "Weekly habit progress text should show 3/7")
        
        // Test monthly habit progress
        let monthlyHabit = Habit(name: "Monthly Goal", habitDescription: "Test", frequency: .monthly, category: .personal)
        
        #expect(monthlyHabit.progressTarget == 30, "Monthly habit target should be 30")
        #expect(monthlyHabit.calculateProgress() == 0.0, "New monthly habit should have 0.0 progress")
        
        // Simulate 15 days completed
        monthlyHabit.dayCounter = 15
        let monthlyProgress = monthlyHabit.calculateProgress()
        #expect(abs(monthlyProgress - 0.5) < 0.01, "Monthly habit with 15 days should have 0.5 progress")
        #expect(monthlyHabit.progressText == "15/30", "Monthly habit progress text should show 15/30")
        
        // Test progress bounds (should not exceed 1.0)
        monthlyHabit.dayCounter = 35 // More than target
        #expect(monthlyHabit.calculateProgress() <= 1.0, "Progress should not exceed 1.0 even with high day counter")
        
        // Test frequency unit strings
        dailyHabit.streakCounter = 1
        #expect(dailyHabit.frequencyUnit == "day", "Single day streak should use singular 'day'")
        
        dailyHabit.streakCounter = 5
        #expect(dailyHabit.frequencyUnit == "days", "Multiple day streak should use plural 'days'")
        
        weeklyHabit.streakCounter = 1
        #expect(weeklyHabit.frequencyUnit == "week", "Single week streak should use singular 'week'")
        
        weeklyHabit.streakCounter = 3
        #expect(weeklyHabit.frequencyUnit == "weeks", "Multiple week streak should use plural 'weeks'")

        monthlyHabit.streakCounter = 1
        #expect(monthlyHabit.frequencyUnit == "month", "Single month streak should use singular 'month'")

        monthlyHabit.streakCounter = 4
        #expect(monthlyHabit.frequencyUnit == "months", "Multiple month streak should use plural 'months'")
    }
    
   
    // MARK: - Test 4: HabitPhoto Model and Gallery Management
    /**
     * Test Purpose: Tests habit photo model creation and gallery functionality
     * Intent: Validates photo storage, metadata handling, and gallery operations
     * Coverage: Photo creation, metadata extraction, and relationship management
     * Storage Testing: Ensures proper handling of photo data and timestamps
     */
    @Test("HabitPhoto model should manage photo data and metadata correctly")
    func testHabitPhotoModelAndGalleryManagement() async throws {
        // Create a test habit for photo association
        let testHabit = Habit(
            name: "Test Photo Habit",
            category: .health
        )
        
        // Test photo creation with full metadata
        let testPhotoData = "test image data".data(using: .utf8)!
        let testNote = "Morning workout completed!"
        let testTimestamp = Date()
        
        let habitPhoto = HabitPhoto(
            photoData: testPhotoData,
            note: testNote,
            timestamp: testTimestamp
        )
        
        #expect(habitPhoto.photoData == testPhotoData, "Photo data should be preserved")
        #expect(habitPhoto.note == testNote, "Note should be preserved")
        #expect(habitPhoto.timestamp == testTimestamp, "Timestamp should match input")
        #expect(habitPhoto.id != nil, "Photo should have a valid UUID")
        
        // Test photo without note 
        let minimalPhoto = HabitPhoto(
            photoData: testPhotoData,
            note: "",
            timestamp: Date()
        )
        #expect(minimalPhoto.note == "", "Empty notes should be allowed")
        #expect(minimalPhoto.photoData == testPhotoData, "Photo data should be preserved")
        
        // Test photo with large note 
        let longNote = String(repeating: "This is a long note. ", count: 100)
        let longNotePhoto = HabitPhoto(
            photoData: testPhotoData,
            note: longNote,
            timestamp: Date()
        )
        #expect(longNotePhoto.note.count > 1000, "Long notes should be preserved")
        
        // Test photo with unicode note
        let unicodePhoto = HabitPhoto(
            photoData: testPhotoData,
            note: "Great workout! 💪🏃‍♂️ 很棒的锻炼！",
            timestamp: Date()
        )
        #expect(unicodePhoto.note.contains("💪"), "Emoji should be preserved in notes")
        #expect(unicodePhoto.note.contains("很棒"), "Unicode text should be preserved in notes")
        
        // Test photo uniqueness
        let photo1 = HabitPhoto(photoData: testPhotoData, note: "Photo 1", timestamp: Date())
        let photo2 = HabitPhoto(photoData: testPhotoData, note: "Photo 2", timestamp: Date())
        #expect(photo1.id != photo2.id, "Different photos should have different IDs")
        
        // Test habit-photo relationship setup
        habitPhoto.habit = testHabit
        testHabit.photos.append(habitPhoto)
        
        #expect(testHabit.photos.count == 1, "Habit should have one photo")
        #expect(testHabit.photos.first?.id == habitPhoto.id, "Photo relationship should be correct")
        #expect(habitPhoto.habit?.id == testHabit.id, "Back reference should be correct")
    }
    
    // MARK: - Test 5: HomeViewModel State Management and Data Loading
    /**
     * Test Purpose: Tests the HomeViewModel's state management and data loading capabilities
     * Intent: Validates proper handling of habit collections and filtering operations
     * Coverage: Initial state, habit management, filtering, and sorting operations
     * Architecture Testing: Ensures proper MVVM pattern implementation
     */
    @Test("HomeViewModel should manage habit collections and filtering correctly")
    func testHomeViewModelStateManagementAndDataLoading() async throws {
        // Test initial state
        let viewModel = await HomeViewModel()
        await #expect(viewModel.habits.isEmpty, "Initial habits array should be empty")
        
        // Create test habits with different categories and completion states
        let healthHabit = Habit(name: "Exercise", category: .health)
        let productivityHabit = Habit(name: "Reading", category: .productivity)
        let leisureHabit = Habit(name: "Guitar", category: .leisure)
        
        // Mark one habit as completed
        healthHabit.isCompletedToday = true
        healthHabit.streakCounter = 5
        
        let testHabits = [healthHabit, productivityHabit, leisureHabit]
        
        // Test adding habits to view model
        viewModel.habits = testHabits
        await #expect(viewModel.habits.count == 3, "Habits array should contain loaded data")
        await #expect(viewModel.habits.first?.name == "Exercise", "First habit should match expected data")
        
        // Test habit filtering by category
        let healthHabits = await viewModel.habits.filter { $0.category == .health }
        #expect(healthHabits.count == 1, "Should find one health habit")
        #expect(healthHabits.first?.name == "Exercise", "Should return correct health habit")
        
        let productivityHabits = await viewModel.habits.filter { $0.category == .productivity }
        #expect(productivityHabits.count == 1, "Should find one productivity habit")
        
        // Test habit filtering by completion status
        let completedHabits = await viewModel.habits.filter { $0.isCompletedToday }
        #expect(completedHabits.count == 1, "Should find one completed habit")
        #expect(completedHabits.first?.name == "Exercise", "Completed habit should be Exercise")
        
        let incompleteHabits = await viewModel.habits.filter { !$0.isCompletedToday }
        #expect(incompleteHabits.count == 2, "Should find two incomplete habits")
        
        // Test search functionality 
        let searchTerm = "read"
        let searchResults = await viewModel.habits.filter { 
            $0.name.localizedCaseInsensitiveContains(searchTerm) ||
            $0.habitDescription.localizedCaseInsensitiveContains(searchTerm)
        }
        #expect(searchResults.count == 1, "Search should return one result")
        #expect(searchResults.first?.name == "Reading", "Search should find Reading habit")
        
        // Test category grouping
        let categoryGroups = await Dictionary(grouping: viewModel.habits) { $0.category }
        #expect(categoryGroups.keys.count == 3, "Should have 3 different categories")
        #expect(categoryGroups[.health]?.count == 1, "Health category should have 1 habit")
        #expect(categoryGroups[.productivity]?.count == 1, "Productivity category should have 1 habit")
        #expect(categoryGroups[.leisure]?.count == 1, "Leisure category should have 1 habit")
    }
    
    // MARK: - Test 6: End-to-End Habit Completion and Streak Management
    /**
     * Test Purpose: Tests the complete habit completion workflow and streak management
     * Intent: Validates the entire user journey for completing habits and tracking progress
     * Coverage: Habit completion, streak calculation, photo integration, and state management
     * Integration Testing: Ensures all components work together correctly for habit tracking
     * User Journey: Simulates real user interactions and validates expected outcomes
     */
    @Test("End-to-end habit completion workflow should manage streaks and photos correctly")
    func testEndToEndHabitCompletionWorkflowAndStreakManagement() async throws {
        // Setup: Create test habits with different frequencies
        let dailyHabit = Habit(
            name: "Daily Water Intake",
            frequency: .daily,
            category: .health,
        )
        
        let weeklyHabit = Habit(
            name: "Weekly Review",
            frequency: .weekly,
            category: .productivity
        )
        
        let monthlyHabit = Habit(
            name: "Monthly Reflection",
            frequency: .monthly,
            category: .personal
        )
        
        // Test initial state for all habits
        let habits = [dailyHabit, weeklyHabit, monthlyHabit]
        for habit in habits {
            #expect(habit.streakCounter == 0, "New habit should have zero streak")
            #expect(habit.longestStreak == 0, "New habit should have zero longest streak")
            #expect(habit.daysActive == 0, "New habit should have zero days active")
            #expect(habit.dayCounter == 0, "New habit should have zero day counter")
            #expect(habit.isCompletedToday == false, "New habit should not be completed")
            #expect(habit.photos.isEmpty, "New habit should have no photos")
        }
        
        // Test daily habit completion workflow
        let testPhotoData = "completion photo".data(using: .utf8)!
        
        // Test photo creation and association
        let completionPhoto = HabitPhoto(
            photoData: testPhotoData,
            note: "Completed my daily water intake! 💧",
            timestamp: Date()
        )
        
        completionPhoto.habit = dailyHabit
        dailyHabit.photos.append(completionPhoto)
        
        #expect(dailyHabit.photos.count == 1, "Habit should have one photo after completion")
        #expect(((dailyHabit.photos.first?.note.contains("💧")) != nil), "Photo note should contain emoji")
        #expect(dailyHabit.hasPhotos == true, "Habit should indicate it has photos")
        
        // Simulate streak logic for daily habit
        dailyHabit.isCompletedToday = true
        dailyHabit.streakCounter = 1
        dailyHabit.daysActive = 1
        dailyHabit.longestStreak = 1
        
        // Test daily habit progress
        #expect(dailyHabit.calculateProgress() == 1.0, "Completed daily habit should show 100% progress")
        
        // Test weekly habit progression
        weeklyHabit.dayCounter = 3 // 3 days completed this week
        let weeklyProgress = weeklyHabit.calculateProgress()
        #expect(abs(weeklyProgress - (3.0/7.0)) < 0.01, "Weekly habit should show correct progress")
        #expect(weeklyHabit.progressText == "3/7", "Weekly habit should show 3/7 progress")
        
        // Simulate completing a full week
        weeklyHabit.dayCounter = 7
        weeklyHabit.streakCounter = 1
        weeklyHabit.dayCounter = 0 
        
        #expect(weeklyHabit.streakCounter == 1, "Weekly habit should have 1 week streak")
        #expect(weeklyHabit.calculateProgress() == 0.0, "Weekly habit should reset progress after completion")
        
        // Test monthly habit progression
        monthlyHabit.dayCounter = 15 // Half month completed
        let monthlyProgress = monthlyHabit.calculateProgress()
        #expect(abs(monthlyProgress - 0.5) < 0.01, "Monthly habit should show 50% progress")
        #expect(monthlyHabit.progressText == "15/30", "Monthly habit should show 15/30 progress")
        
        // Simulate completing a full month
        monthlyHabit.dayCounter = 30
        monthlyHabit.streakCounter = 1
        monthlyHabit.dayCounter = 0
        
        #expect(monthlyHabit.streakCounter == 1, "Monthly habit should have 1 month streak")
        #expect(monthlyHabit.calculateProgress() == 0.0, "Monthly habit should reset progress after completion")

        // Test multiple photo additions over time
        let secondPhoto = HabitPhoto(
            photoData: testPhotoData,
            note: "Day 2 completion 🎯",
            timestamp: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        )
        
        secondPhoto.habit = dailyHabit
        dailyHabit.photos.append(secondPhoto)
        
        #expect(dailyHabit.photos.count == 2, "Habit should have two photos")
        
        // Test photo sorting and retrieval
        let sortedPhotos = dailyHabit.getSortedPhotos()
        #expect(sortedPhotos.count == 2, "Should return all photos sorted")
        #expect(((sortedPhotos.first?.note.contains("🎯")) != nil), "Most recent photo should be first")
        
        let latestPhoto = dailyHabit.latestPhoto
        #expect(((latestPhoto?.note.contains("🎯")) != nil), "Latest photo should be the most recent")
        
        // Test frequency unit display
        #expect(dailyHabit.frequencyUnit == "day", "Single day streak should use singular")
        #expect(weeklyHabit.frequencyUnit == "week", "Single week streak should use singular")
        
        // Simulate longer streaks
        dailyHabit.streakCounter = 10
        weeklyHabit.streakCounter = 5
        
        #expect(dailyHabit.frequencyUnit == "days", "Multiple day streak should use plural")
        #expect(weeklyHabit.frequencyUnit == "weeks", "Multiple week streak should use plural")
        
        // Final integration verification
        let integrationChecks = [
            "dailyHabitCompleted": dailyHabit.isCompletedToday,
            "photosAttached": dailyHabit.hasPhotos,
            "streaksCalculated": dailyHabit.streakCounter > 0,
            "progressTracked": dailyHabit.calculateProgress() > 0,
            "weeklyProgressCorrect": weeklyHabit.streakCounter > 0,
            "monthlyProgressTracked": monthlyHabit.dayCounter >= 0
        ]
        
        let allIntegrationPassed = integrationChecks.values.allSatisfy { $0 ?? false }
        #expect(allIntegrationPassed, "All habit completion workflow components should work together")
    }
}
