//
//  ProfileView.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 7/10/2025.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject private var themeManager = ThemeManager.sharedTheme
    @State private var showLogoutAlert = false
    
    // Get current user data
    private var currentUser: User? {
        if case .authenticated(let user) = authViewModel.authState {
            return user
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    userProfileSection
                    settingsSection
                    logoutSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                authViewModel.checkAuthState()
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authViewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .environment(\.colorScheme, themeManager.colorScheme ?? .light)
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Appearance")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Theme Toggle
            HStack(spacing: 16) {
                Image(systemName: themeManager.colorScheme == .dark ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(themeManager.colorScheme == .dark ? .blue : .orange)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Theme")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(getThemeDisplayName())
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        themeManager.toggleTheme()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Change")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - User Profile Section
    private var userProfileSection: some View {
        VStack(spacing: 16) {
            // Profile Picture
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 100, height: 100)
                .overlay(
                    Group {
                        if let photoURL = currentUser?.photoURL, !photoURL.isEmpty {
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .clipShape(Circle())
                )
            
            // User Info
            VStack(spacing: 8) {
                Text(currentUser?.displayName ?? "User")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(currentUser?.email ?? "No email")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
    }
            
    
    // MARK: - Logout Section
    private var logoutSection: some View {
        Button(action: {
            showLogoutAlert = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.red)
                
                Text("Logout")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.red)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Helper Methods
    private func getThemeDisplayName() -> String {
        switch themeManager.colorScheme {
        case .light:
            return "Light Mode"
        case .dark:
            return "Dark Mode"
        case .none:
            return "System Default"
        @unknown default:
            return "System Default"
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
