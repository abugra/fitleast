import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingTimer = false
    var workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                
                exercisesList
                
                TimerView()
                    .padding(.top, 20)
                
                resetButton
            }
            .padding()
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.edgesIgnoringSafeArea(.all))
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
                    workoutManager.toggleExerciseCompletion(workoutId: workout.id, exerciseId: exercise.id)
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