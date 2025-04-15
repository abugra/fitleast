import SwiftUI
import UIKit

struct WorkoutPlayerView: View {
    @State private var isWorkoutActive = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var startTime: Date?
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar at top of player
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    
                    if isWorkoutActive {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: min(CGFloat(elapsedTime / 3600) * geometry.size.width, geometry.size.width), height: 2)
                            .animation(.linear, value: elapsedTime)
                    }
                }
            }
            .frame(height: 2)
            
            HStack(spacing: 20) {
                // Time display
                VStack(alignment: .leading, spacing: 4) {
                    Text("WORKOUT TIME")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.gray)
                        .fontWeight(.medium)
                    
                    Text(timeString(from: elapsedTime))
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                
                Spacer()
                
                // Play/Pause button
                Button(action: toggleWorkout) {
                    ZStack {
                        Circle()
                            .fill(isWorkoutActive ? Color.red : Color.green)
                            .frame(width: 50, height: 50)
                            .shadow(radius: 3)
                        
                        Image(systemName: isWorkoutActive ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                
                // Reset button
                Button(action: resetWorkout) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .disabled(!isWorkoutActive && elapsedTime == 0)
                .opacity(!isWorkoutActive && elapsedTime == 0 ? 0.5 : 1)
            }
           .padding(EdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16))
        }
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    private func toggleWorkout() {
        isWorkoutActive.toggle()
        
        if isWorkoutActive {
            startWorkout()
        } else {
            pauseWorkout()
        }
        
        // Add haptic feedback
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    private func startWorkout() {
        let now = Date()
        if startTime == nil {
            startTime = now
        } else {
            // Adjust start time to account for paused time
            startTime = now.addingTimeInterval(-elapsedTime)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.updateElapsedTime()
        }
    }
    
    private func pauseWorkout() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetWorkout() {
        pauseWorkout()
        isWorkoutActive = false
        elapsedTime = 0
        startTime = nil
        
        // Add haptic feedback
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        #endif
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 100)
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d.%02d", hours, minutes, seconds, milliseconds)
        } else {
            return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
        }
    }
}

// Extension to create a Color from a hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Extension to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ZStack {
        Color.black
            .edgesIgnoringSafeArea(.all)
        VStack {
            Spacer()
            WorkoutPlayerView()
        }
    }
} 