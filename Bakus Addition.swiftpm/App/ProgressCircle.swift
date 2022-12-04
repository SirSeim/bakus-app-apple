import SwiftUI

struct ProgressCircle: View {
    @State var progress: Double
    @State var color = Color.blue
    @State var showBig = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4.0)
                .opacity(0.3)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 4.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            if showBig {
                Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                    .font(.largeTitle)
                    .bold()
            }
        }
    }
}

struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressCircle(progress: 0.285, showBig: true)
        }
    }
}
