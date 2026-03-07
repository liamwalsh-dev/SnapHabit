import SwiftUI

/// A Reusable Component View that displays a statistic card with a value, title, and color for `HabitDetailView`.
/// 
/// This view is used to present key statistics about a habit in a card format.
/// 
/// - Parameters:
///   - value: The main statistic value to be displayed (e.g., "5 days", "80%").
///   - title: A brief description of the statistic (e.g., "Days Completed", "Completion Rate").
///   - color: A `Color` used to style the value text, indicating the status of the statistic.
/// 
/// - SeeAlso: `HabitDetailView` for displaying detailed information about a habit.
struct StatisticCard: View {
    let value: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}