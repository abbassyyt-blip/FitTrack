# FitTrack

## Project Description
Problem: I want to see the progress I am making with various different exercises that I do at the gym while also being able to track my calories easily (through the use of AI) and have it all in one app so I can cross reference my progress with my diet and bodyweight all at once to see what could be causing growth or declining progression.

Solution: My app will allow for accurate calorie tracking through the use of AI and simply typing in the food being eaten (no need for barcode scanning). The app will track body weight and calorie intake as well as expenditure as it allows for tracking physical activities. These physical activities (lets say weight lifting or running) will have data that can be graphed over a time range to see the progress being made. The app will allow for cross reference the data so that the viewer could see if specific foods, body weight, or other factors are influencing the progress they are making in their physical activities.

Audience: This can be used by all ages and it solves a problem for me personally which I assume many others may also have.

Minimum Viable Product (MVP): 
- Tracking physical activities including reps completed, miles ran, etc whatever unit applies to the activity with estimated calories burned for each activity
- Tracking calories with AI estimating calorie intake
- Graphs and data interpretation using the calories, bodyweight, and physical activity data with suggestions for diet/exercise for continued progression/improvement

## Product Requirements Document
# Product Requirements Document (PRD): FitTrack v1.0 (MVP)

## 1. Introduction

### 1.1 Purpose
This document outlines the requirements, goals, features, and specifications for the Minimum Viable Product (MVP) of FitTrack. FitTrack aims to be a unified platform for tracking physical activity, weight, and nutrition, utilizing AI to provide cross-referenced insights into progress, plateaus, and potential causes for change.

### 1.2 Goals
The primary goals of FitTrack MVP are:
1.  Provide a fast, reliable, and intuitive system for logging workouts based on Duration and RPE.
2.  Deliver highly accurate, AI-powered calorie intake estimation from natural language text input.
3.  Automate the cross-referencing of Exercise Progress, Bodyweight, and Calorie Data to generate actionable insights.

### 1.3 Target Audience
All individuals interested in fitness, strength training, or weight management who wish to systematically analyze the relationship between their diet, body weight, and physical performance.

## 2. Feature Requirements

### 2.1 Activity Tracking Module (Workout Logging)

**REQ-ACT-001: Activity Input Method**
The system must allow users to log physical activities by specifying the Activity Name, Duration, and Intensity (RPE).

