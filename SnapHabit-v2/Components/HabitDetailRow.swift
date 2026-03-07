import SwiftUI


/// A Reusable Component View that displays a single row of habit detail information.
/// 
/// This view is used to present a title, with an optional color badge indicating the status of the habit.
/// 
/// - Parameters:
///   - title: The title of the habit.
///   - value: The value associated with the title (e.g., "5 days", "80%").
///   - color: A `Color` used to indicate the status of the habit. If the color is `.clear`, no badge is shown.
///
struct HabitDetailRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            if color != .clear {
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.8))
                    .cornerRadius(8)
            } else {
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
