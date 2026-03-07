//
//  HabitList.swift
//  SnapHabit
//
//  Created by Agam Singh on 15/8/2025.
//

/// A Reusable Component View that displays a single habit item in a list format.
/// 
/// This view presents the habit's name, time, frequency, streak counter, and completion status.
/// It includes a colored indicator bar on the left side, which reflects the habit's assigned color.
/// The habit name is displayed with a strikethrough effect if the habit has been completed today.
/// 
/// - Parameters:
///   - habit: The `Habit` object containing all relevant information about the habit.
/// # Features:
///  - Displays the habit name, time, frequency, and streak counter.
///  - Shows a colored indicator bar on the left side.
///  - Applies a strikethrough effect to the habit name if completed today.
///  - Includes a completion status indicator (checkmark or empty circle).
/// 
/// - SeeAlso:
///  - `Habit` model for the data structure used in this view.
///  - `HabitDetailRow` for displaying detailed information about a habit.
/// 
import SwiftUI

struct HabitListItem: View {
    let habit: Habit
    
    var body: some View {
        Button(action: {
            // Handle button tap
            print("Tapped on \(habit.name)")
        }) {
            HStack(spacing: 0) {
                // Color indicator bar
                Rectangle()
                    .fill(habit.color.color)
                    .frame(width: 4)
                    .cornerRadius(2)
                    .opacity(habit.isCompletedToday ? 0.6 : 1.0)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(habit.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(habit.isCompletedToday ? .secondary : .primary)
                                .strikethrough(habit.isCompletedToday, color: .secondary)
                            
                            Text("\(habit.time) \(habit.frequency.rawValue)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Streak counter and completion status
                        VStack(spacing: 6) {
                            Text("\(habit.streakCounter) day streak")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(habit.isCompletedToday ? Color.green.opacity(0.7) : Color.blue.opacity(0.7))
                                .cornerRadius(12)
                            
                            // Completion status indicator
                            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 24))
                                .foregroundColor(habit.isCompletedToday ? .green : .gray.opacity(0.5))
                        }
                    }
                }
                .padding(.leading, 16)
                .padding(.vertical, 12)
            }
        }
    }
}
