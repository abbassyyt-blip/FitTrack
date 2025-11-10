package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/hadiabbas/fittrack-backend/internal/models"
	"github.com/hadiabbas/fittrack-backend/pkg/database"
	"github.com/hadiabbas/fittrack-backend/pkg/utils"
)

type AuthHandler struct {
	DB *database.SupabaseClient
}

func NewAuthHandler(db *database.SupabaseClient) *AuthHandler {
	return &AuthHandler{DB: db}
}

// Register creates a new user account
func (h *AuthHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Create user with Supabase Auth
	authResp, err := h.DB.AuthSignUp(req.Email, req.Password)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to create account: " + err.Error()})
		return
	}

	// Parse response
	var authData map[string]interface{}
	if err := json.Unmarshal(authResp, &authData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse auth response"})
		return
	}

	// Extract user data
	userData, ok := authData["user"].(map[string]interface{})
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid auth response"})
		return
	}

	userID := userData["id"].(string)
	email := userData["email"].(string)

	// Generate JWT token
	token, err := utils.GenerateJWT(userID, email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	// Return response
	user := models.User{
		ID:    userID,
		Email: email,
	}

	c.JSON(http.StatusCreated, models.AuthResponse{
		Token: token,
		User:  user,
	})
}

// Login authenticates a user
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Sign in with Supabase Auth
	authResp, err := h.DB.AuthSignIn(req.Email, req.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// Parse response
	var authData map[string]interface{}
	if err := json.Unmarshal(authResp, &authData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse auth response"})
		return
	}

	// Extract user data
	userData, ok := authData["user"].(map[string]interface{})
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid auth response"})
		return
	}

	userID := userData["id"].(string)
	email := userData["email"].(string)

	// Generate JWT token
	token, err := utils.GenerateJWT(userID, email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	// Return response
	user := models.User{
		ID:    userID,
		Email: email,
	}

	c.JSON(http.StatusOK, models.AuthResponse{
		Token: token,
		User:  user,
	})
}

