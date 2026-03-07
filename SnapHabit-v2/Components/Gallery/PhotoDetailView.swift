//
//  PhotoDetailView.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 16/9/2025.
//

import SwiftUI

/// A Reusable Component View that displays a detailed view of a specific photo associated with a habit.
/// 
/// This view shows the photo in a large format along with details about the habit, including the habit name, category, color, timestamp of when the photo was taken, and any notes associated with the photo.
/// 
/// - Parameters:
///  - habit: The habit to which the photo belongs.
///  - photoIndex: The index of the photo in the habit's photo array.
///  - image: The UIImage to be displayed.
///  - habitPhoto: The HabitPhoto object containing metadata about the photo.
/// 
/// # Features:
///  - Displays the photo in a large format.
///  - Shows details about the habit, including name, category, and color.
///  - Displays the timestamp of when the photo was taken.
///  - Shows any notes associated with the photo.
/// 
/// - SeeAlso: `HabitPhotosView` for viewing all photos associated with a habit.
struct PhotoDetailView: View {
    let habit: Habit
    let photoIndex: Int
    let image: UIImage
    let habitPhoto: HabitPhoto 
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Photo Section
                photoSection
                
                // MARK: - Details Section
                detailsSection
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Photo \(photoIndex + 1)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var photoSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Photo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(habit.color.color, lineWidth: 3)
                    )
                
                if habit.photos.count > 1 {  
                    Text("Photo \(photoIndex + 1) of \(habit.photos.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                // Habit info
                HStack {
                    Circle()
                        .fill(habit.color.color)
                        .frame(width: 20, height: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(habit.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(habit.category.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    Text("Completed")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(habitPhoto.formattedTimestamp) 
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                        .frame(width: 20)
                    
                    Text("Streak")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(habit.streakCounter) ")  
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                }
                
                Divider()
                
                if !habitPhoto.note.isEmpty {  
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .frame(width: 20)
                            
                            Text("Note")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(habitPhoto.note)  
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .padding(16)
                            .background(habit.color.color.opacity(0.1))
                            .cornerRadius(12)
                    }
                } else {
                    HStack {
                        Image(systemName: "note.text")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        
                        Text("No note added for this photo")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        PhotoDetailView( 
            habit: Habit(name: "Demo Habit"),
            photoIndex: 0,
            image: UIImage(systemName: "photo") ?? UIImage(),
            habitPhoto: HabitPhoto(  
                photoData: Data(),
                note: "Sample",
                timestamp: Date()
            )
        )
    }
}