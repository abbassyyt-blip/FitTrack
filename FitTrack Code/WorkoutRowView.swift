//
//  WorkoutRowView.swift
//  FitTrack Code
//
//  Created by Hadi Abbas on 11/9/25.
//

import SwiftUI

struct WorkoutRowView: View {
    let workout: Workout
    let isSelected: Bool
    let isSelectionMode: Bool
    @Binding var swipedWorkoutId: UUID?
    var onTap: () -> Void
    var onLongPress: () -> Void
    var onDelete: () -> Void
    
    // State to track the swipe
    @State private var swipeOffset: CGFloat = 0
    @State private var showNotes = false
    @State private var justLongPressed = false
    @GestureState private var isPressing = false
    
    // Max distance for the swipe
    private let deleteButtonWidth: CGFloat = 100
    
    // Check if workout has exercises (to show summary button)
    private var hasExercises: Bool {
        !workout.exercises.isEmpty
    }
    
    var body: some View {
        // Use GeometryReader to get the parent's full width
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                // 0. CARD BACKGROUND (bottom layer)
                // This creates the card appearance with rounded corners
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("SecondaryBackground"))
                    .frame(width: geo.size.width, height: geo.size.height)
                
                // 1. THE CUSTOM DELETE BUTTON
                // This is the custom red ZStack with a trash icon
                // It sits above the background but below the content
                if !isSelectionMode {
                    deleteButtonView
                        .frame(width: deleteButtonWidth)
                        // We move it into view from the right
                        .offset(x: deleteButtonWidth + (swipeOffset >= 0 ? 0 : swipeOffset))
                        .onTapGesture {
                            onDelete()
                            resetSwipe()
                        }
                }

                // 2. THE ROW CONTENT (ANIMATED)
                // This sits on the top layer
                Group {
                    if isSelectionMode {
                        rowContentView
                            .frame(width: geo.size.width + swipeOffset)
                            .position(
                                x: (geo.size.width / 2) + swipeOffset / 2,
                                y: geo.size.height / 2
                            )
                    } else {
                        rowContentView
                            .frame(width: geo.size.width + swipeOffset)
                            .position(
                                x: (geo.size.width / 2) + swipeOffset / 2,
                                y: geo.size.height / 2
                            )
                            .highPriorityGesture(dragGesture(parentWidth: geo.size.width))
                    }
                }
            }
            .cornerRadius(15) // Use a nice, high corner radius
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: swipeOffset)
            // This clip is important! It stops the delete button
            // from being visible until it's swiped in.
            .clipped()
        }
        .frame(height: hasExercises && !isSelectionMode ? 90 : 70) // Adjust height if summary button is shown
        // --- CARD SHADOW FOR SEPARATION FROM BACKGROUND ---
        .shadow(
            color: .black.opacity(0.1), // Reduced shadow for subtle separation
            radius: 6, // Reduced shadow blur radius
            x: 0,
            y: 3 // Shadow offset downward
        )
        .onChange(of: isSelectionMode) { oldValue, newValue in
            if newValue {
                // Reset swipe when entering selection mode
                resetSwipe()
            }
        }
        .onChange(of: swipedWorkoutId) { oldValue, newValue in
            // If swipedWorkoutId is set to nil or a different workout ID, reset this row's swipe
            if newValue != workout.id {
                // Reset if this row is currently swiped open
                if swipeOffset < 0 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        swipeOffset = 0
                    }
                }
            }
        }
    }
    
    // --- Subviews ---
    
    private var rowContentView: some View {
        HStack(alignment: .center, spacing: 16) {
            // Selection checkbox
            if isSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? Color(red: 0.0, green: 0.5, blue: 1.0) : Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.3))
                    .padding(.leading, 16)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    // Workout Name on the left
                    Text(workout.workoutName)
                        .font(.headline)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    
                    Spacer()
                    
                    // Calories on the right (negative, flame color)
                    Text("-\(workout.estimatedCalories) cal")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                }
                .padding(.horizontal)
                .padding(.top, hasExercises && !isSelectionMode ? 16 : 0)
                .padding(.bottom, hasExercises && !isSelectionMode ? 0 : 0)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    // Always allow taps - the onTap handler will check if we're in selection mode
                    onTap()
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .updating($isPressing) { currentState, gestureState, _ in
                            // Only update pressing state when not in selection mode
                            if !isSelectionMode {
                                gestureState = true
                            }
                        }
                        .onEnded { _ in
                            // Only handle long press when not in selection mode
                            if !isSelectionMode {
                                // Long press detected - call immediately for instant feedback
                                justLongPressed = true
                                onLongPress()
                                // Reset flag after delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    justLongPressed = false
                                }
                            }
                        }
                )
                .scaleEffect(isPressing && !isSelectionMode ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressing)
                
                // Summary button (show if there are exercises)
                if hasExercises && !isSelectionMode {
                    Button(action: {
                        showNotes = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "note.text")
                                .font(.caption)
                            Text("View Summary")
                                .font(.caption)
                        }
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
                        .padding(.horizontal)
                        .padding(.top, 2)
                        .padding(.bottom, 16)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .sheet(isPresented: $showNotes) {
            NotesView(workout: workout)
        }
    }
    
    private var deleteButtonView: some View {
        ZStack {
            Color.red
            Image(systemName: "trash.fill")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
    
    // --- Gesture Logic ---
    
    private func dragGesture(parentWidth: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // Only allow swiping left and only if not in selection mode
                if !isSelectionMode && value.translation.width < 0 {
                    // Apply stretch limit: hard clamp to prevent red button from being cut off
                    // The swipe offset is clamped to never exceed the delete button width
                    swipeOffset = max(-deleteButtonWidth, value.translation.width)
                } else if !isSelectionMode {
                    // If swiping right, allow closing if swipe is currently open
                    // Otherwise prevent swiping right
                    if swipeOffset < 0 {
                        // Swipe is open, allow closing by swiping right
                        // Since translation.width is relative to gesture start, we need to
                        // calculate based on current offset
                        let newOffset = swipeOffset + value.translation.width
                        swipeOffset = min(0, max(-deleteButtonWidth, newOffset))
                    } else {
                        // Swipe is closed, prevent swiping right
                        swipeOffset = 0
                    }
                }
            }
            .onEnded { value in
                // Only handle if not in selection mode
                if !isSelectionMode {
                    // Check if we should keep it open or close it
                    let finalOffset = swipeOffset
                    if finalOffset < -deleteButtonWidth / 2 {
                        // Snap to fully open
                        swipeOffset = -deleteButtonWidth
                        // Notify parent that this workout is now swiped open
                        swipedWorkoutId = workout.id
                    } else {
                        // Snap back to closed
                        resetSwipe()
                    }
                }
            }
    }
    
    private func resetSwipe() {
        withAnimation {
            swipeOffset = 0
        }
        // Clear the swiped workout ID if this was the swiped workout
        // Only clear if we're the one that's currently tracked
        if swipedWorkoutId == workout.id {
            swipedWorkoutId = nil
        }
    }
}

