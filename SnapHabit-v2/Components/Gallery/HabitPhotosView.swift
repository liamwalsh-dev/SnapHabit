//
//  HabitPhotosView.swift  
//  SnapHabit-v2
//
//  Created by Agam Singh on 16/9/2025.
//

import SwiftUI

/// A Reusable Component View that displays all photos associated with a specific habit in a grid layout.
/// 
/// This view provides a header section with habit details and statistics, followed by a grid of photos. Each photo can be tapped to navigate to a detailed view of that photo.
/// 
/// - Parameters:
///   - habit: The habit for which photos are displayed.
/// 
/// # Features:
///  - Displays a header section with habit details and statistics.
///  - Shows a grid of photos related to the habit.
///  - Tapping on a photo navigates to a detailed view of that photo.
///  
/// - SeeAlso: `PhotoDetailView` for viewing individual photos in detail.
/// 
struct HabitPhotosView: View {
    let habit: Habit
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    
    private var photosWithNotes: [(UIImage, String, HabitPhoto)] {
        return habit.photos.compactMap { habitPhoto in
            if let image = habitPhoto.image {
                return (image, habitPhoto.note, habitPhoto)
            }
            return nil
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Header
                headerSection
                
                // MARK: - Photo Grid
                if photosWithNotes.isEmpty {
                    emptyPhotosView
                } else {
                    photoGridSection
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                // Habit info
                HStack {
                    Circle()
                        .fill(habit.color.color)
                        .frame(width: 20, height: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(habit.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(habit.category.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Stats
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Streak")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                            Text("\(habit.streakCounter)") 
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Photos")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(photosWithNotes.count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var emptyPhotosView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Photos Found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("This habit doesn't have any completion photos yet.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var photoGridSection: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(Array(photosWithNotes.enumerated()), id: \.offset) { index, photoData in
                let (image, note, habitPhoto) = photoData  
                
                NavigationLink(destination: PhotoDetailView(
                    habit: habit, 
                    photoIndex: index, 
                    image: image, 
                    habitPhoto: habitPhoto  
                )) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .overlay(
                            Rectangle()
                                .stroke(habit.color.color.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        HabitPhotosView(habit: Habit(name: "Morning Exercise"))
    }
}