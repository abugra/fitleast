import SwiftUI
#if os(iOS)
import UIKit
#endif

struct TimerView: View {
    @State private var timeRemaining: Int = 60
    @State private var timer: Timer? = nil
    @State private var isRunning: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(timeString(from: timeRemaining))")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .monospacedDigit()
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                Button(action: {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .background(isRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                
                Button(action: resetTimer) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            
            HStack(spacing: 20) {
                Button("30s") { setTimer(seconds: 30) }
                    .buttonStyle(TimerButtonStyle())
                
                Button("60s") { setTimer(seconds: 60) }
                    .buttonStyle(TimerButtonStyle())
                
                Button("90s") { setTimer(seconds: 90) }
                    .buttonStyle(TimerButtonStyle())
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
    
    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                // Haptic feedback when timer completes
                #if os(iOS)
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                #endif
            }
        }
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        timeRemaining = 60
    }
    
    private func setTimer(seconds: Int) {
        stopTimer()
        timeRemaining = seconds
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct TimerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded).weight(.bold))
            .foregroundColor(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(Color.purple.opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        TimerView()
    }
} 