//
//  ActivitiesView.swift
//  FitTrack Code
//
//  Created by Hadi Abbas on 11/9/25.
//

import SwiftUI
import SwiftData

struct ActivitiesView: View {
    @Query private var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    @State private var isMenuOpen = false
    @State private var showLogWorkout = false
    @State private var showLogCardio = false
    @State private var workoutToEdit: Workout? = nil
    @State private var selectedWorkouts: Set<UUID> = []
    @State private var isSelectionMode = false
    @State private var strengthSortOrder: SortOrder = .newestFirst
    @State private var cardioSortOrder: SortOrder = .newestFirst
    @State private var justLongPressedWorkoutId: UUID? = nil
    @State private var swipedWorkoutId: UUID? = nil
    
    enum SortOrder {
        case newestFirst
        case oldestFirst
    }
    
    // Filter and sort strength workouts
    private var strengthWorkouts: [Workout] {
        let filtered = workouts.filter { $0.activityType == nil || $0.activityType == .strength }
        switch strengthSortOrder {
        case .newestFirst:
            return filtered.sorted(by: { $0.workoutDate > $1.workoutDate })
        case .oldestFirst:
            return filtered.sorted(by: { $0.workoutDate < $1.workoutDate })
        }
    }
    
    // Filter and sort cardio workouts
    private var cardioWorkouts: [Workout] {
        let filtered = workouts.filter { $0.activityType == .cardio }
        switch cardioSortOrder {
        case .newestFirst:
            return filtered.sorted(by: { $0.workoutDate > $1.workoutDate })
        case .oldestFirst:
            return filtered.sorted(by: { $0.workoutDate < $1.workoutDate })
        }
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea(.all)
                .contentShape(Rectangle())
                .onTapGesture {
                    // Close menu when tapping outside
                    if isMenuOpen {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isMenuOpen = false
                        }
                    }
                    // Close selection mode when tapping outside
                    if isSelectionMode {
                        withAnimation {
                            isSelectionMode = false
                            selectedWorkouts.removeAll()
                        }
                    }
                    // Dismiss swipe-to-delete when tapping outside
                    if swipedWorkoutId != nil {
                        withAnimation {
                            swipedWorkoutId = nil
                        }
                    }
                }
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        if isSelectionMode {
                            Button(action: {
                                withAnimation {
                                    isSelectionMode = false
                                    selectedWorkouts.removeAll()
                                }
                            }) {
                                Text("Cancel")
                                    .font(.body)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            }
                            
                            Text("\(selectedWorkouts.count) selected")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            
                            Spacer()
                            
                            if !selectedWorkouts.isEmpty {
                                Menu {
                                    Button(role: .destructive, action: {
                                        deleteSelectedWorkouts()
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .font(.title2)
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                        .frame(minWidth: 44, minHeight: 44) // Minimum touch target size (Apple HIG recommends 44x44)
                                        .contentShape(Rectangle()) // Makes entire frame area tappable
                                }
                            }
                        } else {
                            Text("Activities")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, geometry.safeAreaInsets.top > 0 ? geometry.safeAreaInsets.top : 0)
                    .padding(.top, 8)
                
                // Workouts List
                if workouts.isEmpty {
                    GeometryReader { emptyGeometry in
                        VStack(spacing: 16) {
                            Spacer()
                                .frame(height: emptyGeometry.size.height / 3 - 50) // 1/3 from top, moved up 50px
                            VStack(spacing: 16) {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                Text("No workouts yet")
                                    .font(.title3)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                Text("Tap the + button to log your first workout")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
                            }
                            .frame(maxWidth: .infinity) // Center horizontally
                            Spacer()
                                .frame(height: emptyGeometry.size.height * 2 / 3 + 50) // 2/3 from bottom, adjusted for 50px up
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            // --- Custom, Sleek Section Header ---
                            if !strengthWorkouts.isEmpty {
                                HStack {
                                    Text("Strength Training")
                                        .font(.title2.bold())
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            strengthSortOrder = strengthSortOrder == .newestFirst ? .oldestFirst : .newestFirst
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.down")
                                                .font(.caption)
                                                .rotationEffect(.degrees(strengthSortOrder == .newestFirst ? 0 : 180))
                                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: strengthSortOrder)
                                            Text(strengthSortOrder == .newestFirst ? "Newest" : "Oldest")
                                                .font(.caption)
                                                .id(strengthSortOrder)
                                                .transition(.asymmetric(
                                                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                                                    removal: .opacity.combined(with: .scale(scale: 0.8))
                                                ))
                                        }
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .contentShape(Rectangle())
                                    }
                                }
                                .padding(.top, 10)
                                
                                // Strength Workouts Loop
                                ForEach(strengthWorkouts) { workout in
                                    WorkoutRowView(
                                        workout: workout,
                                        isSelected: selectedWorkouts.contains(workout.id),
                                        isSelectionMode: isSelectionMode,
                                        swipedWorkoutId: $swipedWorkoutId,
                                        onTap: {
                                            // Dismiss swipe-to-delete if another row is swiped open
                                            if swipedWorkoutId != nil && swipedWorkoutId != workout.id {
                                                withAnimation {
                                                    swipedWorkoutId = nil
                                                }
                                            }
                                            
                                            // Ignore tap only on the workout that was just long-pressed (to prevent unselecting)
                                            if justLongPressedWorkoutId == workout.id {
                                                return
                                            }
                                            
                                            if isSelectionMode {
                                                if selectedWorkouts.contains(workout.id) {
                                                    selectedWorkouts.remove(workout.id)
                                                } else {
                                                    selectedWorkouts.insert(workout.id)
                                                }
                                            } else {
                                                workoutToEdit = workout
                                                if workout.activityType == .cardio {
                                                    showLogCardio = true
                                                } else {
                                                    showLogWorkout = true
                                                }
                                            }
                                        },
                                        onLongPress: {
                                            if !isSelectionMode {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    isSelectionMode = true
                                                    selectedWorkouts.insert(workout.id)
                                                }
                                                justLongPressedWorkoutId = workout.id
                                                
                                                // Reset flag after delay to allow subsequent taps on this workout
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    justLongPressedWorkoutId = nil
                                                }
                                            }
                                        },
                                        onDelete: {
                                            deleteWorkout(workout)
                                        }
                                    )
                                }
                            }
                            
