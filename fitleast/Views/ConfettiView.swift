import SwiftUI

struct ConfettiView: View {
    @Binding var isShowing: Bool
    let duration: Double
    
    @State private var particles = [Particle]()
    @State private var timer: Timer?
    
    init(isShowing: Binding<Bool>, duration: Double = 3.0) {
        self._isShowing = isShowing
        self.duration = duration
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiParticle(particle: particle)
            }
        }
        .onChange(of: isShowing) { _, newValue in
            if newValue {
                startConfetti()
                
                // Hide confetti after duration
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isShowing = false
                    }
                }
            } else {
                stopConfetti()
            }
        }
    }
    
    private func startConfetti() {
        let colors: [Color] = [.red, .green, .blue, .yellow, .pink, .purple, .orange]
        let shapes = ["circle.fill", "square.fill", "triangle.fill", "star.fill", "heart.fill"]
        
        particles = (0..<100).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -50
                ),
                color: colors.randomElement() ?? .red,
                shape: shapes.randomElement() ?? "circle.fill",
                size: CGFloat.random(in: 5...15),
                rotation: Double.random(in: 0...360),
                speed: CGFloat.random(in: 150...700)
            )
        }
        
        // Update particles
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            for i in 0..<particles.count {
                if i < particles.count {
                    particles[i].position.y += particles[i].speed * 0.01
                    particles[i].rotation += Double.random(in: 0.5...5)
                    
                    // Apply some "wiggle" to horizontal movement
                    if Bool.random() {
                        particles[i].position.x += CGFloat.random(in: -2...2)
                    }
                }
            }
            
            // Remove particles that have fallen off screen
            particles = particles.filter { $0.position.y < UIScreen.main.bounds.height + 100 }
            
            // If all particles are gone, stop the timer
            if particles.isEmpty {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    private func stopConfetti() {
        timer?.invalidate()
        timer = nil
        particles = []
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let shape: String
    let size: CGFloat
    var rotation: Double
    let speed: CGFloat
}

struct ConfettiParticle: View {
    let particle: Particle
    
    var body: some View {
        Image(systemName: particle.shape)
            .foregroundColor(particle.color)
            .font(.system(size: particle.size))
            .position(particle.position)
            .rotationEffect(.degrees(particle.rotation))
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        ConfettiView(isShowing: .constant(true))
    }
} 