import SwiftUI

struct WorkoutHistoryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingClearConfirmation = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if workoutManager.workoutHistory.isEmpty {
                emptyHistoryView
            } else {
                historyListView
            }
        }
        .navigationTitle("Past Workouts")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingClearConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .disabled(workoutManager.workoutHistory.isEmpty)
            }
        }
        .alert("Clear History", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                workoutManager.clearWorkoutHistory()
            }
        } message: {
            Text("Are you sure you want to clear your workout history? This cannot be undone.")
        }
        .onAppear {
            print("HistoryView appeared")
            // Use a slight delay to ensure it runs after navigation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                workoutManager.displayTabBar()
            }
        }
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("No Past Workouts")
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundColor(.white)
            
            Text("Complete your first workout to see it here.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(workoutManager.workoutHistory) { entry in
                    workoutHistoryCard(entry)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private func workoutHistoryCard(_ entry: WorkoutHistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.workoutName)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Day \(entry.day)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                
                Text(formattedDate(entry.date))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text("\(entry.exercisesCompleted)/\(entry.totalExercises) completed")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let previewManager = WorkoutManager()
    previewManager.workoutHistory = [
        WorkoutHistoryEntry(
            workoutName: "Chest - Triceps - Cardio",
            day: 1,
            date: Date(),
            exercisesCompleted: 5,
            totalExercises: 5
        ),
        WorkoutHistoryEntry(
            workoutName: "Back - Biceps - Abs",
            day: 2,
            date: Date().addingTimeInterval(-86400),
            exercisesCompleted: 6,
            totalExercises: 6
        )
    ]
    
    return WorkoutHistoryView().environmentObject(previewManager)
} 