                            // --- Custom, Sleek Section Header ---
                            if !cardioWorkouts.isEmpty {
                                HStack {
                                    Text("Cardio")
                                        .font(.title2.bold())
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            cardioSortOrder = cardioSortOrder == .newestFirst ? .oldestFirst : .newestFirst
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.down")
                                                .font(.caption)
                                                .rotationEffect(.degrees(cardioSortOrder == .newestFirst ? 0 : 180))
                                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: cardioSortOrder)
                                            Text(cardioSortOrder == .newestFirst ? "Newest" : "Oldest")
                                                .font(.caption)
                                                .id(cardioSortOrder)
                                                .transition(.asymmetric(
                                                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                                                    removal: .opacity.combined(with: .scale(scale: 0.8))
                                                ))
                                        }
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .contentShape(Rectangle())
                                    }
                                }
                                .padding(.top, 20) // More padding to separate sections
                                
                                // Cardio Workouts Loop
                                ForEach(cardioWorkouts) { workout in
                                    WorkoutRowView(
                                        workout: workout,
                                        isSelected: selectedWorkouts.contains(workout.id),
                                        isSelectionMode: isSelectionMode,
                                        swipedWorkoutId: $swipedWorkoutId,
                                        onTap: {
                                            // Dismiss swipe-to-delete if another row is swiped open
                                            if swipedWorkoutId != nil && swipedWorkoutId != workout.id {
                                                withAnimation {
                                                    swipedWorkoutId = nil
                                                }
                                            }
                                            
                                            // Ignore tap only on the workout that was just long-pressed (to prevent unselecting)
                                            if justLongPressedWorkoutId == workout.id {
                                                return
                                            }
                                            
                                            if isSelectionMode {
                                                if selectedWorkouts.contains(workout.id) {
                                                    selectedWorkouts.remove(workout.id)
                                                } else {
                                                    selectedWorkouts.insert(workout.id)
                                                }
                                            } else {
                                                workoutToEdit = workout
                                                if workout.activityType == .cardio {
                                                    showLogCardio = true
                                                } else {
                                                    showLogWorkout = true
                                                }
                                            }
                                        },
                                        onLongPress: {
                                            if !isSelectionMode {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    isSelectionMode = true
                                                    selectedWorkouts.insert(workout.id)
                                                }
                                                justLongPressedWorkoutId = workout.id
                                                
                                                // Reset flag after delay to allow subsequent taps on this workout
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    justLongPressedWorkoutId = nil
                                                }
                                            }
                                        },
                                        onDelete: {
                                            deleteWorkout(workout)
                                        }
                                    )
                                }
                            }
                            
                            // Spacer to capture taps on empty space at the bottom
                            Color.clear
                                .frame(minHeight: 100)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Dismiss swipe-to-delete when tapping on empty space
                                    if swipedWorkoutId != nil {
                                        withAnimation {
                                            swipedWorkoutId = nil
                                        }
                                    }
                                }
                        }
                        .padding(.horizontal) // This gives the cards horizontal space
                        .padding(.top)
                        .padding(.bottom, 200) // Space for menu and button
                        .background(
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Dismiss swipe-to-delete when tapping on empty space in the background
                                    if swipedWorkoutId != nil {
                                        withAnimation {
                                            swipedWorkoutId = nil
                                        }
                                    }
                                }
                        )
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color("PrimaryBackground"))
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                // Dismiss swipe-to-delete when tapping anywhere in the scroll view (but only if a swipe is open)
                                // This works as a fallback for taps on empty space that might not be captured by other handlers
                                if swipedWorkoutId != nil {
                                    withAnimation {
                                        swipedWorkoutId = nil
                                    }
                                }
                            }
                    )
                }
                }
            }
            
            // Full-screen overlay to capture taps outside menu when menu is open
            if isMenuOpen {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isMenuOpen = false
                        }
                    }
            }
            
            // Menu and Button Container
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    // Menu Options (appears above button)
                    if isMenuOpen {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                MenuOptionButton(
                                    icon: "figure.strengthtraining.traditional",
                                    text: "Log Strength Training",
                                    action: {
                                        isMenuOpen = false
                                        showLogWorkout = true
                                    }
                                )
                                
                                MenuOptionButton(
                                    icon: "figure.run",
                                    text: "Log Cardio",
                                    action: {
                                        showLogCardio = true
                                        isMenuOpen = false
                                    }
                                )
                                
                                MenuOptionButton(
                                    icon: "list.bullet.rectangle",
                                    text: "Create Routine",
                                    action: {
                                        // TODO: Handle Create Routine
                                        isMenuOpen = false
                                    }
                                )
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .frame(maxWidth: 340) // Wide enough to display text on one line
                            .padding(.bottom, 10)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity)
                            ))
                            Spacer()
                        }
                    }
                    
                    // Plus Button - centered horizontally, 15px above navigation bar
                    // Navigation bar height: 16 (top padding) + ~40 (content) + safeAreaInsets.bottom = ~56 + safeAreaInsets.bottom
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                .background(Color("PrimaryBackground"))
                                .clipShape(Circle())
                                .rotationEffect(.degrees(isMenuOpen ? 45 : 0))
                        }
                        Spacer()
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 86) // 56 (nav bar) + 15 (spacing) = 71
                }
            }
        }
        .onAppear {
            // Reset menu to closed state when screen appears
            if isMenuOpen {
                withAnimation {
                    isMenuOpen = false
                }
            }
        }
        .onDisappear {
            // Close menu when leaving the screen
            if isMenuOpen {
                isMenuOpen = false
            }
        }
        .sheet(isPresented: $showLogWorkout) {
            LogWorkoutView(workoutToEdit: workoutToEdit)
        }
        .sheet(isPresented: $showLogCardio) {
            LogCardioView(workoutToEdit: workoutToEdit)
        }
        .onChange(of: showLogWorkout) { oldValue, newValue in
            if !newValue {
                // Reset workoutToEdit when sheet is dismissed
                workoutToEdit = nil
            }
        }
        .onChange(of: showLogCardio) { oldValue, newValue in
            if !newValue {
                // Reset workoutToEdit when sheet is dismissed
                workoutToEdit = nil
            }
        }
    }
    
    private func deleteWorkout(_ workout: Workout) {
        modelContext.delete(workout)
    }
    
    private func deleteSelectedWorkouts() {
        let workoutsToDelete = workouts.filter { selectedWorkouts.contains($0.id) }
        for workout in workoutsToDelete {
            modelContext.delete(workout)
        }
        withAnimation {
            selectedWorkouts.removeAll()
            isSelectionMode = false
        }
    }
}

// Menu Option Button Component
struct MenuOptionButton: View {
    var icon: String
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    .frame(width: 30)
                
                Text(text)
                    .font(.body)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    ActivitiesView()
}

