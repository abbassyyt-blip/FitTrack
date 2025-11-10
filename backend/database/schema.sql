-- FitTrack Database Schema for Supabase
-- Run this SQL in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Workout Sessions Table
CREATE TABLE IF NOT EXISTS workout_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    workout_name TEXT NOT NULL,
    workout_date TIMESTAMPTZ NOT NULL,
    duration_hours INTEGER DEFAULT 0,
    duration_minutes INTEGER NOT NULL,
    overall_rpe DECIMAL(3,1) CHECK (overall_rpe >= 1 AND overall_rpe <= 10),
    estimated_calories INTEGER DEFAULT 0,
    activity_type TEXT CHECK (activity_type IN ('strength', 'cardio')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Workout Exercises Table
CREATE TABLE IF NOT EXISTS workout_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_id UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    notes TEXT DEFAULT '',
    "order" INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Workout Sets Table
CREATE TABLE IF NOT EXISTS workout_sets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    exercise_id UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
    weight TEXT NOT NULL,
    reps TEXT NOT NULL,
    rpe DECIMAL(3,1) CHECK (rpe IS NULL OR (rpe >= 1 AND rpe <= 10)),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Food Logs Table
CREATE TABLE IF NOT EXISTS food_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    meal_type TEXT CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    source_text TEXT,
    calories_estimated INTEGER NOT NULL,
    protein_g DECIMAL(10,2),
    fat_g DECIMAL(10,2),
    carbs_g DECIMAL(10,2),
    ai_confidence_score DECIMAL(3,2) DEFAULT 0.80,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Body Metrics Table
CREATE TABLE IF NOT EXISTS body_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    body_weight_kg DECIMAL(6,2),
    body_fat_percent DECIMAL(4,2),
    muscle_mass_kg DECIMAL(6,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, log_date)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_workout_date ON workout_sessions(workout_date);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_workout_id ON workout_exercises(workout_id);
CREATE INDEX IF NOT EXISTS idx_workout_sets_exercise_id ON workout_sets(exercise_id);
CREATE INDEX IF NOT EXISTS idx_food_logs_user_id ON food_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_food_logs_log_date ON food_logs(log_date);
CREATE INDEX IF NOT EXISTS idx_body_metrics_user_id ON body_metrics(user_id);
CREATE INDEX IF NOT EXISTS idx_body_metrics_log_date ON body_metrics(log_date);

-- Enable Row Level Security (RLS)
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE body_metrics ENABLE ROW LEVEL SECURITY;

-- RLS Policies for workout_sessions
CREATE POLICY "Users can view their own workouts"
    ON workout_sessions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own workouts"
    ON workout_sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own workouts"
    ON workout_sessions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own workouts"
    ON workout_sessions FOR DELETE
    USING (auth.uid() = user_id);

-- RLS Policies for workout_exercises
CREATE POLICY "Users can view exercises of their workouts"
    ON workout_exercises FOR SELECT
    USING (
        workout_id IN (
            SELECT id FROM workout_sessions WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert exercises for their workouts"
    ON workout_exercises FOR INSERT
    WITH CHECK (
        workout_id IN (
            SELECT id FROM workout_sessions WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete exercises from their workouts"
    ON workout_exercises FOR DELETE
    USING (
        workout_id IN (
            SELECT id FROM workout_sessions WHERE user_id = auth.uid()
        )
    );

-- RLS Policies for workout_sets
CREATE POLICY "Users can view sets of their exercises"
    ON workout_sets FOR SELECT
    USING (
        exercise_id IN (
            SELECT e.id FROM workout_exercises e
            JOIN workout_sessions w ON e.workout_id = w.id
            WHERE w.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert sets for their exercises"
    ON workout_sets FOR INSERT
    WITH CHECK (
        exercise_id IN (
            SELECT e.id FROM workout_exercises e
            JOIN workout_sessions w ON e.workout_id = w.id
            WHERE w.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete sets from their exercises"
    ON workout_sets FOR DELETE
    USING (
        exercise_id IN (
            SELECT e.id FROM workout_exercises e
            JOIN workout_sessions w ON e.workout_id = w.id
            WHERE w.user_id = auth.uid()
        )
    );

-- RLS Policies for food_logs
CREATE POLICY "Users can view their own food logs"
    ON food_logs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own food logs"
    ON food_logs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own food logs"
    ON food_logs FOR DELETE
    USING (auth.uid() = user_id);

-- RLS Policies for body_metrics
CREATE POLICY "Users can view their own body metrics"
    ON body_metrics FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own body metrics"
    ON body_metrics FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own body metrics"
    ON body_metrics FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own body metrics"
    ON body_metrics FOR DELETE
    USING (auth.uid() = user_id);

-- Create a function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for workout_sessions
CREATE TRIGGER update_workout_sessions_updated_at
    BEFORE UPDATE ON workout_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

