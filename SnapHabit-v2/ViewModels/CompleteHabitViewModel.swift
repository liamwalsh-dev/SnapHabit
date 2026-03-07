//
//  CompleteHabitViewModel.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 15/9/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

/// ViewModel for completing a habit.
/// 
/// This class manages the state and logic for completing a habit, including handling photo uploads and notes.
/// It uses the `@MainActor` attribute to ensure that all UI updates are performed on the main thread.
/// 
/// # Properties:
///  - `isLoading`: A boolean indicating if a completion operation is in progress.
///  - `errorMessage`: An optional error message to display if the completion fails.
///  - `successMessage`: An optional success message to display when a habit is completed successfully.
///  - `showError`: A boolean to control the display of error messages.
///  - `showSuccess`: A boolean to control the display of success messages.
///  - `homeViewModel`: A reference to the `HomeViewModel` for refreshing habits after completion.
/// 
/// # Methods:
/// - `completeHabit(_:with:note:)`: Completes the given habit with an optional photo and note.
/// 
/// - SeeAlso: `HomeViewModel`, `Habit`, `HabitPhoto`
@MainActor
class CompleteHabitViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    
    private let homeViewModel: HomeViewModel
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
    }
    
    /// Function to complete a habit with an optional photo and note.
    /// 
    /// This function handles the logic for completing a habit, including validating the photo, processing it,
    /// and updating the habit's completion status. It also manages success and error messages based on the operation's outcome.
    /// 
    /// - Parameters:
    ///   - habit: The `Habit` instance to be completed.
    ///   - image: An optional `UIImage` representing the photo to be associated with the habit completion.
    ///   - note: A string note to be associated with the habit completion.
    /// 
    /// - Returns: This function does not return a value but updates the state of the ViewModel.
    /// 
    /// - Throws: This function does not throw errors but sets error messages in the `errorMessage` property if validation fails.
    ///
    func completeHabit(_ habit: Habit, with image: UIImage?, note: String) async {
        isLoading = true
        errorMessage = nil
        
        guard let image = image else {
            errorMessage = "Photo is required to complete the habit"
            showError = true
            isLoading = false
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process the image"
            showError = true
            isLoading = false
            return
        }
        
        guard let modelContext = homeViewModel.modelContext else {
            errorMessage = "Database context not available"
            showError = true
            isLoading = false
            return
        }
        
        habit.completeWithPhoto(
            photoData: imageData, 
            note: note.isEmpty ? nil : note, 
            context: modelContext
        )
        
        homeViewModel.refreshHabits()
        
        successMessage = "Habit completed successfully!"
        showSuccess = true
        
        print("✅ Successfully completed habit '\(habit.name)' with photo")
        
        isLoading = false
    }
}