# FitTrack Backend Setup Guide

This guide will walk you through setting up the FitTrack backend server step-by-step.

## Step 1: Create a Supabase Account (5 minutes)

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up with your GitHub account (or email)
4. Create a new organization (you can name it "FitTrack" or anything you like)

## Step 2: Create Your Database (5 minutes)

1. Click "New Project"
2. Fill in the details:
   - **Name**: FitTrack
   - **Database Password**: Create a strong password and save it somewhere safe
   - **Region**: Choose the region closest to you
3. Click "Create new project"
4. Wait 2-3 minutes for Supabase to set up your database

## Step 3: Get Your API Keys (2 minutes)

1. Once your project is ready, go to **Settings** (gear icon on the left sidebar)
2. Click on **API** in the settings menu
3. You'll see several keys. Copy these three:
   - **Project URL** (looks like: https://xxxxx.supabase.co)
   - **anon public key** (starts with "eyJ...")
   - **service_role key** (starts with "eyJ..." - this one is secret!)

## Step 4: Run the Database Schema (5 minutes)

1. In your Supabase dashboard, click on **SQL Editor** (on the left sidebar)
2. Click "+ New Query"
3. Open the file `backend/database/schema.sql` from this project
4. Copy ALL the SQL code from that file
5. Paste it into the Supabase SQL Editor
6. Click **RUN** (bottom right corner)
7. You should see "Success. No rows returned" - that's perfect!

## Step 5: Configure Your Backend (3 minutes)

1. In your terminal, navigate to the backend folder:
   ```bash
   cd backend
   ```

2. Create a `.env` file:
   ```bash
   touch .env
   ```

3. Open the `.env` file in a text editor and add:
   ```
   SUPABASE_URL=your_project_url_here
   SUPABASE_ANON_KEY=your_anon_key_here
   SUPABASE_SERVICE_KEY=your_service_role_key_here
   JWT_SECRET=make_up_a_long_random_string_here
   PORT=8080
   ENVIRONMENT=development
   ```

4. Replace the placeholders with:
   - `SUPABASE_URL`: The Project URL you copied
   - `SUPABASE_ANON_KEY`: The anon public key you copied
   - `SUPABASE_SERVICE_KEY`: The service_role key you copied
   - `JWT_SECRET`: Any long random string (like: my-super-secret-jwt-key-12345)

## Step 6: Install Go Dependencies (2 minutes)

```bash
cd backend
go mod download
```

This downloads all the required packages.

## Step 7: Start Your Server (1 minute)

```bash
go run cmd/api/main.go
```

You should see:
```
🚀 FitTrack API server starting on port 8080
📊 Endpoints available:
   - POST /api/v1/auth/register
   - POST /api/v1/auth/login
   - POST /api/v1/workouts
   ...
```

## Step 8: Test Your Server (2 minutes)

Open a new terminal window and test the health endpoint:

```bash
curl http://localhost:8080/health
```

You should see:
```json
{"service":"fittrack-api","status":"healthy"}
```

🎉 **Your backend is now running!**

## Troubleshooting

### "command not found: go"
You need to install Go first:
- Mac: `brew install go`
- Or download from: https://go.dev/dl/

### "Error: SUPABASE_URL environment variable is required"
Make sure your `.env` file is in the `backend` folder and has all the required variables.

### "Failed to create account"
Check that:
1. Your Supabase database schema was run successfully
2. Your API keys are correct in the `.env` file
3. Your internet connection is working

## Next Steps

Once your backend is running, we'll:
1. Build the iOS app's networking layer
2. Create a login screen
3. Connect your iPhone app to this backend

Keep your terminal window with the server running open!

