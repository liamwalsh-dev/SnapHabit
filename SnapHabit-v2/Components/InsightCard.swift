import SwiftUI

/// A SwiftUI view that displays a card representing a habit insight.
/// This view is designed to visually represent different types of habit insights with appropriate colors, icons, and priority badges.
/// 
/// It adapts its layout and styling based on the specific characteristics of the insight being displayed.
/// 
/// # Properties
///  - `insight`: The `HabitInsight` object containing details about the insight to be displayed.
/// 
/// # View Components
///  - `cardHeader`: A horizontal stack containing the icon, title, type label, and priority badge.
///  - `iconView`: A circular icon representing the type of insight.
///  - `priorityBadge`: A badge indicating the priority level of the insight.
///  - `cardBackground`: A styled background for the card with rounded corners and a border that reflects the insight type.
/// 
/// - SeeAlso: `HabitInsight`, `HabitInsightType`, `InsightPriority`
struct InsightCard: View {
    let insight: HabitInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader
            
            Text(insight.description)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(16)
        .shadow(color: insight.type.color.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private var cardHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            iconView
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(insight.type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(insight.type.color)
            }
            
            Spacer()
            
            priorityBadge
        }
    }
    
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(insight.type.color.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Image(systemName: insight.type.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(insight.type.color)
        }
    }
    
    private var priorityBadge: some View {
        Text(insight.priority.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(insight.priority.color.opacity(0.2))
            .foregroundColor(insight.priority.color)
            .cornerRadius(8)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(insight.type.color.opacity(0.3), lineWidth: 1)
            )
    }
}