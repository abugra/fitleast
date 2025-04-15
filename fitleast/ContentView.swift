//
//  ContentView.swift
//  fitleast
//
//  Created by Ahmet Bugra Avcilar on 15.04.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Workouts", systemImage: "dumbbell.fill")
                }
            
            Text("Stats Coming Soon")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            Text("Settings Coming Soon")
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.white)
        .environmentObject(workoutManager)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