**REQ-ACT-002: Activity Name Flexibility**
Users must be able to enter custom activity names (e.g., \"Vinyasa Yoga,\" \"HIIT Class,\" \"Pickup Basketball\").

**REQ-ACT-003: Duration Input**
Duration must be logged in minutes (e.g., 45 minutes).

**REQ-ACT-004: Intensity Input (MVP Standard)**
Intensity must be captured using the Rate of Perceived Exertion (RPE) scale from 1 (Rest) to 10 (Maximum Effort). This is the primary quantifiable metric for activity expenditure in the MVP.

**REQ-ACT-005: Calorie Estimation (Activity)**
The system must calculate and display an estimated calorie expenditure for each logged activity based on Duration and RPE. This estimation will rely on established metabolic equivalent of task (MET) estimations mapped to the RPE scale.

**REQ-ACT-006: Weightlifting Specifics (Future Proofing)**
While the MVP focuses on Duration/RPE for all activities, the data model must support logging specific details (sets, reps, weight) for weightlifting exercises, linking them under a general workout entry. For the MVP, these specific sets/reps/weight details will be saved but primarily used to calculate aggregate metrics (like total volume) for graphing, not as the primary intensity input.

### 2.2 Nutrition Tracking Module (Calorie Logging)

**REQ-NUT-001: Text-Based Food Entry**
Users must be able to log food intake by typing a natural language description (e.g., \"one large chicken breast with a side of rice and olive oil\"). Barcode scanning is explicitly excluded from the MVP scope.

**REQ-NUT-002: AI Parsing (Perplexity Integration)**
The backend must securely call the Perplexity API to parse the natural language input, extract standard food items, quantities, and derive total calories and macronutrients (Protein, Fat, Carbs).

**REQ-NUT-003: Calorie Accuracy Target**
The AI-derived calorie estimate must aim for 90% accuracy against a standardized database for known foods. The system must acknowledge and prompt for clarification on ambiguous inputs (homemade meals, vague portions).

**REQ-NUT-004: Daily Intake Tracking**
The system must aggregate all food entries for a single calendar day to provide a Total Daily Calorie Intake figure.

### 2.3 Body Metrics Tracking

**REQ-BOD-001: Body Weight Logging**
Users must be able to log their body weight daily.

**REQ-BOD-002: HealthKit Integration (Read)**
The app must read the user\'s current body weight from Apple HealthKit as the primary source of truth, and use this data for daily logging/trending.

**REQ-BOD-003: Body Composition Metrics (Future Proofing)**
While weight is mandatory, the data model must be prepared to integrate body composition metrics (e.g., body fat percentage) in future versions. For the MVP, weight is the only required metric.

**REQ-BOD-004: Bodyweight Graph Smoothing**
The Bodyweight graph must display a **7-day rolling average** as the primary trend line, with the raw daily weigh-ins displayed as faint points.

### 2.4 Data Visualization and Cross-Referencing (The Core Value)

**REQ-VIS-001: Standard Graphing Ranges**
All primary progress graphs (Strength, Bodyweight, Nutrition) must support three time ranges: 7-Day (Adherence focus), 30-Day (Trend focus), and All-Time (Progress focus).

**REQ-VIS-002: Graph Types**
The MVP will utilize Line Graphs for trend visualization (e.g., Strength progression) and Bar Graphs for daily adherence visualization (e.g., Daily Calorie Intake vs. Target).

**REQ-VIS-003: Dashboard Insights (Layer 1)**
The main dashboard must feature an "Insight Card" section that automatically displays AI-generated, plain-English suggestions based on detected correlations between logged data.

*   **REQ-VIS-003a (Stall Insight):** Suggest potential causes when progress (strength or weight) plateaus (e.g., linking stalled strength to dropped protein).
*   **REQ-VIS-003b (Positive Insight):** Reinforce positive correlations (e.g., linking calorie surplus to strength gain).
*   **REQ-VIS-003c (Effort Insight):** Link workout intensity (RPE) to pre-workout nutrition metrics.

**REQ-VIS-004: Customizable Comparative Widgets (Layer 2)**
Users must be able to add dual-axis line graph widgets to the dashboard, allowing them to select any two core metrics (e.g., Weekly Volume vs. Average Daily Calorie Intake) over a 30-day range.

**REQ-VIS-005: Deep Dive Comparison Reports (Layer 3)**
A dedicated "Analyze" tab must allow power users to select Metric A (e.g., Barbell Squat e1RM) and Metric B (e.g., Daily Calorie Intake) to overlay on an interactive graph.

*   **REQ-VIS-005a (Correlation Summary):** The AI must generate a text summary below the deep-dive graph quantifying the correlation found between the two selected metrics over the displayed period.

## 3. Design and User Experience (UX/UI)

**DES-001: Aesthetic Philosophy**
The application aesthetic must align with a minimalist, data-focused, "Personal Lab" feel.

**DES-002: Color Palette**
The primary mode must be Dark Mode (Black/Dark Grey background). Interactive elements, primary data lines, and action buttons must utilize a single, vibrant accent color (e.g., electric blue or sharp green).

**DES-003: Typography**
Use a clean, modern sans-serif font. Hierarchy must be achieved solely through size and weight (Bold, Medium, Regular).

**DES-004: Data Visualization Quality**
Graphs must be clean, highly readable, and interactive (allowing users to scrub/tap data points).

**DES-005: Inspiration Adherence**
The logging workflow should prioritize speed and efficiency akin to the Strong app. Data insight presentation should be clean and distilled, similar to Gentler Streak. Clutter, advertising, and excessive gamification must be avoided.

## 4. Non-Functional Requirements (NFRs)

### 4.1 Performance and Latency
**NFR-PERF-001: App Load Time**
Cold start load time must be under 3.0 seconds. Warm start load time must be under 500 milliseconds.

**NFR-PERF-002: AI Food Log Latency**
The perceived time from logging a typed food entry to receiving the AI-parsed nutritional result must be under 2.0 seconds.

**NFR-PERF-003: Graph Rendering**
Standard 7-day/30-day graphs must render completely within 1.5 seconds of data being received by the client. Loading states (skeletons/shimmers) must be used for any operation exceeding 500ms.

### 4.2 Security and Privacy
**NFR-SEC-001: Health Data Compliance**
The app must strictly adhere to all Apple HealthKit guidelines regarding data access, consent, and privacy policy documentation concerning Protected Health Information (PHI).

**NFR-SEC-002: API Key Security**
The backend proxy must secure the Perplexity API key; it must never be exposed client-side on the iOS application.

**NFR-SEC-003: Network Communication**
All data transmission between the client and the backend must utilize HTTPS.

### 4.3 Usability and Reliability
**NFR-USAB-001: Offline Logging**
The user must be able to fully log workouts and food entries while offline. These entries must be stored locally (SwiftData) and automatically sync upon reconnection.

**NFR-USAB-002: Crash Rate**
The application must maintain a 99.9%+ crash-free session rate. Data integrity must not be compromised by crashes.

### 4.4 Interoperability
**NFR-INT-001: HealthKit Read/Write**
The application must correctly request permission, read Body Weight from HealthKit, and write completed workout sessions to HealthKit.

## 5. Future Scalability Considerations

**NFR-SCALE-001: Guided Workouts Support**
The MVP database schema for exercise logging must include a non-nullable field (`routine_exercise_id`) which defaults to NULL. This structure is required to support future, prescriptive Guided Workout features without a required full data migration.

**NFR-SCALE-002: Detailed Macro Tracking**
The nutrition logging database table must be designed to easily accommodate the future addition of detailed macro-nutrients (Carbs, Fat, Fiber, Sodium, Sugar) without requiring schema restructuring beyond adding new columns.

## 6. Suggestions and Feedback Mechanism

**SUGG-001: AI Feedback Requirement**
The dashboard must provide a simple mechanism for users to offer feedback on AI Insight Cards (e.g., a simple thumbs up/down icon). This feedback must be captured to assist in model training and tuning the correlation sensitivity.

**SUGG-002: Suggestion Tone**
All AI-generated text suggestions must remain observational and non-prescriptive, focusing on correlation rather than acting as medical or certified coaching advice. (Example structure: Observation + Correlation + Non-binding Prompt).

## Technology Stack
FitTrack - Technology Stack Documentation

1. Client-Side (Mobile Application)

Technology: Swift & SwiftUI
Justification: As the application is strictly for iOS, native development using Swift provides the best performance, the tightest integration with the operating system (especially HealthKit), and aligns perfectly with the modern, minimalist UI aesthetic requested. SwiftUI is the declarative framework necessary to build the clean, data-centric visualizations and interactive components efficiently.

Data Persistence (Local): SwiftData
Justification: SwiftData is the modern, Swift-native framework built on Core Data principles. It is ideal for handling the critical offline usability requirement—storing all user logs (food, workouts) locally until synchronization is possible. It integrates seamlessly with SwiftUI.

Interoperability: Apple HealthKit API
Justification: Essential for reading body weight (and optionally body composition metrics like body fat %) and writing completed workout data back to the central Health ecosystem, fulfilling interoperability NFRs.

2. Backend (Server & API Gateway)

Technology: Node.js or Python (e.g., Express.js or Django/Flask)
Justification: The backend serves two primary roles: a secure proxy for external AI services and the orchestration layer for user data. Both Node.js and Python are excellent for building fast, scalable API layers. Python is marginally favored if the development team plans to expand AI/ML processing in the future, but Node.js offers superior I/O performance for a proxy-heavy architecture.

Security Constraint: All API keys (especially the Perplexity API key) MUST reside securely on this backend server and never be exposed to the iOS client.

3. Database

Technology: PostgreSQL (Recommended) or MongoDB
Justification:
PostgreSQL (Relational): Recommended for structural integrity, especially when planning for the future complexity of Guided Workouts (Phase 2). It handles the relational mapping (programs, routines, subscriptions) robustly.
MongoDB (NoSQL): Could be used if schema flexibility is prioritized over rigid relationships, though relational structure is more future-proof for the prescriptive coaching features.

Data Integrity NFR: The database must ensure atomic transactions for logging, preventing data loss in case of sync conflicts.

4. Artificial Intelligence (AI/LLM) Services

Technology: Perplexity Sonar API (or similar highly capable LLM service)
Justification: This is the engine for the calorie tracking feature based on typed food entries. The requirement mandates high accuracy (~90%) for diverse, ambiguous input. Perplexity's ability to perform complex reasoning and factual grounding makes it suitable for parsing natural language food descriptions into standardized nutritional data, provided the backend correctly handles context and ambiguity prompting.

Data Flow Constraint: AI calls must be proxied through the secure backend server.

5. Performance & Latency Optimization Strategy

Target Latency Management: All components are selected to meet strict NFRs (App Load < 3s, AI Log < 2s, Graph Fetch < 1.5s).
Graphing Strategy: Client-side rendering using SwiftUI for speed. Database queries must be highly optimized for common time ranges (7-day and 30-day aggregates).
Data Smoothing: Bodyweight data will be processed server-side or on the client to generate a 7-day rolling average, ensuring graphs are smooth and actionable despite daily logging frequency.

6. Data Visualization & UI Layer

Aesthetic Alignment: The UI framework (SwiftUI) is chosen specifically to support the "Personal Lab" aesthetic:
Dark Mode Preference: OLED black backgrounds are natively supported and optimized on iOS.
Color Use: Strict use of white/gray text on a dark field, utilizing a single, vibrant accent color (Electric Blue or Sharp Green) exclusively for interactive elements and critical data points.
Typography: Reliance on clean, modern sans-serif fonts (like SF Pro) using weight and size hierarchy.

7. Future-Proofing (Scalability Consideration)

Design Constraint: The MVP data models (specifically the `exercise_logs` table structure) must include a `routine_exercise_id` column (defaulting to NULL) to accommodate the relational complexity required by future Guided Workout features without forcing a complete data migration.

## Project Structure
# PROJECT STRUCTURE DOCUMENT: FitTrack

## 1. Overview and Purpose

This document details the logical and physical file and folder organization for the FitTrack application. The structure is designed to support a clean, maintainable, modern iOS application built with Swift/SwiftUI, adhering to the "Personal Lab" aesthetic and performance requirements. It separates concerns clearly for the Client (iOS App) and the necessary Backend infrastructure.

## 2. Top-Level Directory Structure

The project repository is structured primarily around the Client application, with placeholder directories for required backend services.

```
FitTrack/
├── .github/                   # CI/CD and Workflow configuration
├── client/                    # The primary iOS application codebase (SwiftUI/Swift)
├── backend/                   # Placeholder for required server infrastructure
│   ├── api/                   # Node.js/Python backend logic proxy
│   └── db/                    # Database configuration scripts (PostgreSQL/MongoDB)
├── docs/                      # Project documentation (this file, architecture diagrams)
└── scripts/                   # Utility scripts (e.g., deployment, database seeding)
```

## 3. Client Application Structure (`client/FitTrackApp/`)

The iOS application is structured using architectural patterns (e.g., MVVM, Redux-like flow) to separate UI, business logic, and data management.

```
client/FitTrackApp/
├── FitTrackApp.swift          # Main entry point and App setup
│
├── Resources/                 # Static assets and configuration
│   ├── Assets.xcassets        # Images, icons (Dark Mode optimized)
│   ├── Fonts/                 # Custom or licensed font files (if not using SF Pro)
│   ├── Info.plist             # Configuration file (Permissions, HealthKit setup)
│   └── PrivacyInfo.xcprivacy  # Required file detailing PHI usage
│
├── Models/                    # Data structures and core types (Codable, SwiftData Entities)
│   ├── UserProfile.swift      # User settings, goals (e.g., target calories, weight)
│   ├── FoodEntry.swift        # Struct for AI food logging result
│   ├── ActivityLog.swift      # Core entity for RPE/Duration tracking
│   ├── BodyMetrics.swift      # Weight, Body Fat % entities
│   └── DataConstants.swift    # Static constants (e.g., RPE scale max)
│
├── Services/                  # Business logic layer (Handles integration with external systems)
│   ├── HealthKitService.swift # Handles all HealthKit read/write operations (PHI)
│   ├── BackendAPIClient.swift # Handles secure network calls to the backend server
│   ├── AIService.swift        # Local wrappers for backend calls (e.g., /api/analyze_food)
│   └── PersistenceController.swift # Manages SwiftData / Realm context setup
│
├── Views/                     # Presentation Layer (SwiftUI Views)
│   ├── Dashboard/             # Main landing screen containing Insight Cards
│   │   ├── DashboardView.swift
│   │   └── InsightCard.swift  # Component for Layer 1 AI Suggestions
│   │
│   ├── Logging/               # Screens for data entry
│   │   ├── ActivityLogger.swift
│   │   └── FoodLoggerView.swift # Includes typed input field and AI parsing UI
│   │
│   ├── Analysis/              # The "Deep Dive" Lab (Layer 3 UI)
│   │   ├── ComparisonReportView.swift # Core view for overlaying two metrics
│   │   └── WidgetLibrary.swift # View for Layer 2 configuration
│   │
│   └── Components/            # Reusable, atomic UI elements
│       ├── DarkBackgroundContainer.swift # Ensures correct "OLED Black" background
│       ├── AccentButton.swift # Reusable button style with accent color
│       └── DataVisualization/ # Graphing components
│           ├── LineGraphView.swift
│           ├── BarGraphView.swift
│           └── GraphScrubber.swift
│
└── ViewModels/                # Logic controllers that feed data to the Views
    ├── DashboardViewModel.swift
    ├── ActivityLogViewModel.swift
    └── AnalysisViewModel.swift # Handles complex query construction for comparison reports
```

## 4. Backend Structure (`backend/api/`)

The backend acts as a secure intermediary for the Perplexity AI API and the primary data storage. It must never expose API keys to the client.

```
backend/api/
├── src/
│   ├── routes/                # Defines API endpoints
│   │   ├── auth.js            # User authentication/management
│   │   ├── workouts.js        # Endpoints for logging/retrieving activity data
│   │   ├── nutrition.js       # Endpoints for food logging requests
│   │   └── analyze.js         # Endpoint called by client to trigger AI analysis
│   │
│   ├── controllers/           # Business logic execution
│   │   └── AIController.js    # Handles interaction with Perplexity API
│   │
│   ├── models/                # Database schema definitions (Mongoose/Sequelize)
│   │   ├── User.js
│   │   └── LogEntry.js
│   │
│   └── middleware/            # Security and validation
│       └── auth_middleware.js
│
├── server.js                  # Server initialization (Express/Fastify)
└── package.json
```

## 5. Data Model Implications (Future-Proofing for Scalability)

The design of the MVP data models explicitly accounts for the future introduction of "Guided Workouts," as required by scalability concerns.

| MVP Table/Entity | Key Fields Included Now | Rationale |
| :--- | :--- | :--- |
| `ActivityLog` | `routine_exercise_id` (Set to NULL/Optional) | Allows linking a logged set to a *prescribed* parent in Phase 2 without refactoring the entire logging endpoint. |
| `UserProfile` | (None explicitly) | Goal settings will be expanded later to include routine preferences. |
| `FoodEntry` | Fields for all future macronutrients (Carbs, Fat, Fiber) | While only `calories` and possibly `protein` are used in MVP AI responses, adding structure now prevents major schema migration when detailed macro tracking is implemented. |

## 6. HealthKit Data Flow Requirements

To satisfy non-functional requirements regarding interoperability and data source truth:

| Metric | Source of Truth (Read) | Write Destination (If Applicable) |
| :--- | :--- | :--- |
| **Body Weight** | Apple HealthKit | None (Read-only for trend analysis) |
| **Body Fat %** | Apple HealthKit (If available/provided) | None (Read-only) |
| **Workout Data** | Client Entry (RPE/Duration) | Apple HealthKit (as ExerciseType) |
| **Calorie Expenditure** | Backend/AI Estimation (for activity) | Apple HealthKit (As Active Energy Burned) |

## Database Schema Design
FitTrack: Schema Design Documentation (v1.0 MVP)

1. OVERVIEW & DESIGN PRINCIPLES

The FitTrack database schema is designed to support three core, interrelated data streams: Nutrition (AI-driven calorie logging), Activity (Effort-based workout logging), and Biometrics (Weight/Composition tracking). The structure prioritizes data integrity, performance (for fast graph rendering), and future scalability, particularly supporting the eventual introduction of Guided Workouts.

Aesthetic Note: The underlying data structure supports a minimalist, data-focused "Personal Lab" UI aesthetic (Dark Mode preferred). All performance targets prioritize latency below 1.5 seconds for critical reads.

2. CORE ENTITIES & RELATIONSHIPS

The schema revolves around the User, with logs being tied to specific activities or food entries.

2.1. User Management (ACCOUNT)

Table: Users
Purpose: Stores core user authentication and profile information.
| Field Name | Data Type | Constraints/Notes |
| :--- | :--- | :--- |
| user_id | UUID/Serial PK | Primary Key |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| password_hash | VARCHAR(255) | Stored securely |
| created_at | TIMESTAMP | NOT NULL |
| last_login | TIMESTAMP | |

2.2. Nutrition Tracking (CALORIE_LOG)

This table captures the AI-parsed result of food entry logging. It is structured to easily accept future, detailed macro fields (Fat, Carbs, Fiber, etc.) without structural change.

Table: FoodLogs
Purpose: Stores daily and per-meal calorie intake derived from AI processing.
| Field Name | Data Type | Constraints/Notes |
| :--- | :--- | :--- |
| food_log_id | UUID/Serial PK | Primary Key |
| user_id | UUID FK | References Users(user_id), NOT NULL |
| log_date | DATE | NOT NULL (For daily summarization) |
| meal_type | VARCHAR(50) | E.g., \\"Breakfast\\", \\"Lunch\\", \\"Snack\\", \\"Dinner\\" |
| source_text | TEXT | The original text the user typed (for debugging AI) |
| calories_estimated | INTEGER | The final parsed calorie count. MVP Target: ~90% accuracy. |
| protein_g | DECIMAL(10, 2) | Nullable in MVP, essential for Phase 2 |
| fat_g | DECIMAL(10, 2) | Nullable in MVP, essential for Phase 2 |
| carbs_g | DECIMAL(10, 2) | Nullable in MVP, essential for Phase 2 |
| ai_confidence_score | DECIMAL(3, 2) | Score of the AI parsing confidence (0.00 - 1.00) |

2.3. Activity Tracking (WORKOUT_LOG)

This structure separates the overall workout session from the individual sets/components, adhering to the RPE requirement and future-proofing for Guided Workouts.

Table: WorkoutSessions
Purpose: Represents a single training session (e.g., \\"Monday Gym\\").
| Field Name | Data Type | Constraints/Notes |
| :--- | :--- | :--- |
| session_id | UUID/Serial PK | Primary Key |
| user_id | UUID FK | References Users(user_id), NOT NULL |
| session_date | TIMESTAMP | NOT NULL (When the session occurred) |
| activity_name | VARCHAR(100) | E.g., \\"Vinyasa Yoga\\", \\"HIIT Class\\" |
| duration_minutes | INTEGER | User input: E.g., 45 |
| overall_rpe | INTEGER | Average RPE for the session (Scale 1-10). Nullable if only sets are logged. |
| estimated_calories_burned | INTEGER | Calculated by backend based on duration, RPE/HR, and user profile. |
| sync_status | VARCHAR(20) | \\"LOCAL\\", \\"SYNCED\\" (For offline usability NFR) |
| routine_exercise_id | UUID FK | NULL in MVP. **Future proofing for Guided Workouts.** |

Table: ExerciseSets
Purpose: Logs the specific actions within a session (e.g., a single set of squats, or a segment of a run).
| Field Name | Data Type | Constraints/Notes |
| :--- | :--- | :--- |
| set_id | UUID/Serial PK | Primary Key |
| session_id | UUID FK | References WorkoutSessions(session_id), NOT NULL |
| metric_type | VARCHAR(50) | E.g., \\"RepsVolume\\", \\"Distance\\" (For specialized activities) |
| value_1 | DECIMAL(10, 2) | Primary measure (e.g., Weight lifted, or Distance in Miles/KM) |
| value_2 | INTEGER | Secondary measure (e.g., Reps completed, or RPE for this specific set) |
| calories_burned_estimated | INTEGER | Estimated burn for this specific set/segment |

**MVP Metric Interpretation for ExerciseSets:**
*   For Reps/Weight Activities (Lifting): value_1 = Weight, value_2 = Reps.
*   For Duration/RPE Activities (Yoga/HIIT): session\_date/duration/overall\_rpe handle the primary data. This table may remain sparse or unused in the initial RPE-based MVP, focusing activity tracking on the WorkoutSessions table fields.

2.4. Biometric Tracking (BODY_METRICS)

This table supports the requirement for daily logging but enforces a 7-day rolling average for graphing purposes to smooth out noise.

Table: BodyMetrics
Purpose: Tracks body weight and body composition data.
| Field Name | Data Type | Constraints/Notes |
| :--- | :--- | :--- |
| metric_id | UUID/Serial PK | Primary Key |
| user_id | UUID FK | References Users(user_id), NOT NULL |
| log_date | DATE | NOT NULL |
| body_weight_kg | DECIMAL(6, 2) | User/HealthKit Input. Source of Truth for weight graphs. |
| body_fat_percent | DECIMAL(4, 2) | Nullable in MVP. **Crucial for cross-referencing insights.** |
| muscle_mass_kg | DECIMAL(6, 2) | Nullable for Phase 2 |

3. DATA AGGREGATION FOR REPORTING & AI

The MVP requires efficient data retrieval across time windows (7-Day, 30-Day, All-Time). Optimized views or database functions are recommended for the following calculated metrics:

3.1. Calorie Metrics (FoodLogs)
*   Daily Calorie Intake (Sum of FoodLogs on log\_date)
*   Weekly Calorie Surplus/Deficit (Comparison of Daily Intake vs. Estimated Expenditure)

3.2. Activity Metrics (WorkoutSessions & ExerciseSets)
*   Total Weekly Volume (Sum of (Weight * Reps * Sets) for all sets in a week)
*   Average Weekly RPE (Average of session\_overall\_rpe for all sessions in a week)
*   Avg. Activity Calorie Burn (Per activity type)

3.3. Bodyweight Metrics (BodyMetrics)
*   7-Day Rolling Average Weight: Calculated by averaging BodyMetrics.body\_weight\_kg over the preceding 7 days (including the current day). **This is the bold line on the MVP weight graph.**
*   Daily Weight Dots: The raw, un-averaged daily entries (faint dots on the graph).

4. INTEROPERABILITY (HealthKit Sync)

The backend design must account for bidirectional synchronization, though the client (iOS/SwiftData) manages the immediate cache.

*   Read from HealthKit: Reads BodyWeight.
*   Write to HealthKit: Writes WorkoutSessions (as completed exercise events) and Estimated Calories Burned.

5. SCALABILITY CONSIDERATIONS (Future-Proofing: Guided Workouts)

The following fields, while potentially NULL in the MVP, are present specifically to prevent a full schema migration when Phase 2 (Guided Workouts) is implemented:

*   Users.is_subscribed (BOOLEAN)
*   WorkoutSessions.routine\_exercise\_id (UUID FK, references a future RoutineExercises table)
*   ExerciseSets.routine\_exercise\_id (UUID FK, references a future RoutineExercises table)

## User Flow
USERFLOW DOCUMENTATION: FitTrack MVP

Project: FitTrack - AI-Powered Fitness & Nutrition Cross-Referencing Lab

Date Generated: October 26, 2023

---
SECTION 1: CORE USER JOURNEYS (MVP FOCUS)
---

1.1 Journey 1: Logging A New Workout (RPE Based)

User Goal: Record the details and perceived effort of a completed strength training session.

| Step | User Action | System Response / Screen State | Key Data Captured |
| :--- | :--- | :--- | :--- |
| 1.1.1 | Taps the central "Log Activity" floating action button (FAB) on the Dashboard. | Navigates to the Activity Selection screen. | N/A |
| 1.1.2 | Selects "Strength Training" or types in a custom activity name (e.g., "Full Body Session"). | Enters the Workout Detail Input screen. | Activity Name (e.g., "Full Body Session") |
| 1.1.3 | Enters Duration (e.g., "60 minutes"). | Updates the Duration field. | Duration (60 minutes) |
| 1.1.4 | Taps "Add Exercise Set" to begin logging lifts. | Opens an inline exercise input modal. | N/A |
| 1.1.5 | Selects "Barbell Squat" from the exercise list. Inputs "Weight: 225 lbs" and "Reps: 5". | Returns to the main workout log screen, showing the logged set. | Exercise: Squat, Weight: 225, Reps: 5 |
| 1.1.6 | Repeats Step 1.1.5 for all sets/exercises within the session. | Workout log accumulates sets. | Total Sets/Reps/Weight tracked. |
| 1.1.7 | Taps "Complete Workout Log" once all exercises are entered. | Presents the Finalization Modal. | N/A |
| 1.1.8 | In the Finalization Modal, the user is prompted for Intensity (RPE 1-10). User selects "8". | Updates workout metadata. | Intensity (RPE): 8/10 |
| 1.1.9 | Taps "Save & Sync". | Processes data locally (SwiftData) and pushes to backend. Estimated Calorie Burn is calculated (Duration x RPE approximation). Displays a success toast. | Estimated Calories Burned logged. |
| 1.1.10 | Returns to Dashboard. | Dashboard updates instantly with recent activity summary. AI processes the new data point for cross-referencing. | N/A |

1.2 Journey 2: Logging Food Intake (AI Text Parsing)

User Goal: Quickly log lunch and receive an estimated calorie count.

| Step | User Action | System Response / Screen State | Key Data Captured |
| :--- | :--- | :--- | :--- |
| 1.2.1 | Taps the "Log Food" section on the Dashboard. | Navigates to the Nutrition Logging screen. | N/A |
| 1.2.2 | Enters text describing the meal: "Large chicken salad with ranch dressing and a small avocado." | The input field displays a subtle, fast loading indicator while connecting to the backend AI service. (Target Latency: < 2s) | Raw text input. |
| 1.2.3 | Hits "Log" or "Analyze". | Backend processes text via Perplexity API. If ambiguity exists (e.g., portion size), the system presents a disambiguation prompt. | N/A |
| 1.2.4 | (Scenario: Ambiguity) System prompts: "For the Ranch Dressing, what is the portion size? (1 tbsp, 2 tbsp, or 1/4 cup)" | User selects "2 tbsp". | Portion confirmation is captured. |
| 1.2.5 | Final confirmation screen displays parsed data (e.g., Chicken Breast, Avocado, Salad Mix, 2 tbsp Ranch) with total estimated calories (e.g., 580 kcal). | User reviews the breakdown. | Calorie Intake, Estimated Macro breakdown. |
| 1.2.6 | Taps "Confirm & Save". | Data saved locally and synced. The user returns to the Dashboard. | N/A |

1.3 Journey 3: Reviewing Cross-Referenced Progress (The Lab)

User Goal: Investigate why strength gains have recently stalled.

| Step | User Action | System Response / Screen State | Key Data Captured |
| :--- | :--- | :--- | :--- |
| 1.3.1 | Navigates to the dedicated "Analyze" or "Lab" tab (Layer 3 UI). | Opens the Comparative Analysis setup screen. | N/A |
| 1.3.2 | User selects Metric A (Strength): Category "Lifting," Metric "Barbell Squat," Data Point "Estimated 1-Rep Max (e1RM)". | Metric A dropdown populates with historical e1RM trend line. | Metric A selected: Squat e1RM |
| 1.3.3 | User selects Metric B (Nutrition): Category "Nutrition," Metric "Calorie Intake," Data Point "Daily Average". | Metric B dropdown populates with daily calorie history bars. | Metric B selected: Daily Avg Calories |
| 1.3.4 | User selects the time range: "30 Days". | The system renders a dual-axis line/bar graph overlaying e1RM (line) vs. Calories (bars) for the last month. | Graph rendering begins (Target Latency: < 1.5s). |
| 1.3.5 | User observes the graph and notices a dip in the calorie line corresponding with a flattening of the e1RM line 3-5 days later. | User can scrub finger across the graph to pinpoint specific data points. | Visual correlation confirmed. |
| 1.3.6 | System automatically generates a "Correlation Summary" card below the graph. | Card reads: "We observe a moderate positive correlation. When your daily caloric average dropped below 2,100 kcal, your Squat e1RM progress paused within 5 days." | AI Insight rendered. |
| 1.3.7 | User taps the "Compare Periods" button. Selects "Period 1: Aug 1 - Aug 30 (Growth)" and "Period 2: Sep 1 - Sep 30 (Stall)". | Generates a side-by-side comparison table summarizing the differences in average RPE, Calorie Surplus/Deficit, and Total Volume between the two periods. | Deep Dive Analysis completed. |

---
SECTION 2: DASHBOARD INTERACTIONS (Layer 1 & 2)
---

2.1 Dashboard Elements (The "Personal Lab" View)

The MVP Dashboard is dark-themed, minimalist, and primarily composed of data widgets and insight cards.

2.1.1 Proactive Insight Cards (Layer 1)

Location: Top section of the Dashboard, displayed prominently.

Interaction: Cards are dismissible via a small (X) icon or thumb swipe. If dismissed, the system records the feedback (implicitly training the AI on relevance).

Content Trigger Examples:
*   "⚠️ Stall Insight Card: Bench Press has been flat for 10 days, coinciding with a drop in average daily protein intake from 160g to 130g. Focus on protein to break this plateau."
*   "✅ Positive Insight Card: Total Squat Volume increased by 15% this week, aligned with a 300-calorie surplus on lifting days. Keep fueling your workouts!"

2.1.2 Customizable Widgets (Layer 2 - At-a-Glance)

Location: Below the Insight Cards, laid out in a customizable grid.

Interaction: Users can tap a widget to immediately jump to the full "Deep Dive Lab" view for that specific comparison.

MVP Widget Library (Default State):
1.  **Widget: Bodyweight Trend:** Displays the 7-day rolling average of bodyweight (bold line) overlaid with faint daily weigh-in dots. (X-Axis: Last 7 Days).
2.  **Widget: Weekly Adherence (Bar Graph):** Shows Daily Calorie Intake vs. Target for the current week (7-day Bar Chart).
3.  **Widget: Lifting Volume vs. Calorie Intake (Dual-Axis Line Graph):** Compares Total Weekly Volume vs. Average Daily Calorie Intake over the last 30 days.

---
SECTION 3: DATA INPUT AND VISUALIZATION PATTERNS
---

3.1 Activity Intensity Standardization (RPE)

All activities (Yoga, HIIT, Sports) are standardized using Duration and RPE (1-10).

*   **Input Flow:** After logging Duration, the user is forced to select an RPE via a simple 10-step slider or numbered buttons.
*   **Calculation for Calorie Estimate:** The system uses (Duration Minutes * RPE * Caloric Burn Factor K) to generate an estimate. This factor K is unique per activity category (e.g., HIIT has a higher K than slow Yoga).
*   **Graphable Metric:** Average RPE for a specific activity tracked over time, or "Weekly Effort Score" (Sum of (Duration * RPE) for all workouts that week).

3.2 Bodyweight Tracking Pattern

*   **Logging:** User logs daily weight via a simple numeric input screen, which syncs with HealthKit.
*   **Visualization:** All bodyweight graphs default to showing the **7-day rolling average** as the primary data element (bold, smooth line). Actual daily weigh-ins are shown as small, faint reference points. This manages user expectation regarding daily fluctuations.
*   **Data Requirement:** Logging Body Composition (e.g., Body Fat %) is enabled for advanced analysis, even if it is currently only logged manually or imported from an external source later.

3.3 Graphing Requirements (MVP Timeframes)

All core metrics (Weight, Volume, e1RM) will be viewable in three modes:

1.  **7-Day View:** Primarily Bar Graphs for adherence (Calories/Protein), Line Graph for noisy short-term weight review.
2.  **30-Day View:** Primarily Dual-Axis Line Graphs for correlation review (Strength vs. Diet). This is the primary progress tracking view.
3.  **All-Time View:** Line Graphs for long-term motivation and trend identification.

---
SECTION 4: NON-FUNCTIONAL INTERACTION PATTERNS
---

4.1 Performance Expectations (User Perception)

*   **App Load:** Cold Start must be < 3 seconds. The user must perceive the app as fast and responsive, aligning with the "premium tool" aesthetic.
*   **AI Food Log:** User must see feedback/processing within 2 seconds after submission to maintain the flow. Slow responses here break user trust in the AI feature.
*   **Data Display:** Graphs must render smoothly without jank (< 200ms rendering time once data is received). Shimmer/skeleton loading screens are mandatory for complex "All-Time" loads.

4.2 Offline Functionality

*   **Logging:** The system must allow the user to complete full logging of Food and Workouts while offline, storing data securely in the local SwiftData database.
*   **Sync:** Once connection is restored, logs must sync sequentially without user intervention. Data integrity must be maintained (i.e., no duplicate entries, proper timestamping).

4.3 Feedback Mechanism

*   **Insight Card Feedback:** Every AI-generated insight card must have a subtle mechanism (e.g., a thumbs up/down icon, or a small "..." menu) allowing the user to rate the suggestion. This low-friction feedback loop is crucial for improving the MVP's suggestion engine accuracy.

## Styling Guidelines
# FitTrack Styling Guidelines Document (FitTrack Design System)

## 1. Overview and Aesthetic Principle

FitTrack is designed to be the user's "Personal Lab"—a focused, premium, and analytical environment for tracking progress where diet, body metrics, and exercise converge. The styling must be minimalist, precise, and data-centric, ensuring that graphs and insights are the undisputed heroes of the interface. We prioritize clarity and focus over excessive decoration or gamification.

**Core Aesthetic:** Data-Focused Minimalism, Premium Precision.

**Target Feeling:** Empowered, Informed, Analytical.

## 2. Color Palette

The palette is strictly limited to ensure maximum contrast for data visualization against a dark background.

| Name | Usage | Hex Code | Notes |
| :--- | :--- | :--- | :--- |
| **Primary Background (OLED Black)** | Main background, navigation areas. | #000000 | Preferred for visual impact and screen efficiency. |
| **Secondary Background (Dark Gray)** | Card backgrounds, separators, subtle groupings. | #1A1A1A | Used sparingly to create depth and separate content blocks. |
| **Primary Text (Pure White)** | Main headings, key data readouts. | #FFFFFF | Maximum legibility against the black background. |
| **Secondary Text (Light Gray)** | Subtitles, timestamps, explanatory text for insights. | #AAAAAA | For secondary, supportive information. |
| **Accent Color (Electric Blue)** | Interactive elements, primary graph lines, CTAs, RPE/Effort markers. | #007AFF (Or similar vibrant blue) | The single, vibrant color used to draw attention to interactive elements and primary data flows. |
| **Alert / Warning Color** | Used sparingly for Stall/Negative Insight Cards. | #FF3B30 (Vibrant Red) | Used only when data suggests a necessary correction or negative trend. |
| **Success Color** | Used sparingly for Positive Insight Cards. | #34C759 (Vibrant Green) | Used only for reinforcement of positive correlations. |

## 3. Typography System

We use a clean, modern, system sans-serif font family for optimal readability across all iOS devices. Hierarchy is established purely through size and weight, keeping color variations minimal (White/Gray).

**Font Family:** System Default (e.g., SF Pro for iOS)

| Level | Usage | Weight | Size (iOS Default Scale) | Color | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **H1 (Screen Title)** | Main Dashboard Title, Report Titles. | Bold | Large (e.g., 34pt) | White | **FitTrack Dashboard** |
| **H2 (Metric Header)** | Key metrics displayed prominently (e.g., Current Weight). | Semibold | Large (e.g., 28pt) | White | **175.2 lbs** |
| **Body - Primary** | Standard paragraph text, primary graph labels. | Regular | Medium (e.g., 17pt) | White | We noticed your total volume increased... |
| **Body - Secondary** | Helper text, timestamps, detailed graph axis labels. | Regular | Small (e.g., 15pt) | Light Gray | Logged 5 minutes ago |
| **Data Callout** | Numbers within graphs or input fields. | Medium | Varies | White | 135 lbs |
| **Caption / Feedback** | Insight Card suggestions, small footnotes. | Medium | Small (e.g., 13pt) | Light Gray | Based on 30-day average. |

## 4. UI/UX Principles

FitTrack's interface must adhere to principles that support deep data analysis and minimal cognitive load.

### 4.1. Data Visualization First (The Hero)

*   **Graph Focus:** Graphs must occupy maximum usable screen space on data-centric views. Whitespace (or "Blackspace") around graphs should be generous.
*   **Interactivity:** All primary graphs (30-Day, All-Time) must support scrubbing/panning/zooming to reveal precise data points instantly.
*   **Dual-Axis Clarity:** When correlating two metrics (e.g., Weight vs. Strength), the primary lines must use distinct, high-contrast visual styles (e.g., Bold Line for Metric A, Dotted Line for Metric B). Axis labels must be clearly color-coded to match the data lines if necessary, but prioritize labeling.
*   **Bodyweight Trend:** The Bodyweight graph must prominently display the **Bold, Clear 7-Day Rolling Average Line** over the fainter, small dots representing the daily weigh-ins.

### 4.2. Input Efficiency (The Logbook)

*   **Speed is Critical:** Logging interactions (especially AI Food Logging) must target sub-2-second latency. Utilize loading skeletons/shimmers instantly upon submission.
*   **Workout Logging Adherence:** The workout logging screen should emulate the speed and simplicity of apps like Strong, requiring minimal taps to enter sets, reps, and RPE.
*   **RPE Scale:** The Rate of Perceived Exertion (RPE 1-10) input must be a highly visible, intuitive slider or segmented control, highlighted using the Electric Blue accent color.

### 4.3. Insight Delivery (The Personal Lab)

*   **Insight Card Design:** Automated suggestions (Layer 1) should appear as distinct cards on the dashboard, utilizing the Success (Green) or Warning (Red) accent colors sparingly to denote the nature of the finding.
    *   **Structure:** Observation -> Correlation -> Suggestion (as detailed in the feedback mechanism).
    *   **Dismissal:** Each card must have a small, unobtrusive "X" or "Dismiss" icon in the corner.
*   **Data Comparison View (Layer 3):** This "Deep Dive Lab" must provide a clean, configuration-heavy interface where users select metrics from clearly labeled dropdowns. The visual result should be a large, interactive graph immediately followed by the AI's textual Correlation Summary.

### 4.4. Interaction and Navigation

*   **Iconography:** Icons should be modern, line-based, and simple. They should appear in White when inactive and switch to the **Electric Blue Accent Color** when selected or active.
*   **Buttons/CTAs:** Primary Call-to-Action buttons (e.g., "Save Log," "Generate Report") must be solid blocks filled with the **Electric Blue Accent Color** with White text. Secondary actions should use outlined buttons using the Accent Color border.
*   **Gamification Avoidance:** Absolutely no visual noise, leaderboards, badges, bright pulsing colors, or excessive "celebratory" animations that detract from the analytical focus. Progress should be shown via quantifiable data shifts, not decorative feedback.

## 5. Data Visualization Component Guidelines

All graphs must be built to support future cross-referencing capabilities.

| Component | Guideline | Example Metric |
| :--- | :--- | :--- |
| **Line Graph (Trend)** | Use smooth lines. X-axis represents time (Date). Y-axis represents value. Primary metric should be the boldest visual element. | 30-Day e1RM Progression |
| **Bar Graph (Adherence)** | Used for daily tracking (7-Day view). A vertical bar for each day. Color indicates status (e.g., Blue if target met, Gray if target missed). | Daily Calorie Intake vs. Target |
| **Dual-Axis Line Graph** | Used for direct correlation (30-Day view). Metric 1 (e.g., Volume) uses Electric Blue. Metric 2 (e.g., Calories) uses Light Gray or a secondary subtle color, clearly mapped to its corresponding Y-axis. | Weekly Volume vs. Avg. Daily Calories |
| **Data Point Markers** | Small, circular markers on line graphs indicating specific logged events (e.g., a weigh-in, a completed workout). White or Accent Colored. | |
