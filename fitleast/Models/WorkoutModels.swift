import Foundation

struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sets: Int
    var reps: String
    var isCompleted: Bool = false
}

struct Workout: Identifiable, Codable {
    var id = UUID()
    var name: String
    var day: Int
    var exercises: [Exercise]
    var isCompleted: Bool = false
}

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var currentStreak: Int = 0
    
    private let saveKey = "WorkoutData"
    
    init() {
        loadWorkouts()
        if workouts.isEmpty {
            setupDefaultWorkouts()
        }
    }
    
    func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func loadWorkouts() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            workouts = decoded
        }
    }
    
    func updateStreak() {
        // Simple streak implementation - increases if any workout is completed today
        let completedWorkouts = workouts.filter { $0.isCompleted }
        if !completedWorkouts.isEmpty {
            currentStreak += 1
        } else {
            // Reset streak if no workouts completed today
            // In a real app, you'd check dates to maintain streak for days
            currentStreak = 0
        }
    }
    
    func toggleExerciseCompletion(workoutId: UUID, exerciseId: UUID) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }),
           let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exerciseId }) {
            
            workouts[workoutIndex].exercises[exerciseIndex].isCompleted.toggle()
            
            // Check if all exercises are completed to mark workout as completed
            let allExercisesCompleted = workouts[workoutIndex].exercises.allSatisfy { $0.isCompleted }
            workouts[workoutIndex].isCompleted = allExercisesCompleted
            
            if allExercisesCompleted {
                updateStreak()
            }
            
            saveWorkouts()
        }
    }
    
    func resetWorkout(workoutId: UUID) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }) {
            for i in 0..<workouts[workoutIndex].exercises.count {
                workouts[workoutIndex].exercises[i].isCompleted = false
            }
            workouts[workoutIndex].isCompleted = false
            saveWorkouts()
        }
    }
    
    private func setupDefaultWorkouts() {
        workouts = [
            Workout(
                name: "Chest - Triceps - Cardio",
                day: 1,
                exercises: [
                    Exercise(name: "Bench Press", sets: 3, reps: "8-10"),
                    Exercise(name: "Incline Bench Press", sets: 3, reps: "10"),
                    Exercise(name: "Triceps Pushdown", sets: 3, reps: "12"),
                    Exercise(name: "Dumbbell Kickback", sets: 2, reps: "12"),
                    Exercise(name: "Treadmill Walk/Jog", sets: 1, reps: "10-15 min")
                ]
            ),
            Workout(
                name: "Back - Biceps - Abs",
                day: 2,
                exercises: [
                    Exercise(name: "Lat Pulldown", sets: 3, reps: "10"),
                    Exercise(name: "Seated Row", sets: 3, reps: "10"),
                    Exercise(name: "Barbell Curl", sets: 3, reps: "12"),
                    Exercise(name: "Dumbbell Hammer Curl", sets: 2, reps: "10"),
                    Exercise(name: "Plank", sets: 2, reps: "1 min"),
                    Exercise(name: "Russian Twist", sets: 2, reps: "20")
                ]
            ),
            Workout(
                name: "Legs - Shoulders - Cardio",
                day: 3,
                exercises: [
                    Exercise(name: "Squat", sets: 3, reps: "12"),
                    Exercise(name: "Leg Press", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Shoulder Press", sets: 3, reps: "10"),
                    Exercise(name: "Lateral Raise", sets: 2, reps: "12"),
                    Exercise(name: "Elliptical / Walking", sets: 1, reps: "10-15 min")
                ]
            )
        ]
        saveWorkouts()
    }
} 