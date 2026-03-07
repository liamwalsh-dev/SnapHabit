//
//  HabitView.swift
//  SnapHabit
//
//  Created by Agam Singh on 15/8/2025.
//

import SwiftUI

struct HomeView: View {
    // MARK: - State Properties
    @ObservedObject private var themeManager = ThemeManager.sharedTheme
    @EnvironmentObject var homeViewModel: HomeViewModel
    @StateObject private var quoteService = QuoteAPIService()

    @State private var draggedHabit: Habit?
    @State private var dragOffset = CGSize.zero

    // MARK: - Computed Properties
    // Get habits that are not completed today
    private var pendingHabits: [Habit] {
        let pending = homeViewModel.searchText.isEmpty ? homeViewModel.habits : homeViewModel.filteredHabits
        return pending.filter { !$0.isCompletedToday }
    }
    
    // Get habits that are completed today
    private var completedHabits: [Habit] {
        let completed = homeViewModel.searchText.isEmpty ? homeViewModel.habits : homeViewModel.filteredHabits
        return completed.filter { $0.isCompletedToday }
    }

    // Format date to show day and date 
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter
    }
    
    // MARK: - Header Components
    // Create the top section with title, date, quote and buttons
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                titleAndDate
                Spacer()
                actionButtons
            }
            quoteSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // Show app title and current date
    @ViewBuilder
    private var titleAndDate: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today's Habits")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(dateFormatter.string(from: Date()))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    // add habit buttons
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 8) {
            addHabitButton
        }
    }
    
    // Navigation button to add new habit
    @ViewBuilder
    private var addHabitButton: some View {
        NavigationLink {
            AddHabitView(homeViewModel: homeViewModel, viewModel: AddHabitViewModel())
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.blue)
                .clipShape(Circle())
        }
    }
    
    // Show motivational quote in blue box
    @ViewBuilder
    private var quoteSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(quoteService.quote ?? "The way to get started is to quit talking and begin doing.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            Text("\(quoteService.author ?? "Walt Disney")")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    @ViewBuilder
    private var searchBar: some View {
        TextField("Search Habits", text: $homeViewModel.searchText)
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
    }

    
    // MARK: - Habits List Components
    // Main list showing pending and completed habits
    @ViewBuilder
    private var habitsList: some View {
        List {
            searchBar
            pendingHabitsSection
            completedHabitsSection
        }
        .listStyle(.plain)
        .environment(\.editMode, homeViewModel.isReorderingEnabled ? .constant(.active) : .constant(.inactive))
        .refreshable {
            homeViewModel.loadHabits()
        }
    }
    
    // Section for habits not done today
    @ViewBuilder
    private var pendingHabitsSection: some View {
        if !pendingHabits.isEmpty {
            Section("Pending for Today") {
                ForEach(pendingHabits) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit, homeViewModel: homeViewModel)){
                        HabitListItem(habit: habit)
                    }
                }
                .onMove { source, destination in
                    homeViewModel.movePendingHabit(from: source, to: destination)
                }
            }
        } else {
            Section {
                Text("No Pending Habits")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // Section for habits completed today
    @ViewBuilder
    private var completedHabitsSection: some View {
        if !completedHabits.isEmpty {
            Section("Completed Today") {
                ForEach(completedHabits) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit, homeViewModel: homeViewModel)) {
                        HabitListItem(habit: habit)
                    }
                }
            }
        } else {
            Section {
                Text("No Completed Habits")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Main View Body
    // Main view that combines header and habits list
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                habitsList
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.colorScheme, themeManager.colorScheme ?? .light)
        .task {
            // Load habits when view appears
            homeViewModel.loadHabits()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            homeViewModel.checkAndResetForNewDay()
        }
        .onAppear {
            homeViewModel.checkAndResetForNewDay()
        }
    }
    
    @ViewBuilder
    private func pendingHabitRow(habit: Habit) -> some View {
        NavigationLink(destination: HabitDetailView(habit: habit, homeViewModel: homeViewModel)) {
            HabitListItem(habit: habit)
        }
        .disabled(homeViewModel.isReorderingEnabled)
        .opacity(draggedHabit?.id == habit.id ? 0.5 : 1.0)
        .offset(draggedHabit?.id == habit.id ? dragOffset : .zero)
        .scaleEffect(draggedHabit?.id == habit.id ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: draggedHabit?.id == habit.id)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .sequenced(before: DragGesture())
                .onChanged { value in
                    switch value {
                    case .first(true):
                        hapticFeedback()
                        homeViewModel.enableReordering()
                        draggedHabit = habit
                        
                    case .second(true, let drag):
                        if let drag = drag {
                            dragOffset = drag.translation
                        }
                        
                    default:
                        break
                    }
                }
                .onEnded { value in
                    draggedHabit = nil
                    dragOffset = .zero
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        homeViewModel.disableReordering()
                    }
                }
        )
    }

    // Haptic feedback helper
    private func hapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeViewModel())
}
