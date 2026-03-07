//
//  HabitPhoto.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 22/9/2025.
//
import SwiftUI
import Foundation
import SwiftData

/// A model representing a photo associated with a habit, including metadata such as notes and timestamps.
/// 
/// This model is used to store and manage photos taken to document habit completions.
/// Each photo has a unique identifier, optional image data, a note, and a timestamp indicating when the photo was taken.
/// 
/// - SeeAlso: Habit
/// # Properties:
///  - photoID: UUID - Unique identifier for the photo.
///  - photoData: Data? - Binary data of the photo.
///  - note: String - An optional note associated with the photo.
///  - timestamp: Date - The date and time when the photo was taken.
///  - habit: Habit? - A relationship to the associated Habit entity.
/// 
/// # Computed Properties:
///  - image: UIImage? - Converts the binary photo data to a UIImage.
///  - formattedTimestamp: String - A formatted string representation of the timestamp.
///  - formattedDate: String - A medium style formatted string representation of the date.
///
@Model
final class HabitPhoto {
    @Attribute(.unique) var photoID: UUID
    var photoData: Data?
    var note: String
    var timestamp: Date
    
    // Relationship to habit
    var habit: Habit?

    init(photoID: UUID = UUID(), photoData: Data? = nil, note: String = "", timestamp: Date = Date()) {
        self.photoID = photoID
        self.photoData = photoData
        self.note = note
        self.timestamp = timestamp
    }

    var image: UIImage? {
        guard let data = photoData else { return nil }
        return UIImage(data: data)
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}