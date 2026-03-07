import SwiftUI

// MARK: - Custom Layout for Logo with Text Overlay
// This layout places text centered on top of a circular background
struct LogoTextLayout: Layout {
    
    // MARK: - Size Calculation
    // Calculate how much space this layout needs
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let circle = subviews.first else { return .zero }
        let circleSize = circle.sizeThatFits(proposal)
        return circleSize
    }

    // MARK: - View Positioning
    // Position the circle and text views within the layout bounds
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // Make sure we have exactly 2 views (circle and text)
        guard subviews.count == 2 else { return }
        let circle = subviews[0]
        let text = subviews[1]

        // Centers the circle in the available space
        let circleSize = circle.sizeThatFits(proposal)
        let circleOrigin = CGPoint(
            x: bounds.midX - circleSize.width / 2,
            y: bounds.midY - circleSize.height / 2
        )
        circle.place(at: circleOrigin, proposal: ProposedViewSize(circleSize))

        // Centers the text over the circle
        let textSize = text.sizeThatFits(proposal)
        let textOrigin = CGPoint(
            x: bounds.midX - textSize.width / 2,
            y: bounds.midY - textSize.height / 2
        )
        text.place(at: textOrigin, proposal: ProposedViewSize(textSize))
    }
}
