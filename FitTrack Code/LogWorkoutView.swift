//
//  LogWorkoutView.swift
//  FitTrack Code
//
//  Created by Hadi Abbas on 11/9/25.
//

import SwiftUI
import SwiftData

// Weight unit enum
enum WeightUnit: String, CaseIterable {
    case lbs = "lbs"
    case kg = "kg"
    
    var displayName: String {
        return self.rawValue
    }
}

// Focus state enum for keyboard management
enum FocusedField: Hashable {
    case workoutName
    case exerciseName(Int) // Index of exercise
    case weight(Int, Int) // Exercise index, Set index
    case reps(Int, Int) // Exercise index, Set index
    case notes(Int) // Exercise index
}

// Temporary data models for UI (converted to SwiftData models on save)
struct WorkoutSetEntry: Identifiable {
    let id = UUID()
    var weight: String = ""
    var reps: String = ""
    var rpe: Double? = nil
    
    init(weight: String = "", reps: String = "", rpe: Double? = nil) {
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
    }
}

struct ExerciseEntry: Identifiable {
    let id = UUID()
    var name: String = ""
    var sets: [WorkoutSetEntry] = [WorkoutSetEntry()]
    var notes: String = ""
    
    init(name: String = "", sets: [WorkoutSetEntry] = [WorkoutSetEntry()], notes: String = "") {
        self.name = name
        self.sets = sets
        self.notes = notes
    }
}

