import SwiftUI

struct ProgressCircle: View {
    @State var progress: Double
    @State var state: AdditionState
    @State var showBig = false
    
    var body: some View {
        if state == .Completed {
            ZStack {
                Circle()
                    .background(Circle())
                    .foregroundColor(.green)
                Image(systemName: "checkmark")
                    .scaleEffect(0.6, anchor: .center)
                    .colorScheme(.dark)
            }
        } else {
            ZStack {
                Circle()
                    .stroke(lineWidth: 4.0)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 4.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.blue)
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
}

struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressCircle(progress: 0.285, state: .Downloading, showBig: true)
            ProgressCircle(progress: 0.9, state: .Completed, showBig: true)
        }
    }
}
