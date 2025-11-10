//
//  JournalView.swift
//  FitTrack Code
//
//  Created by Hadi Abbas on 11/9/25.
//

import SwiftUI

struct JournalView: View {
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .edgesIgnoringSafeArea(.all)
            
            Text("Journal Screen")
                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
        }
    }
}

#Preview {
    JournalView()
}

