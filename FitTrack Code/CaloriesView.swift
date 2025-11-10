//
//  CaloriesView.swift
//  FitTrack Code
//
//  Created by Hadi Abbas on 11/9/25.
//

import SwiftUI

struct CaloriesView: View {
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .edgesIgnoringSafeArea(.all)
            
            Text("Calories Screen")
                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
        }
    }
}

#Preview {
    CaloriesView()
}

