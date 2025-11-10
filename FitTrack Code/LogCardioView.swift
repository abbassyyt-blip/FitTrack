//
//  LogCardioView.swift
//  FitTrack Code
//
//  Created by Hadi Abbas on 11/9/25.
//

import SwiftUI
import SwiftData

// Distance unit enum
enum DistanceUnit: String, CaseIterable {
    case miles = "mi"
    case kilometers = "km"
    
    var displayName: String {
        return self.rawValue
    }
}

// Cardio set entry (for intervals)
struct CardioSetEntry: Identifiable {
    let id = UUID()
    var distance: String = ""
    var durationMinutes: Int = 0
    var durationSeconds: Int = 0
    var pace: String = ""
    var heartRate: String = ""
    var notes: String = ""
    
    init(distance: String = "", durationMinutes: Int = 0, durationSeconds: Int = 0, pace: String = "", heartRate: String = "", notes: String = "") {
        self.distance = distance
        self.durationMinutes = durationMinutes
        self.durationSeconds = durationSeconds
        self.pace = pace
        self.heartRate = heartRate
        self.notes = notes
    }
}

// Cardio activity entry
struct CardioActivityEntry: Identifiable {
    let id = UUID()
    var name: String = ""
    var sets: [CardioSetEntry] = [CardioSetEntry()]
    var notes: String = ""
    
    init(name: String = "", sets: [CardioSetEntry] = [CardioSetEntry()], notes: String = "") {
        self.name = name
        self.sets = sets
        self.notes = notes
    }
}

// Focus state enum for keyboard management
enum CardioFocusedField: Hashable {
    case activityName
    case activityNameIndex(Int)
    case distance(Int, Int)
    case pace(Int, Int)
    case heartRate(Int, Int)
    case notes(Int)
}

