//
//  Nav.swift
//  SnapHabit
//
//  Created by Agam Singh on 15/8/2025.
//

import Foundation
import SwiftUI

/// The main navigation view of the app, providing access to different sections such as Home, AI Analytics, Gallery, and Profile.
/// 
/// - Note: This view uses a `TabView` to allow users to switch between different sections of the app.
/// # Environment Objects:
///  - `homeViewModel`: An instance of `HomeViewModel` to manage the state and logic for the Home view.
///  - `database`: An instance of `database` to manage data storage and retrieval.
/// # Child Views:
///  - `HomeView`: The main view displaying the user's habits and activities.
///  - `HabitAnalysisView`: A view that provides AI-driven analytics on the user's habits.
///  - `GalleryView`: A view that displays a gallery of images related to the user's habits.
///  - `ProfileView`: A view that displays the user's profile information and settings.
struct Nav: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var database: database
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
                    .environmentObject(homeViewModel)
            }
            Tab("AI Analytics", systemImage: "chart.line.text.clipboard.fill") {
                HabitAnalysisView(database: database)
                    .environmentObject(homeViewModel)
            }
            Tab("Gallery", systemImage: "photo.on.rectangle") {
                GalleryView()
            }
            Tab("Profile", systemImage: "person.crop.circle.fill") {
                ProfileView()
            }
        }
    }
}

#Preview {
    Nav()
        .environmentObject(HomeViewModel())
}