// Notes View - displays comprehensive workout/cardio summary
struct NotesView: View {
    let workout: Workout
    @Environment(\.dismiss) var dismiss
    
    // Sort exercises by order
    private var sortedExercises: [WorkoutExercise] {
        workout.exercises.sorted(by: { $0.order < $1.order })
    }
    
    // Date formatter
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
    
    // Time formatter
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
    
    // Duration string
    private var durationString: String {
        if workout.durationHours > 0 && workout.durationMinutes > 0 {
            return "\(workout.durationHours)h \(workout.durationMinutes)m"
        } else if workout.durationHours > 0 {
            return "\(workout.durationHours)h"
        } else {
            return "\(workout.durationMinutes)m"
        }
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(workout.activityType == .cardio ? "Cardio Summary" : "Workout Summary")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Basic Info Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Overview")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(label: "Name", value: workout.workoutName)
                                InfoRow(label: "Date", value: dateFormatter.string(from: workout.workoutDate))
                                InfoRow(label: "Time", value: timeFormatter.string(from: workout.workoutDate))
                                InfoRow(label: "Duration", value: durationString)
                                InfoRow(label: "Overall RPE", value: "\(Int(workout.overallRPE))/10")
                                InfoRow(label: "Estimated Calories", value: "-\(workout.estimatedCalories) cal", valueColor: Color(red: 1.0, green: 0.5, blue: 0.0))
                            }
                        }
                        .padding()
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(12)
                        
                        // Exercises/Intervals Section
                        if !sortedExercises.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(workout.activityType == .cardio ? "Intervals" : "Exercises")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                ForEach(sortedExercises) { exercise in
                                    ExerciseSummaryCard(
                                        exercise: exercise,
                                        isCardio: workout.activityType == .cardio
                                    )
                                }
                            }
                            .padding()
                            .background(Color("SecondaryBackground"))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// Info Row Component
struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = Color(red: 0.0, green: 0.5, blue: 1.0)
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

// Exercise Summary Card
struct ExerciseSummaryCard: View {
    let exercise: WorkoutExercise
    let isCardio: Bool
    
    // Sort sets by order (they should already be in order, but just in case)
    private var sortedSets: [WorkoutSet] {
        exercise.sets
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise/Interval Name
            Text(exercise.name)
                .font(.headline)
                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
            
            // Sets/Intervals
            if !sortedSets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(sortedSets.enumerated()), id: \.element.id) { index, set in
                        if isCardio {
                            // Cardio interval display
                            CardioSetSummary(set: set, setNumber: index + 1)
                        } else {
                            // Strength training set display
                            StrengthSetSummary(set: set, setNumber: index + 1)
                        }
                    }
                }
            }
            
            // Notes
            if !exercise.notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes:")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
                    
                    Text(exercise.notes)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color("PrimaryBackground").opacity(0.5))
        .cornerRadius(10)
    }
}

// Strength Training Set Summary
struct StrengthSetSummary: View {
    let set: WorkoutSet
    let setNumber: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Set \(setNumber):")
                .font(.caption)
                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
            
            if !set.weight.isEmpty && !set.reps.isEmpty {
                Text("\(set.weight) × \(set.reps) reps")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
            }
            
            if let rpe = set.rpe {
                Text("RPE: \(Int(rpe))")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
            }
        }
    }
}

// Cardio Interval Summary
struct CardioSetSummary: View {
    let set: WorkoutSet
    let setNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Interval \(setNumber):")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
            
            HStack(spacing: 12) {
                if !set.weight.isEmpty {
                    Text("Distance: \(set.weight)")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.8))
                }
                
                if !set.reps.isEmpty {
                    Text("Duration: \(set.reps) min")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.8))
                }
                
                if let pace = set.rpe, pace > 0 {
                    Text("Pace: \(String(format: "%.1f", pace))")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.8))
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color("PrimaryBackground").edgesIgnoringSafeArea(.all)
        WorkoutRowView(
            workout: Workout(
                workoutName: "Preview Workout",
                workoutDate: Date(),
                durationHours: 1,
                durationMinutes: 30,
                overallRPE: 7.0,
                estimatedCalories: 450
            ),
            isSelected: false,
            isSelectionMode: false,
            swipedWorkoutId: .constant(nil),
            onTap: {},
            onLongPress: {},
            onDelete: {}
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}

