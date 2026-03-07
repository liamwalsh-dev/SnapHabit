import SwiftUI

struct EditHabitView: View {
    // MARK: - Properties
    let habit: Habit
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject var viewModel = EditHabitViewModel()
    @Environment(\.dismiss) private var dismiss

    // MARK: - Main View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HeaderView()
                    HabitInfoSection(viewModel: viewModel)
                    FrequencySection(viewModel: viewModel)
                    ColorThemeSection(viewModel: viewModel)
                    CategorySection(viewModel: viewModel)
                    ErrorMessageView(errorMessage: viewModel.errorMessage)
                    SuccessMessageView(successMessage: viewModel.successMessage)
                    ActionButtons(viewModel: viewModel, homeViewModel: homeViewModel, habit: habit, dismiss: { dismiss() })
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Load existing habit data when view appears
                viewModel.loadHabit(habit)
            }
        }
    }
}

// MARK: - Header Component
// Shows title and subtitle
struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Edit Habit")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            Text("Update your habit details")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
}

// MARK: - Habit Information Component
// Form fields for habit name, description and reminder time
struct HabitInfoSection: View {
    @ObservedObject var viewModel: EditHabitViewModel

    var body: some View {
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
    }
}

// MARK: - Frequency Selection Component
// Picker for daily, weekly, or monthly frequency
struct FrequencySection: View {
    @ObservedObject var viewModel: EditHabitViewModel

    var body: some View {
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
                // Style the picker as a segmented control
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Color Theme Component
// Grid of color options for habit theme
struct ColorThemeSection: View {
    @ObservedObject var viewModel: EditHabitViewModel

    var body: some View {
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
    }
}

// MARK: - Category Selection Component
// Dropdown menu for choosing habit category
struct CategorySection: View {
    @ObservedObject var viewModel: EditHabitViewModel

    var body: some View {
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
    }
}

// MARK: - Error Message Component
// Shows error message if something goes wrong
struct ErrorMessageView: View {
    let errorMessage: String?

    var body: some View {
        if let errorMessage = errorMessage {
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
    }
}

// MARK: - Success Message Component
// Shows success message when habit is updated
struct SuccessMessageView: View {
    let successMessage: String?

    var body: some View {
        if let successMessage = successMessage {
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
    }
}

// MARK: - Action Buttons Component
// Cancel and save buttons at the bottom
struct ActionButtons: View {
    @ObservedObject var viewModel: EditHabitViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    let habit: Habit
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Cancel button - go back without saving
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            // Save button - update habit with new changes
            Button(action: {
                viewModel.saveChanges(to: homeViewModel, habit: habit)
                if viewModel.successMessage != nil {
                    // Auto dismiss after successful save (after 1 second)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        dismiss()
                    }
                }
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text("Save Changes")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.color.color)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}
