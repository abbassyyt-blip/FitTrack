package models

import (
	"time"
)

// FoodLog represents a logged food entry
type FoodLog struct {
	ID              string    `json:"id"`
	UserID          string    `json:"user_id"`
	LogDate         time.Time `json:"log_date"`
	MealType        string    `json:"meal_type"` // "breakfast", "lunch", "dinner", "snack"
	SourceText      string    `json:"source_text"`
	CaloriesEst     int       `json:"calories_estimated"`
	ProteinG        *float64  `json:"protein_g,omitempty"`
	FatG            *float64  `json:"fat_g,omitempty"`
	CarbsG          *float64  `json:"carbs_g,omitempty"`
	AIConfidence    float64   `json:"ai_confidence_score"`
	CreatedAt       time.Time `json:"created_at"`
}

// ParseTextRequest represents a request to parse food from text
type ParseTextRequest struct {
	Query    string `json:"query" binding:"required"`
	MealType string `json:"meal_type" binding:"required,oneof=breakfast lunch dinner snack"`
}

// ParseImageRequest represents a request to parse food from an image
type ParseImageRequest struct {
	ImageBase64 string `json:"image_base64" binding:"required"`
	MealType    string `json:"meal_type" binding:"required,oneof=breakfast lunch dinner snack"`
}

// NutritionInfo represents the parsed nutrition information
type NutritionInfo struct {
	Calories   int     `json:"calories"`
	Protein    float64 `json:"protein"`
	Fat        float64 `json:"fat"`
	Carbs      float64 `json:"carbs"`
	Confidence float64 `json:"confidence"`
}

