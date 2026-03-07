//
//  GalleryViewModel.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 22/9/2025.
//

import SwiftUI
import SwiftData

/// ViewModel for managing and displaying habit albums in the gallery.
/// 
/// This ViewModel handles loading habit albums, filtering them based on search text and categories,
/// and provides a list of categories available in the habit albums.
/// It interacts with the HomeViewModel to fetch the habits and their associated photos.
/// 
/// # Properties:
///  - `habitAlbums`: An array of `Habit` objects representing the habit albums.
///  - `isLoading`: A boolean indicating if the data is currently being loaded.
///  - `errorMessage`: An optional string to hold any error messages.
///  - `searchText`: A string for filtering habit albums based on their names.
///  - `selectedCategory`: A string representing the currently selected category for filtering.
///  - `filteredHabitAlbums`: A computed property that returns habit albums filtered by the search text.
///  - `homeViewModel`: An instance of `HomeViewModel` to fetch habits.
///
/// # Methods:
///  - `loadHabitAlbums()`: Loads habit albums from the HomeViewModel and sorts them by the latest photo date.
///  - `categoryList()`: Returns a list of unique categories from the habit albums.
///  - `filterByCategory(category:)`: Filters the habit albums based on the selected category.
///
@MainActor
class GalleryViewModel: ObservableObject {
    @Published var habitAlbums: [Habit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All"

    var filteredHabitAlbums: [Habit] {
        if searchText.isEmpty {
            return habitAlbums
        } else {
            return habitAlbums.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var homeViewModel: HomeViewModel

    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        loadHabitAlbums()
    }
    
    /// Function that loads habit albums from the HomeViewModel.
    /// 
    /// Loads habit albums from the HomeViewModel, filtering out habits without photos
    /// and sorting them by the date of their latest photo in descending order.
    /// Sets the loading state and handles any errors that may occur during the process.
    /// 
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    func loadHabitAlbums() {
        isLoading = true
        errorMessage = nil

        habitAlbums = homeViewModel.getHabits().filter { habit in
            !habit.photos.isEmpty
        }

        habitAlbums.sort { habit1, habit2 in
            let date1 = habit1.latestPhoto?.timestamp ?? Date.distantPast
            let date2 = habit2.latestPhoto?.timestamp ?? Date.distantPast
            return date1 > date2
        }
        
        isLoading = false
        print("📸 Loaded \(habitAlbums.count) habit albums")
    }

    /// Function that returns a list of unique categories from the habit albums.
    /// 
    /// Iterates through the habit albums to collect unique categories and returns them as a sorted array.
    ///
    /// - Parameters: None
    /// - Returns: An array of unique category names as strings.
    /// - Throws: None
    /// 
    func categoryList() -> [String] {
        var categories = Set<String>()
        for habit in habitAlbums {
            categories.insert(habit.category.rawValue)
        }
        return Array(categories).sorted()
    }

    /// Function that filters the habit albums based on the selected category on the View.
    /// 
    /// If the selected category is "All", it loads all habit albums.
    /// Otherwise, it filters the habit albums to include only those that match the selected category.
    ///
    /// - Parameters:
    ///   - category: A string representing the category to filter by.
    /// - Returns: None
    /// - Throws: None
    ///
    func filterByCategory(category: String) {
        if category == "All" {
            loadHabitAlbums()
        } else {
            habitAlbums = habitAlbums.filter { $0.category.rawValue == category }
        }
    }

}