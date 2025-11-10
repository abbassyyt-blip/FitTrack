//
//  MainView.swift
//  FitTrack Code
//
//  Created by Hadi Abbas on 11/9/25.
//

import SwiftUI

struct MainView: View {
    // This state variable will track our selected page.
    // 0 = Summary, 1 = Activities, 2 = Calories, 3 = Journal
    @State private var selectedTab = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // 1. THE SLIDING PAGE VIEW
                TabView(selection: $selectedTab) {
                    // Add our four content views
                    SummaryView()
                        .tag(0)
                    
                    ActivitiesView()
                        .tag(1)
                    
                    CaloriesView()
                        .tag(2)
                    
                    JournalView()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // This gives the sliding animation
                .animation(.easeInOut, value: selectedTab) // Animate the slide
                .background(Color("PrimaryBackground").ignoresSafeArea(.all))
                
                // 2. OUR CUSTOM BUTTONS AT THE BOTTOM
                HStack(spacing: 0) {
                    // Summary Button
                    TabButton(icon: "chart.bar", text: "Summary", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    // Activities Button
                    TabButton(icon: "flame", text: "Activities", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    
                    // Calories Button
                    TabButton(icon: "leaf", text: "Calories", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                    
                    // Journal Button
                    TabButton(icon: "book", text: "Journal", isSelected: selectedTab == 3) {
                        selectedTab = 3
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, geometry.safeAreaInsets.bottom - 30)
                .background {
                    Color("SecondaryBackground")
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .ignoresSafeArea(edges: .bottom)
                }
            }
        }
    }
}

// Reusable button component for our custom tab bar
struct TabButton: View {
    var icon: String
    var text: String
    var isSelected: Bool
    var action: () -> Void
    
    // Computed property to get the icon name based on selection state
    private var iconName: String {
        isSelected ? "\(icon).fill" : icon
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.title2)
                Text(text)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // Makes the whole area tappable
            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
        }
        .buttonStyle(.plain) // Removes default button styling
    }
}

// Helper to round specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    MainView()
        // Add a model container here for previews later
        // .modelContainer(for: YourModel.self, inMemory: true)
}

