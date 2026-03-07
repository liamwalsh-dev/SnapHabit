//
//  HabitDetailView.swift
//  SnapHabit
//
//  Created by Agam Singh on 15/8/2025.
//

import SwiftUI

struct HabitDetailView: View {
    // MARK: - Properties
    let habit: Habit
    @ObservedObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Computed Properties
    private var progress: Double {
        habit.calculateProgress()
    }
    
    private var progressDays: Int {
        return habit.dayCounter
    }

    private var totalTargetDays: Int {
        return habit.progressTarget
    }
    
    private var frequencyDescription: String {
        switch habit.frequency {
        case .daily:
            return "day"
        case .weekly:
            return "week"
        case .monthly:
            return "month"
        }
    }

    // MARK: - Main View Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header Section
                VStack(spacing: 12) {
                    Text(habit.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(habit.habitDescription)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // MARK: - Streak Section
                VStack(spacing: 16) {
                    Text("Current Streak")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text("\(habit.streakCounter)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(habit.color.color)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.orange)
                        Text(frequencyDescription)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        if habit.frequency == .daily {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(habit.isCompletedToday ? habit.color.color : Color.gray.opacity(0.3))
                                    .frame(width: 12, height: 12)
                                
                                Text(habit.isCompletedToday ? "Completed today" : "Not completed today")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            ProgressView(value: Double(progressDays), total: Double(totalTargetDays))
                                .progressViewStyle(LinearProgressViewStyle(tint: habit.color.color))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .clipShape(Capsule())

                            Text("\(progressDays) of \(totalTargetDays) days this \(frequencyDescription)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // MARK: - Statistics Section
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        StatisticCard(
                            value: "\(habit.daysActive)",
                            title: "DAYS ACTIVE",
                            color: habit.color.color
                        )

                        StatisticCard(
                            value: "\(habit.longestStreak)",
                            title: "LONGEST STREAK",
                            color: habit.color.color
                        )
                    }
                    
                    StatisticCard(
                        value: "\(Int(progress * 100))%",
                        title: "CURRENT COMPLETION RATE",
                        color: habit.color.color
                    )
                }
                .padding(.horizontal, 20)
                
                // MARK: - Habit Details Section
                VStack(spacing: 16) {
                    HabitDetailRow(
                        title: "Frequency",
                        value: habit.frequency.rawValue.capitalized,
                        color: habit.color.color
                    )
                    
                    HabitDetailRow(
                        title: "Target",
                        value: habit.progressText, 
                        color: habit.color.color
                    )
                    
                    HabitDetailRow(
                        title: "Reminder Time",
                        value: habit.time.isEmpty ? "Not set" : habit.time,
                        color: .clear
                    )
                    
                    HabitDetailRow(
                        title: "Category",
                        value: habit.category.rawValue,
                        color: habit.color.color
                    )
                }
                .padding(.horizontal, 20)
                
                // MARK: - Action Buttons Section
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        NavigationLink(destination: EditHabitView(habit: habit, homeViewModel: homeViewModel)) {
                            HStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Edit Habit")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }

                        Button(action: {
                            let habitName = habit.name
                            let confirmation = "Are you sure you want to delete the habit '\(habitName)'?"

                            let alert = UIAlertController(title: "Confirm Deletion", message: confirmation, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                                homeViewModel.deleteHabit(habit)
                                dismiss()
                            })
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Delete Habit")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                    }
                    
                    NavigationLink(destination: CompleteHabitView(habit: habit, homeViewModel: homeViewModel)) {
                        HStack {
                            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "checkmark")
                                .font(.system(size: 16, weight: .medium))
                            Text(habit.isCompletedToday ? "Completed for today" : "Complete Habit")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(habit.isCompletedToday ? Color.gray : Color.green)
                        .cornerRadius(12)
                    }
                    .disabled(habit.isCompletedToday)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}