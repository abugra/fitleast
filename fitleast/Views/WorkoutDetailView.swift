import SwiftUI
#if os(iOS)
import UIKit
#endif

struct WorkoutDetailView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = false
    @State private var showStreakMessage = false
    @State private var showPlayer = false
    var workout: Workout
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerView
                    exercisesList
                    Spacer(minLength: 100) // Space for player at bottom
                }
                .padding()
            }
            .navigationTitle(workout.name)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                // Hide tab bar when detail view appears
                workoutManager.hideTabBar()
                
                // Show player with animation after 1 second
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showPlayer = true
                    }
                }
            }
            
            // Fixed workout player at bottom
            VStack(spacing: 0) {
                Spacer()
                WorkoutPlayerView()
                    .offset(y: showPlayer ? 0 : 200) // Slide up from below
            }
            .ignoresSafeArea(edges: .bottom)
            
            // Confetti overlay
            ConfettiView(isShowing: $showConfetti)
                .allowsHitTesting(false)
            
            // Streak message overlay
            if showStreakMessage {
                VStack {
                    Text("Workout Completed!")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundColor(.white)
                    
                    Text("+1 Streak")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(.green)
                        .padding(.top, 5)
                    
                    Button(action: {
                        withAnimation {
                            showStreakMessage = false
                            workoutManager.resetWorkout(workoutId: workout.id)
                        }
                    }) {
                        Text("Great Job! Clear Workout")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding(.top, 20)
                }
                .padding(30)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            // Ensure tab bar returns when leaving this view
            if !showStreakMessage {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    workoutManager.displayTabBar()
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Day \(workout.day)")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(.white)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("\(completedExercises) of \(workout.exercises.count) exercises completed")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    
    private var exercisesList: some View {
        VStack(spacing: 15) {
            ForEach(workout.exercises) { exercise in
                exerciseRow(exercise)
            }
        }
    }
    
    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                
                Text("\(exercise.sets) sets × \(exercise.reps)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    let justCompleted = workoutManager.toggleExerciseCompletion(workoutId: workout.id, exerciseId: exercise.id)
                    
                    if justCompleted {
                        // Show celebration
                        showConfetti = true
                        showStreakMessage = true
                        
                        // Add haptic feedback
                        #if os(iOS)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        #endif
                    }
                }
            }) {
                Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(exercise.isCompleted ? .green : .gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
    
    private var resetButton: some View {
        Button(action: {
            withAnimation {
                workoutManager.resetWorkout(workoutId: workout.id)
            }
        }) {
            Text("Reset Workout")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(15)
        }
        .padding(.vertical)
    }
    
    private var progress: Double {
        guard !workout.exercises.isEmpty else { return 0 }
        return Double(completedExercises) / Double(workout.exercises.count)
    }
    
    private var progressColor: Color {
        if progress == 1 {
            return .green
        } else if progress > 0.5 {
            return .yellow
        } else {
            return .blue
        }
    }
    
    private var completedExercises: Int {
        workout.exercises.filter { $0.isCompleted }.count
    }
}

#Preview {
    NavigationView {
        WorkoutDetailView(workout: Workout(
            name: "Chest - Triceps - Cardio",
            day: 1,
            exercises: [
                Exercise(name: "Bench Press", sets: 3, reps: "8-10"),
                Exercise(name: "Incline Bench Press", sets: 3, reps: "10"),
                Exercise(name: "Triceps Pushdown", sets: 3, reps: "12")
            ]
        ))
        .environmentObject(WorkoutManager())
    }
    .preferredColorScheme(.dark)
} 