struct LogWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Optional workout to edit (nil for new workout)
    var workoutToEdit: Workout?
    
    // Workout-level inputs
    @State private var workoutName: String = ""
    @State private var workoutDate: Date = Date()
    @State private var isDatePickerShowing = false
    @State private var durationHours: Int = 0
    @State private var durationMinutes: Int = 0
    @State private var overallRPE: Double = 5.0
    @State private var weightUnit: WeightUnit = .lbs
    
    // Exercises list
    @State private var exercises: [ExerciseEntry] = []
    
    // Focus state for keyboard management
    @FocusState private var focusedField: FocusedField?
    
    init(workoutToEdit: Workout? = nil) {
        self.workoutToEdit = workoutToEdit
    }
    
    // Computed properties for formatted date and time
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: workoutDate)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: workoutDate)
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                        }
                        
                        Spacer()
                        
                        Text(workoutToEdit == nil ? "Log Strength Training" : "Edit Workout")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                        
                        Spacer()
                        
                        Button(action: {
                            saveWorkout()
                        }) {
                            Text("Save")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // 1. Workout Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Workout Details")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Workout Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Workout Name")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                TextField("e.g., Push Day", text: $workoutName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                    .focused($focusedField, equals: .workoutName)
                            }
                            
                            // Date & Time
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date & Time")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                // Custom Date & Time buttons
                                HStack(spacing: 12) {
                                    // Custom Date Text
                                    Text(formattedDate)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 14)
                                        .background(Color("SecondaryBackground"))
                                        .cornerRadius(10)
                                    
                                    // Custom Time Text
                                    Text(formattedTime)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 14)
                                        .background(Color("SecondaryBackground"))
                                        .cornerRadius(10)
                                }
                                .onTapGesture {
                                    isDatePickerShowing = true
                                }
                            }
                            
                            // Duration
                            HStack(alignment: .center, spacing: 16) {
                                Text("Duration")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                Menu {
                                    ForEach(0..<24) { hour in
                                        Button(action: {
                                            durationHours = hour
                                        }) {
                                            Text("\(hour)")
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("\(durationHours)")
                                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                        Text("hrs")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                        Image(systemName: "chevron.down")
                                            .font(.caption2)
                                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color("PrimaryBackground").opacity(0.5))
                                    .cornerRadius(6)
                                }
                                
                                Menu {
                                    ForEach(0..<60) { minute in
                                        Button(action: {
                                            durationMinutes = minute
                                        }) {
                                            Text("\(minute)")
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("\(durationMinutes)")
                                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                        Text("min")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                        Image(systemName: "chevron.down")
                                            .font(.caption2)
                                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color("PrimaryBackground").opacity(0.5))
                                    .cornerRadius(6)
                                }
                                
                                Spacer()
                            }
                            
                            // Overall RPE
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Overall RPE: \(Int(overallRPE))")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                HStack {
                                    Text("1")
                                        .font(.caption)
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                    
                                    Slider(value: $overallRPE, in: 1...10, step: 1)
                                        .accentColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                    
                                    Text("10")
                                        .font(.caption)
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                }
                            }
                        }
                        .padding()
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // 2. Exercises Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Exercises")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            
                            Spacer()
                            
                            Button(action: {
                                exercises.append(ExerciseEntry())
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Exercise")
                                }
                                .font(.subheadline)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            }
                        }
                        .padding(.horizontal)
                        
                        if exercises.isEmpty {
                            VStack(spacing: 8) {
                                Text("No exercises added yet")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                Text("Tap 'Add Exercise' to get started")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color("SecondaryBackground"))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            ForEach(exercises.indices, id: \.self) { exerciseIndex in
                                ExerciseCardView(
                                    exercise: $exercises[exerciseIndex],
                                    exerciseIndex: exerciseIndex,
                                    weightUnit: $weightUnit,
                                    focusedField: $focusedField,
                                    onDelete: {
                                        exercises.remove(at: exerciseIndex)
                                    }
                                )
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .onTapGesture {
                focusedField = nil
            }
        }
        .sheet(isPresented: $isDatePickerShowing) {
            VStack {
                Text("Select Date & Time")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .padding(.top)
                
                DatePicker(
                    "Select Date & Time",
                    selection: $workoutDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()
                .accentColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                .tint(Color(red: 0.0, green: 0.5, blue: 1.0))
                
                Button("Done") {
                    isDatePickerShowing = false
                }
                .font(.body)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.0, green: 0.5, blue: 1.0))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
            .background(Color("PrimaryBackground"))
            .presentationDetents([.medium])
        }
        .onAppear {
            loadWorkoutData()
        }
    }
    
    private func loadWorkoutData() {
        guard let workout = workoutToEdit else { return }
        
        workoutName = workout.workoutName
        workoutDate = workout.workoutDate
        durationHours = workout.durationHours
        durationMinutes = workout.durationMinutes
        overallRPE = workout.overallRPE
        
        // Load exercises in order
        exercises = workout.exercises
            .sorted(by: { $0.order < $1.order })
            .map { exercise in
                let sets = exercise.sets.map { set in
                    WorkoutSetEntry(
                        weight: set.weight,
                        reps: set.reps,
                        rpe: set.rpe
                    )
                }
                return ExerciseEntry(
                    name: exercise.name,
                    sets: sets.isEmpty ? [WorkoutSetEntry()] : sets,
                    notes: exercise.notes
                )
            }
        
        if exercises.isEmpty {
            exercises = [ExerciseEntry()]
        }
    }
    
    private func saveWorkout() {
        // Convert UI models to SwiftData models
        var workoutExercises: [WorkoutExercise] = []
        
        for (index, exercise) in exercises.enumerated() {
            var workoutSets: [WorkoutSet] = []

            for set in exercise.sets {
                let workoutSet = WorkoutSet(
                    weight: set.weight,
                    reps: set.reps,
                    rpe: set.rpe
                )
                modelContext.insert(workoutSet)
                workoutSets.append(workoutSet)
            }
            
            let workoutExercise = WorkoutExercise(
                name: exercise.name.isEmpty ? "Unnamed Exercise" : exercise.name,
                notes: exercise.notes,
                order: index,
                sets: workoutSets
            )
            modelContext.insert(workoutExercise)
            workoutExercises.append(workoutExercise)
        }
        
        // Calculate estimated calories
        let totalMinutes = durationHours * 60 + durationMinutes
        let estimatedCalories = Workout.calculateEstimatedCalories(durationMinutes: totalMinutes, rpe: overallRPE)
        
        if let existingWorkout = workoutToEdit {
            // Update existing workout
            existingWorkout.workoutName = workoutName.isEmpty ? "Untitled Workout" : workoutName
            existingWorkout.workoutDate = workoutDate
            existingWorkout.durationHours = durationHours
            existingWorkout.durationMinutes = durationMinutes
            existingWorkout.overallRPE = overallRPE
            existingWorkout.estimatedCalories = estimatedCalories
            existingWorkout.activityType = .strength
            
            // Delete old exercises and sets (cascade will handle sets)
            for exercise in existingWorkout.exercises {
                modelContext.delete(exercise)
            }
            
            // Add new exercises (already inserted in the loop above)
            existingWorkout.exercises = workoutExercises
        } else {
            // Create new workout (exercises already inserted in the loop above)
            let workout = Workout(
                workoutName: workoutName.isEmpty ? "Untitled Workout" : workoutName,
                workoutDate: workoutDate,
                durationHours: durationHours,
                durationMinutes: durationMinutes,
                overallRPE: overallRPE,
                estimatedCalories: estimatedCalories,
                activityType: .strength,
                exercises: workoutExercises
            )
            
            // Save to SwiftData (SwiftData auto-saves changes)
            modelContext.insert(workout)
        }
        
        // Dismiss the view
        dismiss()
    }
}

