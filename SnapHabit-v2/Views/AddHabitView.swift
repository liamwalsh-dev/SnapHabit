//  AddHabitView.swift
//  SnapHabit
//
//  Created by Agam Singh on 19/8/2025.
//

import SwiftUI

struct AddHabitView: View {
    // MARK: - Properties
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject var viewModel: AddHabitViewModel
    
    // MARK: - Main View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header Section
                    // Show title and subtitle for creating new habit
                    VStack(spacing: 8) {
                        Text("Create New Habit")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Build a better you, one habit at a time")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Habit Information Section
                    // Input fields for habit name, description and reminder time
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Habit Info")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            VStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Name")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    TextField("Enter habit name", text: $viewModel.name)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.system(size: 16))
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Description")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    TextField("What's this habit about?", text: $viewModel.habitDescription)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.system(size: 16))
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Reminder Time")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    DatePicker(
                                        "Select Time",
                                        selection: $viewModel.time,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .font(.system(size: 16))
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Frequency Selection Section
                    // Let user choose how often to do the habit (daily, weekly, monthly)
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Frequency")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            Picker("Frequency", selection: $viewModel.frequency) {
                                ForEach(Habit.HabitFrequency.allCases, id: \.self) { freq in
                                    Text(freq.rawValue.capitalized)
                                        .font(.system(size: 16, weight: .medium))
                                        .tag(freq)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Color Theme Section
                    // Grid of colors for user to pick habit theme color
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Color Theme")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach(Habit.HabitColor.allCases, id: \.self) { habitColor in
                                    Button(action: {
                                        viewModel.color = habitColor
                                    }) {
                                        VStack(spacing: 8) {
                                            Circle()
                                                .fill(habitColor.color)
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.primary, lineWidth: viewModel.color == habitColor ? 3 : 0)
                                                )
                                            Text(habitColor.rawValue.capitalized)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(viewModel.color == habitColor ? .primary : .secondary)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Category Selection Section
                    // Dropdown menu to choose habit category
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            Picker("Category", selection: $viewModel.category) {
                                ForEach(Habit.HabitCategory.allCases, id: \.self) { cat in
                                    Text(cat.rawValue)
                                        .font(.system(size: 16))
                                        .tag(cat)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Error and Success Messages
                    // Show error message if something went wrong
                    if let errorMessage = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                    // Show success message when habit is created
                    if let successMessage = viewModel.successMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                            Text(successMessage)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Create Button Section
                    // Button to save the new habit with all the selected options
                    Button(action: {
                        viewModel.addHabit(to: homeViewModel)
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .medium))
                            Text("Create Habit")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.color.color)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
        }
    }
}

#Preview {
    AddHabitView(homeViewModel: HomeViewModel(), viewModel: AddHabitViewModel())
}
