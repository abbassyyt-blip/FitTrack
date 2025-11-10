//
//  Workout.swift
//  FitTrack Code
//
//  Created by Hadi Abbas on 11/9/25.
//

import Foundation
import SwiftData

enum ActivityType: String, Codable {
    case strength
    case cardio
}

@Model
final class Workout: Identifiable {
    var id: UUID
    var workoutName: String
    var workoutDate: Date
    var durationHours: Int
    var durationMinutes: Int
    var overallRPE: Double
    var estimatedCalories: Int
    var activityType: ActivityType?
    @Relationship(deleteRule: .cascade) var exercises: [WorkoutExercise]
    
    init(workoutName: String, workoutDate: Date, durationHours: Int, durationMinutes: Int, overallRPE: Double, estimatedCalories: Int = 0, activityType: ActivityType? = nil, exercises: [WorkoutExercise] = []) {
        self.id = UUID()
        self.workoutName = workoutName
        self.workoutDate = workoutDate
        self.durationHours = durationHours
        self.durationMinutes = durationMinutes
        self.overallRPE = overallRPE
        self.estimatedCalories = estimatedCalories
        self.activityType = activityType
        self.exercises = exercises
    }
    
    var totalDurationMinutes: Int {
        return durationHours * 60 + durationMinutes
    }
    
    // Calculate estimated calories based on duration and RPE
    // Base formula: calories = (duration_minutes / 60) * (base_rate + rpe_multiplier * RPE) * 100
    // Simplified: ~5-15 calories per minute depending on RPE
    static func calculateEstimatedCalories(durationMinutes: Int, rpe: Double) -> Int {
        let baseCaloriesPerMinute = 5.0
        let rpeMultiplier = 1.0
        let caloriesPerMinute = baseCaloriesPerMinute + (rpeMultiplier * rpe)
        return Int(Double(durationMinutes) * caloriesPerMinute)
    }
}

@Model
final class WorkoutExercise: Identifiable {
    var id: UUID
    var name: String
    var notes: String
    var order: Int = 0
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet]
    
    init(name: String, notes: String, order: Int = 0, sets: [WorkoutSet] = []) {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.order = order
        self.sets = sets
    }
}

@Model
final class WorkoutSet: Identifiable {
    var id: UUID
    var weight: String
    var reps: String
    var rpe: Double?
    
    init(weight: String, reps: String, rpe: Double? = nil) {
        self.id = UUID()
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
    }
}

