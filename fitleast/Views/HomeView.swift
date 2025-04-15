import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingAddWorkout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        headerView
                        
                        workoutListView
                    }
                    .padding()
                }
            }
            .navigationTitle("FitLeast")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddWorkout = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                Text("Add Workout Feature Coming Soon")
                    .font(.system(.title3, design: .rounded))
                    .padding()
                    .presentationDetents([.medium])
            }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Current Streak")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .bottom, spacing: 2) {
                        Text("\(workoutManager.currentStreak)")
                            .font(.system(.largeTitle, design: .rounded).weight(.black))
                            .foregroundColor(.white)
                        
                        Text("days")
                            .font(.system(.title3, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(20)
        }
    }
    
    private var workoutListView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Workouts")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(.white)
            
            ForEach(workoutManager.workouts) { workout in
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    workoutCard(workout)
                }
            }
        }
    }
    
    private func workoutCard(_ workout: Workout) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(workout.name)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                
                Text("Day \(workout.day) · \(workout.exercises.count) exercises")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 8)
                            .opacity(0.2)
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .frame(width: min(CGFloat(completedExercises(in: workout)) / CGFloat(workout.exercises.count) * geometry.size.width, geometry.size.width), height: 8)
                            .foregroundColor(progressColor(for: workout))
                    }
                    .cornerRadius(4)
                }
                .frame(height: 8)
                .padding(.top, 4)
            }
            
            Spacer()
            
            if workout.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
    
    private func completedExercises(in workout: Workout) -> Int {
        workout.exercises.filter { $0.isCompleted }.count
    }
    
    private func progressColor(for workout: Workout) -> Color {
        let progress = Double(completedExercises(in: workout)) / Double(workout.exercises.count)
        
        if progress == 1 {
            return .green
        } else if progress > 0.5 {
            return .yellow
        } else {
            return .blue
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(WorkoutManager())
} 