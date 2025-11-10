//
//  SummaryView.swift
//  FitTrack Code
//
//  Created by Hadi Abbas on 11/9/25.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Header with user info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Summary")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                        
                        if let user = networkManager.currentUser {
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Logout button
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 60)
                
                // Placeholder content
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    
                    Text("Dashboard Coming Soon")
                        .font(.title3)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                    
                    Text("Your insights and progress graphs will appear here")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxHeight: .infinity)
                
                Spacer()
            }
        }
        .alert("Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                networkManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}

#Preview {
    SummaryView()
        .environmentObject(NetworkManager.shared)
}

