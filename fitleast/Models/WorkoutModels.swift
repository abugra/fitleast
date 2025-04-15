import Foundation
import SwiftUI

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

struct WorkoutHistoryEntry: Identifiable, Codable {
    var id = UUID()
    var workoutName: String
    var day: Int
    var date: Date
    var exercisesCompleted: Int
    var totalExercises: Int
}

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var workoutHistory: [WorkoutHistoryEntry] = []
    @Published var currentStreak: Int = 0
    @Published var showStreakGained: Bool = false
    @Published var showTabBar: Bool = true
    
    private let saveKey = "WorkoutData"
    private let historyKey = "WorkoutHistory"
    private let streakKey = "CurrentStreak"
    
    init() {
        loadWorkouts()
        loadWorkoutHistory()
        loadStreak()
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
    
    func saveWorkoutHistory() {
        if let encoded = try? JSONEncoder().encode(workoutHistory) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    func loadWorkoutHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([WorkoutHistoryEntry].self, from: data) {
            workoutHistory = decoded
        }
    }
    
    func saveStreak() {
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
    }
    
    func loadStreak() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
    }
    
    func hideTabBar() {
        DispatchQueue.main.async {
            print("Hiding tab bar")
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showTabBar = false
            }
        }
    }
    
    func displayTabBar() {
        DispatchQueue.main.async {
            print("Showing tab bar")
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showTabBar = true
            }
        }
    }
    
    func increaseStreak() {
        currentStreak += 1
        showStreakGained = true
        saveStreak()
        
        // Reset the streak notification after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showStreakGained = false
        }
    }
    
    func toggleExerciseCompletion(workoutId: UUID, exerciseId: UUID) -> Bool {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }),
           let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exerciseId }) {
            
            workouts[workoutIndex].exercises[exerciseIndex].isCompleted.toggle()
            
            // Check if all exercises are completed to mark workout as completed
            let allExercisesCompleted = workouts[workoutIndex].exercises.allSatisfy { $0.isCompleted }
            let wasCompletedBefore = workouts[workoutIndex].isCompleted
            workouts[workoutIndex].isCompleted = allExercisesCompleted
            
            // If just completed (wasn't completed before but now is)
            let justCompleted = !wasCompletedBefore && allExercisesCompleted
            
            if justCompleted {
                increaseStreak()
                
                // Add to workout history
                let completedCount = workouts[workoutIndex].exercises.filter { $0.isCompleted }.count
                let historyEntry = WorkoutHistoryEntry(
                    workoutName: workouts[workoutIndex].name,
                    day: workouts[workoutIndex].day,
                    date: Date(),
                    exercisesCompleted: completedCount,
                    totalExercises: workouts[workoutIndex].exercises.count
                )
                workoutHistory.insert(historyEntry, at: 0) // Add to beginning of array
                saveWorkoutHistory()
            }
            
            saveWorkouts()
            return justCompleted
        }
        return false
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
    
    func clearWorkoutHistory() {
        workoutHistory.removeAll()
        saveWorkoutHistory()
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