// Exercise Card View
struct ExerciseCardView: View {
    @Binding var exercise: ExerciseEntry
    var exerciseIndex: Int
    @Binding var weightUnit: WeightUnit
    @FocusState.Binding var focusedField: FocusedField?
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Exercise Header
            HStack {
                TextField("Exercise Name", text: $exercise.name)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($focusedField, equals: .exerciseName(exerciseIndex))
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Sets List
            VStack(alignment: .leading, spacing: 12) {
                ForEach(exercise.sets.indices, id: \.self) { setIndex in
                    SetRowView(
                        set: $exercise.sets[setIndex],
                        setNumber: setIndex + 1,
                        exerciseIndex: exerciseIndex,
                        setIndex: setIndex,
                        weightUnit: $weightUnit,
                        focusedField: $focusedField,
                        onDelete: {
                            exercise.sets.remove(at: setIndex)
                        }
                    )
                }
                
                Button(action: {
                    exercise.sets.append(WorkoutSetEntry())
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Set")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                }
            }
            
            // Optional: Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (Optional)")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                
                TextField("e.g., Paused reps, felt a twinge...", text: $exercise.notes, axis: .vertical)
                    .textFieldStyle(CustomTextFieldStyle())
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .lineLimit(3...6)
                    .focused($focusedField, equals: .notes(exerciseIndex))
            }
        }
        .padding()
        .background(Color("SecondaryBackground"))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Set Row View
struct SetRowView: View {
    @Binding var set: WorkoutSetEntry
    var setNumber: Int
    var exerciseIndex: Int
    var setIndex: Int
    @Binding var weightUnit: WeightUnit
    @FocusState.Binding var focusedField: FocusedField?
    var onDelete: () -> Void
    
    // State to track the swipe (only for additional sets)
    @State private var swipeOffset: CGFloat = 0
    
    // Max distance for the swipe
    private let deleteButtonWidth: CGFloat = 80
    
    // Only enable swipe for additional sets (setNumber > 1)
    private var isSwipeable: Bool {
        setNumber > 1
    }
    
    var body: some View {
        if isSwipeable {
            // Custom swipe animation for additional sets
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // 1. THE CUSTOM DELETE BUTTON (behind, slides in from right)
                    deleteButtonView
                        .frame(width: deleteButtonWidth)
                        .offset(x: geo.size.width + swipeOffset)
                        .onTapGesture {
                            onDelete()
                            resetSwipe()
                        }
                    
                    // 2. THE SET CONTENT (ANIMATED, compresses from right)
                    HStack(spacing: 0) {
                        setContentView
                            .padding(.vertical, 8)
                        
                        Spacer()
                    }
                    .frame(width: max(0, geo.size.width + swipeOffset), alignment: .leading)
                    .background(
                        Color("PrimaryBackground").opacity(0.5)
                            .frame(width: max(0, geo.size.width + swipeOffset))
                            .padding(.horizontal, -12)
                    )
                    .gesture(dragGesture(parentWidth: geo.size.width))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(8)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: swipeOffset)
                .clipped()
                .onTapGesture {
                    if swipeOffset < 0 {
                        resetSwipe()
                    }
                }
            }
            .frame(height: calculateContentHeight())
        } else {
            // Regular view for the first set (no swipe)
            HStack(spacing: 0) {
                setContentView
                    .padding(.vertical, 8)
                
                Spacer()
            }
            .background(
                Color("PrimaryBackground").opacity(0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, -12)
            )
            .cornerRadius(8)
        }
    }
    
