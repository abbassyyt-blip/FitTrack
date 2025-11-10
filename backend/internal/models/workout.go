package models

import (
	"time"
)

// Workout represents a workout session
type Workout struct {
	ID                string            `json:"id"`
	UserID            string            `json:"user_id"`
	WorkoutName       string            `json:"workout_name"`
	WorkoutDate       time.Time         `json:"workout_date"`
	DurationHours     int               `json:"duration_hours"`
	DurationMinutes   int               `json:"duration_minutes"`
	OverallRPE        float64           `json:"overall_rpe"`
	EstimatedCalories int               `json:"estimated_calories"`
	ActivityType      string            `json:"activity_type"` // "strength" or "cardio"
	Exercises         []WorkoutExercise `json:"exercises"`
	CreatedAt         time.Time         `json:"created_at"`
	UpdatedAt         time.Time         `json:"updated_at"`
}

// WorkoutExercise represents an exercise within a workout
type WorkoutExercise struct {
	ID        string       `json:"id"`
	WorkoutID string       `json:"workout_id"`
	Name      string       `json:"name"`
	Notes     string       `json:"notes"`
	Order     int          `json:"order"`
	Sets      []WorkoutSet `json:"sets"`
}

// WorkoutSet represents a single set of an exercise
type WorkoutSet struct {
	ID         string   `json:"id"`
	ExerciseID string   `json:"exercise_id"`
	Weight     string   `json:"weight"`
	Reps       string   `json:"reps"`
	RPE        *float64 `json:"rpe,omitempty"` // Optional RPE for individual sets
}

// CreateWorkoutRequest represents the request to create a workout
type CreateWorkoutRequest struct {
	WorkoutName       string            `json:"workout_name" binding:"required"`
	WorkoutDate       time.Time         `json:"workout_date" binding:"required"`
	DurationHours     int               `json:"duration_hours"`
	DurationMinutes   int               `json:"duration_minutes" binding:"required"`
	OverallRPE        float64           `json:"overall_rpe" binding:"required,min=1,max=10"`
	EstimatedCalories int               `json:"estimated_calories"`
	ActivityType      string            `json:"activity_type" binding:"required,oneof=strength cardio"`
	Exercises         []WorkoutExercise `json:"exercises"`
}

