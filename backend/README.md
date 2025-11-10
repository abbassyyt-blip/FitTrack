# FitTrack Backend Server

This is the Go backend server for FitTrack. It handles authentication, data storage, and AI integration.

## Setup Instructions

### 1. Environment Variables
Create a `.env` file in the backend directory with these variables:

```
SUPABASE_URL=your_supabase_project_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_KEY=your_supabase_service_role_key_here
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
PORT=8080
ENVIRONMENT=development
OPENAI_API_KEY=your_openai_api_key_here
```

### 2. Install Dependencies
```bash
cd backend
go mod download
```

### 3. Run Server
```bash
go run cmd/api/main.go
```

The server will start on http://localhost:8080

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Create new account
- `POST /api/v1/auth/login` - Login to account

### Workouts (Protected - requires authentication)
- `POST /api/v1/workouts` - Create workout
- `GET /api/v1/workouts` - Get all user workouts
- `GET /api/v1/workouts/:id` - Get specific workout
- `DELETE /api/v1/workouts/:id` - Delete workout

### Food Logging (Protected)
- `POST /api/v1/food/parse-text` - Parse food from text
- `POST /api/v1/food/parse-image` - Parse food from image
- `GET /api/v1/food/logs` - Get food logs

### Dashboard (Protected)
- `GET /api/v1/dashboard` - Get dashboard data with insights

