//
//  Habits.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 15/9/2025.
//

import SwiftUI
import Foundation
import SwiftData

/// Habit Model representing a habit with various attributes and relationships.
///
/// This model includes properties for tracking habit details such as name, description,
/// frequency, streaks, completion status, and associated photos. It also contains methods
/// for completing the habit, updating streaks, and calculating progress.
/// 
/// - Parameters:
///  - id: Unique identifier for the habit.
///  - name: Name of the habit.
///  - habitDescription: Description of the habit.
///  - time: Time associated with the habit.
///  - frequency: Frequency of the habit (daily, weekly, monthly).
///  - streakCounter: Current streak count for the habit.
///  - dayCounter: Counter for days towards the next streak.
///  - longestStreak: Longest streak achieved for the habit.
///  - daysActive: Total number of days the habit has been active.
///  - color: Color associated with the habit.
///  - isCompletedToday: Boolean indicating if the habit is completed today.
///  - category: Category of the habit.
///  - lastCompletedDate: The last date the habit was completed.
///  - order: Optional order for sorting habits.
///  - photos: Relationship to HabitPhoto entities associated with the habit.
///
/// - SeeAlso: HabitPhoto
/// 
@Model
final class Habit: Identifiable {
    var id: UUID
    var name: String
    var habitDescription: String 
    var time: String
    var frequency: HabitFrequency
    var streakCounter: Int
    var dayCounter: Int
    var longestStreak: Int
    var daysActive: Int
    var color: HabitColor
    var isCompletedToday: Bool
    var category: HabitCategory
    var lastCompletedDate: String?
    var order: Int?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \HabitPhoto.habit)
    var photos: [HabitPhoto] = []

    init(id: UUID = UUID(), name: String, habitDescription: String = "", time: String = "", frequency: HabitFrequency = .daily, streakCounter: Int = 0, longestStreak: Int = 0, daysActive: Int = 0, color: HabitColor = .blue, isCompletedToday: Bool = false, category: HabitCategory = .general, lastCompletedDate: String? = nil, dayCounter: Int = 0, order: Int? = 0) {
        self.id = id
        self.name = name
        self.habitDescription = habitDescription
        self.time = time
        self.frequency = frequency
        self.streakCounter = streakCounter
        self.longestStreak = longestStreak
        self.daysActive = daysActive
        self.color = color
        self.isCompletedToday = isCompletedToday
        self.category = category
        self.lastCompletedDate = lastCompletedDate
        self.dayCounter = dayCounter
        self.order = order
        self.createdAt = Date()
    }
    
    /// Enumeration for Habit Frequency
    /// 
    /// Enum representing the frequency of the habit.
    /// 
    /// - daily: Habit occurs daily.
    /// - weekly: Habit occurs weekly.
    /// - monthly: Habit occurs monthly.
    ///
    enum HabitFrequency: String, CaseIterable, Codable {
        case daily
        case weekly
        case monthly
    }

    /// Enumeration for Habit Category
    /// 
    /// Enum representing various categories for habits.
    /// 
    /// - general: General category.
    /// - health: Health-related habits.
    /// - productivity: Productivity-related habits.
    /// - leisure: Leisure activities.
    /// - social: Social interactions.
    /// - family: Family-related habits.
    /// - personal: Personal development habits.
    /// - spiritual: Spiritual practices.
    ///
    enum HabitCategory: String, CaseIterable, Codable {
        case general = "General"
        case health = "Health"
        case productivity = "Productivity"
        case leisure = "Leisure"
        case social = "Social"
        case family = "Family"
        case personal = "Personal"
        case spiritual = "Spiritual"
    }

    /// Enumeration for Habit Color
    /// 
    /// Enum representing available colors for habits.
    /// 
    enum HabitColor: String, CaseIterable, Codable {
        case blue = "blue"
        case green = "green"
        case yellow = "yellow"
        case red = "red"
        case orange = "orange"
        case pink = "pink"
        case purple = "purple"
        
        /// A Switch case that converts HabitColor to SwiftUI Color
        /// 
        /// - Returns: Corresponding SwiftUI Color
        ///
        var color: Color {
            switch self {
            case .blue: return .blue
            case .green: return .green
            case .purple: return .purple
            case .orange: return .orange
            case .red: return .red
            case .pink: return .pink
            case .yellow: return .yellow
            }
        }
    }
    
    // MARK: - Habit Methods

    /// Marks the habit as completed for today, updates streaks, and saves a photo with an optional note.
    /// 
    /// What it does:
    /// 1. Checks if the habit was already completed today to avoid double counting.
    /// 2. Creates a new HabitPhoto object with the provided photo data and note.
    /// 3. Associates the photo with the habit and appends it to the photos array
    /// 4. Updates the streak logic based on the habit's frequency.
    /// 5. Saves the changes to the ModelContext.
    ///
    /// - Parameters:
    ///   - photoData: The image data of the photo taken upon completion.
    ///   - note: An optional note associated with the photo.
    ///   - context: The ModelContext used for saving the habit and photo.
    ///
    /// - Returns: None
    /// 
    /// - Throws: Errors related to saving the habit and photo are caught and logged.
    ///
    func completeWithPhoto(photoData: Data, note: String?, context: ModelContext) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        let wasAlreadyCompletedToday = (lastCompletedDate == today && isCompletedToday)
        
        isCompletedToday = true

        let habitPhoto = HabitPhoto(
            photoData: photoData,
            note: note ?? "",
            timestamp: Date()
        )

        habitPhoto.habit = self
        photos.append(habitPhoto)
        context.insert(habitPhoto)
        
        if !wasAlreadyCompletedToday {
            updateStreakLogic(today: today, dateFormatter: dateFormatter)
            lastCompletedDate = today  
        } else {
            lastCompletedDate = today
        }
        
        do {
            try context.save()
            print("✅ Habit '\(name)' completed successfully. Streak: \(streakCounter)")
        } catch {
            print("❌ Failed to save habit completion: \(error)")
        }
    }

    /// Function to update the streak logic based on the habit's frequency.
    /// 
    /// A Switch case is used to handle different frequencies (daily, weekly, monthly).
    /// 
    /// - Parameters:
    ///   - today: The current date in "yyyy-MM-dd" format.
    ///   - dateFormatter: DateFormatter instance for parsing dates.
    /// 
    /// - Returns: None
    /// 
    /// - Throws: None
    ///
    private func updateStreakLogic(today: String, dateFormatter: DateFormatter) {
            switch frequency {
            case .daily:
                updateDailyStreak(today: today, dateFormatter: dateFormatter)
            case .weekly:
                updateWeeklyStreak(today: today, dateFormatter: dateFormatter)
            case .monthly:
                updateMonthlyStreak(today: today, dateFormatter: dateFormatter)
            }
            if streakCounter > longestStreak {
                longestStreak = streakCounter
            }
            daysActive += 1
        }

    /// This function updates the daily streak based on the last completed date.
    /// 
    /// It checks if the last completed date was yesterday to increment the streak,
    /// otherwise it resets the streak to 1.
    /// 
    /// - Parameters:
    ///  - today: The current date in "yyyy-MM-dd" format.
    ///  - dateFormatter: DateFormatter instance for parsing dates.
    /// 
    /// - Returns: None
    /// - Throws: None
    /// 
    private func updateDailyStreak(today: String, dateFormatter: DateFormatter) {
        if let lastDate = lastCompletedDate,
           let last = dateFormatter.date(from: lastDate),
           let todayDate = dateFormatter.date(from: today) {
            
            let calendar = Calendar.current
            
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: todayDate),
               calendar.isDate(last, inSameDayAs: yesterday) {
                streakCounter += 1
            } else {
                streakCounter = 1
            }
        } else {
            streakCounter = 1
        }
    }

    /// This function updates the weekly streak based on the last completed date.
    /// 
    /// It checks if the last completed date was within the past week to increment the day counter,
    /// and if the day counter reaches 7, it increments the streak counter.
    /// Otherwise, it resets the day counter and streak counter as needed.
    /// 
    /// - Parameters:
    ///  - today: The current date in "yyyy-MM-dd" format.
    ///  - dateFormatter: DateFormatter instance for parsing dates.
    /// 
    /// - Returns: None
    /// 
    /// - Throws: None
    ///
    private func updateWeeklyStreak(today: String, dateFormatter: DateFormatter) {
        guard let todayDate = dateFormatter.date(from: today) else {
            dayCounter = 1
            return
        }

        let calendar = Calendar.current

        if let lastDate = lastCompletedDate,
        let last = dateFormatter.date(from: lastDate) {

            let daysBetween = calendar.dateComponents([.day], from: last, to: todayDate).day ?? 0

            if daysBetween == 1 {
                dayCounter += 1
            } else if daysBetween > 1 && daysBetween <= 7 {
                // Still within the week, but not consecutive
                dayCounter += 1
            } else {
                // Missed too many days
                dayCounter = 1
                streakCounter = 0
            }

            if dayCounter >= 7 {
                streakCounter += 1
                dayCounter = 0
            }
        } else {
            dayCounter = 1
        }
    }

    /// This function updates the monthly streak based on the last completed date.
    /// 
    /// It checks if the last completed date was within the past month to increment the day counter,
    /// and if the day counter reaches 30, it increments the streak counter.
    /// Otherwise, it resets the day counter and streak counter as needed.
    /// 
    /// - Parameters:
    ///  - today: The current date in "yyyy-MM-dd" format.
    ///  - dateFormatter: DateFormatter instance for parsing dates.
    /// 
    /// - Returns: None
    /// 
    /// - Throws: None
    /// 
    private func updateMonthlyStreak(today: String, dateFormatter: DateFormatter) {
        guard let todayDate = dateFormatter.date(from: today) else {
            dayCounter = 1
            return
        }

        let calendar = Calendar.current

        if let lastDate = lastCompletedDate,
        let last = dateFormatter.date(from: lastDate) {

            let daysBetween = calendar.dateComponents([.day], from: last, to: todayDate).day ?? 0

            if daysBetween == 1 {
                dayCounter += 1
            } else if daysBetween > 1 && daysBetween <= 30 {
                dayCounter += 1
            } else {
                dayCounter = 1
                streakCounter = 0
            }

            if dayCounter >= 30 {
                streakCounter += 1
                dayCounter = 0
            }
        } else {
            dayCounter = 1
        }
    }

    /// A Switch that calculates the progress towards the next streak based on the habit's frequency.
    /// 
    /// - For daily habits, returns 1.0 if completed today, else 0.0.
    /// - For weekly habits, returns the ratio of dayCounter to 7.
    /// - For monthly habits, returns the ratio of dayCounter to 30.
    /// 
    /// - Returns: A Double value between 0.0 and 1.0 representing progress.
    /// - Throws: None
    ///
    func calculateProgress() -> Double {
        let progress: Double
        switch frequency {
        case .daily:
            return isCompletedToday ? 1.0 : 0.0
        case .weekly:
            progress = Double(dayCounter) / 7.0
        case .monthly:
            progress = Double(dayCounter) / 30.0
        }
        return min(progress, 1.0)
    }

    var progressTarget: Int {
        switch frequency {
        case .daily:
            return 1 
        case .weekly:
            return 7
        case .monthly:
            return 30
        }
    }
    
    var progressText: String {
        let target = progressTarget
        let current = min(dayCounter, target)
        return "\(current)/\(target)"
    }
    
    var frequencyUnit: String {
        switch frequency {
        case .daily:
            return streakCounter == 1 ? "day" : "days"
        case .weekly:
            return streakCounter == 1 ? "week" : "weeks"
        case .monthly:
            return streakCounter == 1 ? "month" : "months"
        }
    }
    
    // MARK: - Photo Helper Methods

    /// Gets the most recent completion image for the habit.
    ///
    /// - Returns: The most recent UIImage if available, else nil.
    /// - Throws: None
    ///
    func getCompletionImage() -> UIImage? {
        return photos.last?.image
    }
    
    /// Gets all completion images associated with the habit.
    /// 
    /// - Returns: An array of UIImages.
    /// - Throws: None
    ///
    func getAllCompletionImages() -> [UIImage] {
        return photos.compactMap { $0.image }
    }
    
    /// Gets all photos along with their associated notes.
    /// 
    /// - Returns: An array of tuples containing UIImage and its associated note.
    /// - Throws: None
    ///
    func getAllPhotosWithNotes() -> [(UIImage, String)] {
        return photos.compactMap { photo in
            if let image = photo.image {
                return (image, photo.note)
            }
            return nil
        }
    }
    
    /// Gets all photos sorted by timestamp in descending order (most recent first).
    /// 
    /// - Returns: An array of HabitPhoto objects sorted by timestamp.
    /// - Throws: None
    /// 
    func getSortedPhotos() -> [HabitPhoto] {
        return photos.sorted { $0.timestamp > $1.timestamp }
    }
    
    var latestPhoto: HabitPhoto? {
        return photos.max { $0.timestamp < $1.timestamp }
    }
    
    var hasPhotos: Bool {
        return !photos.isEmpty
    }
}