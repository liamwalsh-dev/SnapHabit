import SwiftUI

struct HabitAnalysisView: View {
    @State private var viewModel: HabitAnalysisViewModel
    @ObservedObject var database: database
    @ObservedObject private var themeManager = ThemeManager.sharedTheme
    
    init(database: database) {
        self.database = database
        self._viewModel = State(initialValue: HabitAnalysisViewModel(database: database))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    habitSelectorSection
                    
                    if viewModel.isLoading {
                        loadingView
                    } else if let error = viewModel.errorMessage {
                        errorView(error)
                    } else if viewModel.insights.isEmpty && viewModel.selectedHabit != nil {
                        emptyStateView
                    } else if !viewModel.insights.isEmpty {
                        insightsSection
                    } else {
                        initialStateView
                    }
                }
                .padding()
            }
            .navigationTitle("AI Insights")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.refreshAvailableHabits()
            }
            .onChange(of: database.items) { oldValue, newValue in
                viewModel.refreshAvailableHabits()
            }
        }
        .environment(\.colorScheme, themeManager.colorScheme ?? .light)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title)
                    .foregroundColor(.purple)
                
                Text("Habit Intelligence")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("AI-powered analysis of your habit patterns and personalized recommendations")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
    
    private var habitSelectorSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Select Habit to Analyze")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Habit Picker
                Picker("Select Habit", selection: $viewModel.selectedHabit) {
                    Text("Choose a habit...")
                        .tag(nil as Habit?)
                    
                    ForEach(viewModel.availableHabits, id: \.id) { habit in
                        HStack {
                            Text(habit.name)
                            Spacer()
                            Text("🔥 \(habit.streakCounter)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .tag(habit as Habit?)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Generate Button
                Button(action: {
                    guard let selectedHabit = viewModel.selectedHabit else { return }
                    Task {
                        await viewModel.generateInsights(for: selectedHabit)
                    }
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Generate AI Insights")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedHabit != nil ? Color.purple : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(viewModel.selectedHabit == nil || viewModel.isLoading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var initialStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 50))
                .foregroundColor(.purple)
            
            VStack(spacing: 8) {
                Text("Ready to Analyze")
                    .font(.headline)
                
                Text("Select a habit from above and click 'Generate AI Insights' to get personalized recommendations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.purple)
            
            VStack(spacing: 8) {
                if let habitName = viewModel.selectedHabit?.name {
                    Text("Analyzing '\(habitName)'")
                        .font(.headline)
                } else {
                    Text("Analyzing Your Habit")
                        .font(.headline)
                }
                
                Text("Generating personalized insights...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Analysis Failed")
                    .font(.headline)
                
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Try Again") {
                guard let selectedHabit = viewModel.selectedHabit else { return }
                Task {
                    await viewModel.generateInsights(for: selectedHabit)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Insights Generated")
                    .font(.headline)
                
                Text("Unable to generate insights for this habit. Try analyzing a habit with more tracking data.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var insightsSection: some View {
        VStack(spacing: 16) {
            HStack {
                if let habitName = viewModel.selectedHabit?.name {
                    Text("Insights for '\(habitName)'")
                        .font(.headline)
                        .foregroundColor(.primary)
                } else {
                    Text("Generated Insights")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            
            LazyVStack(spacing: 16) {
                ForEach(viewModel.insights.sorted { $0.priority.rawValue < $1.priority.rawValue }) { insight in
                    InsightCard(insight: insight)
                }
            }
        }
    }
}


// MARK: - Extensions for Display Names 

/// This extension provides display names for the HabitInsightType enum cases for the UI (User Friendly).
/// 
/// # Properties:
///  - `displayName`: A user-friendly string representation of each HabitInsightType case.
/// 
/// # Cases:
///  - `critical`: "Critical Issue"
///  - `improvement`: "Improvement Area"
///  - `success`: "Success Story"
///  - `trend`: "Trend Analysis"
/// 
/// - SeeAlso: `HabitInsightType`
extension HabitInsightType {
    var displayName: String {
        switch self {
        case .critical: return "Critical Issue"
        case .improvement: return "Improvement Area"
        case .success: return "Success Story"
        case .trend: return "Trend Analysis"
        }
    }
}

/// This extension provides raw values, display names, and colors for the InsightPriority enum cases for the UI (User Friendly).
/// 
/// # Properties:
///  - `rawValue`: An integer representing the priority level (0 for high, 1 for medium, 2 for low).
///  - `displayName`: A user-friendly string representation of each priority level.
///  - `color`: A SwiftUI Color associated with each priority level.
/// 
///  # Cases:
///  - `high`: "High" with red color
///  - `medium`: "Medium" with orange color
///  - `low`: "Low" with green color
/// 
/// - SeeAlso: `InsightPriority`
extension InsightPriority {
    var rawValue: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
    
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

#Preview {
    HabitAnalysisView(database: database())
}