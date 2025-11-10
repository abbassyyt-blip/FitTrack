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
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [Workout.self, WorkoutExercise.self, WorkoutSet.self])
    }
}
