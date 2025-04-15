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
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Workouts", systemImage: "dumbbell.fill")
            }
            
            NavigationStack {
                WorkoutHistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
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
        .toolbar(workoutManager.showTabBar ? .visible : .hidden, for: .tabBar)
        .onChange(of: workoutManager.showTabBar) { _, newValue in
            print("Tab bar visibility changed to: \(newValue)")
        }
        .environmentObject(workoutManager)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