struct LogCardioView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Optional workout to edit (nil for new workout)
    var workoutToEdit: Workout?
    
    // Activity-level inputs
    @State private var activityName: String = ""
    @State private var activityDate: Date = Date()
    @State private var isDatePickerShowing = false
    @State private var durationHours: Int = 0
    @State private var durationMinutes: Int = 0
    @State private var overallRPE: Double = 5.0
    @State private var distanceUnit: DistanceUnit = .miles
    @State private var totalDistance: String = ""
    @State private var averagePace: String = ""
    @State private var averageHeartRate: String = ""
    
    // Activities list (for interval training)
    @State private var activities: [CardioActivityEntry] = []
    
    // Focus state for keyboard management
    @FocusState private var focusedField: CardioFocusedField?
    
    init(workoutToEdit: Workout? = nil) {
        self.workoutToEdit = workoutToEdit
    }
    
    // Computed properties for formatted date and time
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: activityDate)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: activityDate)
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
                        
                        Text(workoutToEdit == nil ? "Log Cardio" : "Edit Cardio")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                        
                        Spacer()
                        
                        Button(action: {
                            saveCardio()
                        }) {
                            Text("Save")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // 1. Activity Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Activity Details")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Activity Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Activity Name")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                TextField("e.g., Morning Run", text: $activityName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                    .focused($focusedField, equals: .activityName)
                            }
                            
                            // Date & Time
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date & Time")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                HStack(spacing: 12) {
                                    Text(formattedDate)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 14)
                                        .background(Color("SecondaryBackground"))
                                        .cornerRadius(10)
                                    
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
                            
                            // Distance
                            HStack(alignment: .center, spacing: 16) {
                                Text("Distance")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                HStack(spacing: 4) {
                                    TextField("0", text: $totalDistance)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(SetTextFieldStyle())
                                        .frame(width: 60)
                                    
                                    Menu {
                                        ForEach(DistanceUnit.allCases, id: \.self) { unit in
                                            Button(action: {
                                                distanceUnit = unit
                                            }) {
                                                HStack {
                                                    Text(unit.displayName)
                                                    if distanceUnit == unit {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        Text(distanceUnit.displayName)
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color("PrimaryBackground").opacity(0.5))
                                .cornerRadius(6)
                                
                                Spacer()
                            }
                            
                            // Average Pace (Optional)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Average Pace (Optional)")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                TextField("e.g., 8:30", text: $averagePace)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            }
                            
                            // Average Heart Rate (Optional)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Average Heart Rate (Optional)")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                HStack(spacing: 4) {
                                    TextField("0", text: $averageHeartRate)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                    
                                    Text("bpm")
                                        .font(.caption)
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                }
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
                    
                    // 2. Intervals Section (Optional)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Intervals (Optional)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            
                            Spacer()
                            
                            Button(action: {
                                activities.append(CardioActivityEntry())
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Interval")
                                }
                                .font(.subheadline)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            }
                        }
                        .padding(.horizontal)
                        
                        if activities.isEmpty {
                            VStack(spacing: 8) {
                                Text("No intervals added yet")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                Text("Tap 'Add Interval' to track interval training")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color("SecondaryBackground"))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            ForEach(activities.indices, id: \.self) { activityIndex in
                                CardioActivityCardView(
                                    activity: $activities[activityIndex],
                                    activityIndex: activityIndex,
                                    distanceUnit: $distanceUnit,
                                    focusedField: $focusedField,
                                    onDelete: {
                                        activities.remove(at: activityIndex)
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
                    selection: $activityDate,
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
            loadCardioData()
        }
    }
    
    private func loadCardioData() {
        guard let workout = workoutToEdit else { return }
        
        activityName = workout.workoutName
        activityDate = workout.workoutDate
        durationHours = workout.durationHours
        durationMinutes = workout.durationMinutes
        overallRPE = workout.overallRPE
        
        // Load exercises as activities (for intervals)
        activities = workout.exercises
            .sorted(by: { $0.order < $1.order })
            .map { exercise in
                let sets = exercise.sets.map { set in
                    CardioSetEntry(
                        distance: set.weight, // Reusing weight field for distance
                        durationMinutes: Int(set.reps) ?? 0, // Reusing reps for duration minutes
                        pace: set.rpe != nil ? String(set.rpe!) : "",
                        notes: exercise.notes
                    )
                }
                return CardioActivityEntry(
                    name: exercise.name,
                    sets: sets.isEmpty ? [CardioSetEntry()] : sets,
                    notes: exercise.notes
                )
            }
        
        if activities.isEmpty {
            activities = [CardioActivityEntry()]
        }
    }
    
    private func saveCardio() {
        // Convert UI models to SwiftData models
        var workoutExercises: [WorkoutExercise] = []
        
        for (index, activity) in activities.enumerated() {
            var workoutSets: [WorkoutSet] = []
            
            for set in activity.sets {
                let workoutSet = WorkoutSet(
                    weight: set.distance, // Store distance in weight field
                    reps: "\(set.durationMinutes)", // Store duration in reps field
                    rpe: Double(set.pace) // Store pace in rpe field (if numeric)
                )
                modelContext.insert(workoutSet)
                workoutSets.append(workoutSet)
            }
            
            let workoutExercise = WorkoutExercise(
                name: activity.name.isEmpty ? "Unnamed Activity" : activity.name,
                notes: activity.notes,
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
            existingWorkout.workoutName = activityName.isEmpty ? "Untitled Cardio" : activityName
            existingWorkout.workoutDate = activityDate
            existingWorkout.durationHours = durationHours
            existingWorkout.durationMinutes = durationMinutes
            existingWorkout.overallRPE = overallRPE
            existingWorkout.estimatedCalories = estimatedCalories
            existingWorkout.activityType = .cardio
            
            // Delete old exercises and sets (cascade will handle sets)
            for exercise in existingWorkout.exercises {
                modelContext.delete(exercise)
            }
            
            // Add new exercises (already inserted in the loop above)
            existingWorkout.exercises = workoutExercises
        } else {
            // Create new workout (exercises already inserted in the loop above)
            let workout = Workout(
                workoutName: activityName.isEmpty ? "Untitled Cardio" : activityName,
                workoutDate: activityDate,
                durationHours: durationHours,
                durationMinutes: durationMinutes,
                overallRPE: overallRPE,
                estimatedCalories: estimatedCalories,
                activityType: .cardio,
                exercises: workoutExercises
            )
            
            // Save to SwiftData (SwiftData auto-saves changes)
            modelContext.insert(workout)
        }
        
        // Dismiss the view
        dismiss()
    }
}

// Cardio Activity Card View
struct CardioActivityCardView: View {
    @Binding var activity: CardioActivityEntry
    var activityIndex: Int
    @Binding var distanceUnit: DistanceUnit
    @FocusState.Binding var focusedField: CardioFocusedField?
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Activity Header
            HStack {
                TextField("Interval Name", text: $activity.name)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($focusedField, equals: .activityNameIndex(activityIndex))
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Sets List
            VStack(alignment: .leading, spacing: 12) {
                ForEach(activity.sets.indices, id: \.self) { setIndex in
                    CardioSetRowView(
                        set: $activity.sets[setIndex],
                        setNumber: setIndex + 1,
                        activityIndex: activityIndex,
                        setIndex: setIndex,
                        distanceUnit: $distanceUnit,
                        focusedField: $focusedField,
                        onDelete: {
                            activity.sets.remove(at: setIndex)
                        }
                    )
                }
                
                Button(action: {
                    activity.sets.append(CardioSetEntry())
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
                
                TextField("e.g., Felt strong, good weather...", text: $activity.notes, axis: .vertical)
                    .textFieldStyle(CustomTextFieldStyle())
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .lineLimit(3...6)
                    .focused($focusedField, equals: .notes(activityIndex))
            }
        }
        .padding()
        .background(Color("SecondaryBackground"))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Cardio Set Row View (with swipe animation)
struct CardioSetRowView: View {
    @Binding var set: CardioSetEntry
    var setNumber: Int
    var activityIndex: Int
    var setIndex: Int
    @Binding var distanceUnit: DistanceUnit
    @FocusState.Binding var focusedField: CardioFocusedField?
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
            // Distance
            HStack(spacing: 12) {
                Text("Distance:")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .frame(width: 80, alignment: .leading)
                
                HStack(spacing: 4) {
                    TextField("0", text: $set.distance)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(SetTextFieldStyle())
                        .focused($focusedField, equals: .distance(activityIndex, setIndex))
                    
                    Menu {
                        ForEach(DistanceUnit.allCases, id: \.self) { unit in
                            Button(action: {
                                distanceUnit = unit
                            }) {
                                HStack {
                                    Text(unit.displayName)
                                    if distanceUnit == unit {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(distanceUnit.displayName)
                            .font(.caption)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Duration
            HStack(spacing: 12) {
                Text("Duration:")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .frame(width: 80, alignment: .leading)
                
                HStack(spacing: 4) {
                    Menu {
                        ForEach(0..<60) { minute in
                            Button(action: {
                                set.durationMinutes = minute
                            }) {
                                Text("\(minute)")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("\(set.durationMinutes)")
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            Text("min")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color("PrimaryBackground").opacity(0.3))
                        .cornerRadius(6)
                    }
                    
                    Text(":")
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    
                    Menu {
                        ForEach(0..<60) { second in
                            Button(action: {
                                set.durationSeconds = second
                            }) {
                                Text("\(second)")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(String(format: "%02d", set.durationSeconds))
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            Text("sec")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color("PrimaryBackground").opacity(0.3))
                        .cornerRadius(6)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Pace (Optional)
            HStack(spacing: 12) {
                Text("Pace:")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .frame(width: 80, alignment: .leading)
                
                TextField("e.g., 8:30", text: $set.pace)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(SetTextFieldStyle())
                    .focused($focusedField, equals: .pace(activityIndex, setIndex))
                    .frame(maxWidth: .infinity)
            }
            
            // Heart Rate (Optional)
            HStack(spacing: 12) {
                Text("Heart Rate:")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .frame(width: 80, alignment: .leading)
                
                HStack(spacing: 4) {
                    TextField("0", text: $set.heartRate)
                        .keyboardType(.numberPad)
                        .textFieldStyle(SetTextFieldStyle())
                        .focused($focusedField, equals: .heartRate(activityIndex, setIndex))
                    
                    Text("bpm")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
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
        // Approximate height based on content
        return 180
    }
}

#Preview {
    LogCardioView()
}

