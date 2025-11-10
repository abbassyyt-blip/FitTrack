package main

import (
	"fmt"
	"log"
	"os"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/hadiabbas/fittrack-backend/internal/handlers"
	"github.com/hadiabbas/fittrack-backend/internal/middleware"
	"github.com/hadiabbas/fittrack-backend/pkg/database"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("Warning: .env file not found, using system environment variables")
	}

	// Validate required environment variables
	requiredEnvVars := []string{"SUPABASE_URL", "SUPABASE_ANON_KEY", "JWT_SECRET"}
	for _, envVar := range requiredEnvVars {
		if os.Getenv(envVar) == "" {
			log.Fatalf("Error: %s environment variable is required", envVar)
		}
	}

	// Initialize Supabase client
	db := database.NewSupabaseClient()

	// Initialize Gin router
	if os.Getenv("ENVIRONMENT") == "production" {
		gin.SetMode(gin.ReleaseMode)
	}
	
	router := gin.Default()

	// CORS configuration
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"*"} // In production, set this to your specific domain
	config.AllowHeaders = []string{"Origin", "Content-Type", "Authorization"}
	router.Use(cors.New(config))

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "healthy",
			"service": "fittrack-api",
		})
	})

	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		// Authentication routes (public)
		auth := v1.Group("/auth")
		{
			authHandler := handlers.NewAuthHandler(db)
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
		}

		// Protected routes (require authentication)
		protected := v1.Group("")
		protected.Use(middleware.AuthMiddleware())
		{
			// Workout routes
			workouts := protected.Group("/workouts")
			{
				workoutHandler := handlers.NewWorkoutHandler(db)
				workouts.POST("", workoutHandler.CreateWorkout)
				workouts.GET("", workoutHandler.GetWorkouts)
				workouts.GET("/:id", workoutHandler.GetWorkout)
				workouts.DELETE("/:id", workoutHandler.DeleteWorkout)
			}

			// Food logging routes (to be implemented in Phase 2)
			food := protected.Group("/food")
			{
				food.POST("/parse-text", func(c *gin.Context) {
					c.JSON(200, gin.H{"message": "Food text parsing - Coming in Phase 2"})
				})
				food.POST("/parse-image", func(c *gin.Context) {
					c.JSON(200, gin.H{"message": "Food image parsing - Coming in Phase 2"})
				})
				food.GET("/logs", func(c *gin.Context) {
					c.JSON(200, gin.H{"message": "Food logs - Coming in Phase 2"})
				})
			}

			// Dashboard routes (to be implemented in Phase 3)
			protected.GET("/dashboard", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "Dashboard insights - Coming in Phase 3"})
			})
		}
	}

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("🚀 FitTrack API server starting on port %s\n", port)
	fmt.Println("📊 Endpoints available:")
	fmt.Println("   - POST /api/v1/auth/register")
	fmt.Println("   - POST /api/v1/auth/login")
	fmt.Println("   - POST /api/v1/workouts")
	fmt.Println("   - GET  /api/v1/workouts")
	fmt.Println("   - GET  /api/v1/workouts/:id")
	fmt.Println("   - DELETE /api/v1/workouts/:id")

	if err := router.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

