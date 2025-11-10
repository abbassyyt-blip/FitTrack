//
//  FitTrack_CodeApp.swift
//  FitTrack Code
//
//  Created by Hadi Abbas on 11/9/25.
//

import SwiftUI
import SwiftData

@main
struct FitTrack_CodeApp: App {
    @StateObject private var networkManager = NetworkManager.shared
    
    var body: some Scene {
        WindowGroup {
            if networkManager.isAuthenticated {
                MainView()
                    .environmentObject(networkManager)
            } else {
                AuthView()
                    .environmentObject(networkManager)
            }
        }
        .modelContainer(for: [Workout.self, WorkoutExercise.self, WorkoutSet.self])
    }
}
