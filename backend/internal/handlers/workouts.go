package handlers

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/hadiabbas/fittrack-backend/internal/models"
	"github.com/hadiabbas/fittrack-backend/pkg/database"
)

type WorkoutHandler struct {
	DB *database.SupabaseClient
}

func NewWorkoutHandler(db *database.SupabaseClient) *WorkoutHandler {
	return &WorkoutHandler{DB: db}
}

// CreateWorkout creates a new workout
func (h *WorkoutHandler) CreateWorkout(c *gin.Context) {
	userID, _ := c.Get("user_id")
	
	var req models.CreateWorkoutRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Generate workout ID
	workoutID := uuid.New().String()

	// Create workout data for database
	workoutData := map[string]interface{}{
		"id":                 workoutID,
		"user_id":            userID,
		"workout_name":       req.WorkoutName,
		"workout_date":       req.WorkoutDate,
		"duration_hours":     req.DurationHours,
		"duration_minutes":   req.DurationMinutes,
		"overall_rpe":        req.OverallRPE,
		"estimated_calories": req.EstimatedCalories,
		"activity_type":      req.ActivityType,
		"created_at":         time.Now(),
		"updated_at":         time.Now(),
	}

	// Insert workout
	_, err := h.DB.Insert("workout_sessions", workoutData, false)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create workout: " + err.Error()})
		return
	}

	// Insert exercises and sets
	for i, exercise := range req.Exercises {
		exerciseID := uuid.New().String()
		exerciseData := map[string]interface{}{
			"id":         exerciseID,
			"workout_id": workoutID,
			"name":       exercise.Name,
			"notes":      exercise.Notes,
			"order":      i,
		}

		_, err := h.DB.Insert("workout_exercises", exerciseData, false)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create exercise: " + err.Error()})
			return
		}

		// Insert sets for this exercise
		for _, set := range exercise.Sets {
			setID := uuid.New().String()
			setData := map[string]interface{}{
				"id":          setID,
				"exercise_id": exerciseID,
				"weight":      set.Weight,
				"reps":        set.Reps,
				"rpe":         set.RPE,
			}

			_, err := h.DB.Insert("workout_sets", setData, false)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create set: " + err.Error()})
				return
			}
		}
	}

	c.JSON(http.StatusCreated, gin.H{
		"id":      workoutID,
		"message": "Workout created successfully",
	})
}

// GetWorkouts retrieves all workouts for a user
func (h *WorkoutHandler) GetWorkouts(c *gin.Context) {
	userID, _ := c.Get("user_id")

	// Query workouts
	query := map[string]interface{}{
		"user_id": userID,
	}

	workoutsData, err := h.DB.Query("workout_sessions", query, false)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch workouts: " + err.Error()})
		return
	}

	// Parse workouts
	var workouts []models.Workout
	if err := json.Unmarshal(workoutsData, &workouts); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse workouts"})
		return
	}

	// Fetch exercises for each workout
	for i := range workouts {
		exerciseQuery := map[string]interface{}{
			"workout_id": workouts[i].ID,
		}

		exercisesData, err := h.DB.Query("workout_exercises", exerciseQuery, false)
		if err != nil {
			continue
		}

		var exercises []models.WorkoutExercise
		if err := json.Unmarshal(exercisesData, &exercises); err != nil {
			continue
		}

		// Fetch sets for each exercise
		for j := range exercises {
			setQuery := map[string]interface{}{
				"exercise_id": exercises[j].ID,
			}

			setsData, err := h.DB.Query("workout_sets", setQuery, false)
			if err != nil {
				continue
			}

			var sets []models.WorkoutSet
			if err := json.Unmarshal(setsData, &sets); err != nil {
				continue
			}

			exercises[j].Sets = sets
		}

		workouts[i].Exercises = exercises
	}

	c.JSON(http.StatusOK, workouts)
}

// GetWorkout retrieves a specific workout
func (h *WorkoutHandler) GetWorkout(c *gin.Context) {
	userID, _ := c.Get("user_id")
	workoutID := c.Param("id")

	// Query specific workout
	query := map[string]interface{}{
		"id":      workoutID,
		"user_id": userID,
	}

	workoutData, err := h.DB.Query("workout_sessions", query, false)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch workout: " + err.Error()})
		return
	}

	var workouts []models.Workout
	if err := json.Unmarshal(workoutData, &workouts); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse workout"})
		return
	}

	if len(workouts) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Workout not found"})
		return
	}

	workout := workouts[0]

	// Fetch exercises
	exerciseQuery := map[string]interface{}{
		"workout_id": workout.ID,
	}

	exercisesData, err := h.DB.Query("workout_exercises", exerciseQuery, false)
	if err == nil {
		var exercises []models.WorkoutExercise
		if err := json.Unmarshal(exercisesData, &exercises); err == nil {
			// Fetch sets for each exercise
			for j := range exercises {
				setQuery := map[string]interface{}{
					"exercise_id": exercises[j].ID,
				}

				setsData, err := h.DB.Query("workout_sets", setQuery, false)
				if err == nil {
					var sets []models.WorkoutSet
					if err := json.Unmarshal(setsData, &sets); err == nil {
						exercises[j].Sets = sets
					}
				}
			}
			workout.Exercises = exercises
		}
	}

	c.JSON(http.StatusOK, workout)
}

// DeleteWorkout deletes a workout
func (h *WorkoutHandler) DeleteWorkout(c *gin.Context) {
	userID, _ := c.Get("user_id")
	workoutID := c.Param("id")

	// First verify the workout belongs to this user
	query := map[string]interface{}{
		"id":      workoutID,
		"user_id": userID,
	}

	workoutData, err := h.DB.Query("workout_sessions", query, false)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify workout"})
		return
	}

	var workouts []models.Workout
	if err := json.Unmarshal(workoutData, &workouts); err != nil || len(workouts) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Workout not found"})
		return
	}

	// Delete exercises and sets (cascade will handle this in Supabase with proper FK setup)
	// For now, manually delete them
	exerciseQuery := map[string]interface{}{
		"workout_id": workoutID,
	}

	exercisesData, _ := h.DB.Query("workout_exercises", exerciseQuery, false)
	var exercises []models.WorkoutExercise
	if json.Unmarshal(exercisesData, &exercises) == nil {
		for _, exercise := range exercises {
			// Delete sets
			setQuery := map[string]interface{}{
				"exercise_id": exercise.ID,
			}
			setsData, _ := h.DB.Query("workout_sets", setQuery, false)
			var sets []models.WorkoutSet
			if json.Unmarshal(setsData, &sets) == nil {
				for _, set := range sets {
					h.DB.Delete("workout_sets", set.ID, false)
				}
			}
			// Delete exercise
			h.DB.Delete("workout_exercises", exercise.ID, false)
		}
	}

	// Delete workout
	err = h.DB.Delete("workout_sessions", workoutID, false)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete workout"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Workout deleted successfully"})
}

