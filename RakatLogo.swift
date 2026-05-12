import SwiftUI

struct RakatLogo: View {
    var color: Color = .white

    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height
            let sw = w * 0.17  // stroke width

            // Stem
            var stem = Path()
            stem.addRoundedRect(
                in: CGRect(x: 0, y: 0, width: sw, height: h),
                cornerSize: CGSize(width: sw / 2, height: sw / 2)
            )
            ctx.fill(stem, with: .color(color))

            // Bowl (upper half D shape)
            let bowlTop    = CGFloat(0)
            let bowlMid    = h * 0.48
            let bowlRight  = w * 0.9
            let bowlCenter = w * 0.52

            var bowl = Path()
            bowl.move(to: CGPoint(x: sw * 0.5, y: bowlTop + sw * 0.5))
            bowl.addLine(to: CGPoint(x: bowlCenter, y: bowlTop + sw * 0.5))
            bowl.addCurve(
                to: CGPoint(x: bowlCenter, y: bowlMid - sw * 0.5),
                control1: CGPoint(x: bowlRight + sw, y: bowlTop + sw * 0.5),
                control2: CGPoint(x: bowlRight + sw, y: bowlMid - sw * 0.5)
            )
            bowl.addLine(to: CGPoint(x: sw * 0.5, y: bowlMid - sw * 0.5))

            ctx.stroke(
                bowl,
                with: .color(color),
                style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round)
            )

            // Diagonal leg — from mid-right, kicks to bottom-right
            let legStartX = bowlCenter
            let legStartY = bowlMid + 2
            let legEndX   = w
            let legEndY   = h

            var leg = Path()
            leg.move(to: CGPoint(x: legStartX, y: legStartY))
            leg.addLine(to: CGPoint(x: legEndX, y: legEndY))

            ctx.stroke(
                leg,
                with: .color(color),
                style: StrokeStyle(lineWidth: sw, lineCap: .round)
            )
        }
    }
}

#Preview {
    ZStack {
        Color.black
        RakatLogo(color: .white)
            .frame(width: 60, height: 74)
    }
}