    // --- Subviews ---
    
    private var setContentView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Text("Set \(setNumber):")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .frame(width: 60, alignment: .leading)
                
                // Weight Input
                HStack(spacing: 4) {
                    TextField("0", text: $set.weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(SetTextFieldStyle())
                        .focused($focusedField, equals: .weight(exerciseIndex, setIndex))
                    
                    Menu {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Button(action: {
                                weightUnit = unit
                            }) {
                                HStack {
                                    Text(unit.displayName)
                                    if weightUnit == unit {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(weightUnit.displayName)
                            .font(.caption)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    }
                }
                .frame(maxWidth: .infinity)
                
                Text("for")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                
                // Reps Input
                HStack(spacing: 4) {
                    TextField("0", text: $set.reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(SetTextFieldStyle())
                        .focused($focusedField, equals: .reps(exerciseIndex, setIndex))
                    
                    Text("reps")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                }
                .frame(maxWidth: .infinity)
            }
            
            // Optional RPE for this set
            HStack {
                Text("RPE:")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                
                if set.rpe != nil {
                    Slider(value: Binding(
                        get: { set.rpe ?? 5.0 },
                        set: { set.rpe = $0 }
                    ), in: 1...10, step: 1)
                    .accentColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .frame(maxWidth: .infinity)
                    
                    Text("\(Int(set.rpe ?? 5.0))")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                        .frame(width: 20)
                    
                    Button(action: {
                        set.rpe = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
                    }
                } else {
                    Button(action: {
                        set.rpe = 5.0
                    }) {
                        Text("Add RPE")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color("PrimaryBackground").opacity(0.5))
        .cornerRadius(8)
    }
    
    private var deleteButtonView: some View {
        ZStack {
            Color.red
            Image(systemName: "trash.fill")
                .font(.title3)
                .foregroundColor(.white)
        }
    }
    
    // --- Gesture Logic ---
    
    private func dragGesture(parentWidth: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // Only allow swiping left
                if value.translation.width < 0 {
                    swipeOffset = max(-deleteButtonWidth, value.translation.width)
                } else {
                    // Prevent swiping right
                    swipeOffset = 0
                }
            }
            .onEnded { value in
                if value.translation.width < -deleteButtonWidth / 2 {
                    // Snap to fully open
                    swipeOffset = -deleteButtonWidth
                } else {
                    // Snap back to closed
                    resetSwipe()
                }
            }
    }
    
    private func resetSwipe() {
        swipeOffset = 0
    }
    
    private func calculateContentHeight() -> CGFloat {
        // Approximate height based on content (VStack with HStack + RPE row)
        return 80
    }
}

// Custom Text Field Styles
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color("PrimaryBackground").opacity(0.5))
            .cornerRadius(8)
    }
}

struct SetTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(8)
            .background(Color("PrimaryBackground").opacity(0.3))
            .cornerRadius(6)
            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
            .multilineTextAlignment(.center)
    }
}

#Preview {
    LogWorkoutView()
}

