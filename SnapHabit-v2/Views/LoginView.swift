//
//  LoginView.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 7/10/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject private var themeManager = ThemeManager.sharedTheme
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    authFormSection
                    toggleAuthModeButton
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button("OK") {
                authViewModel.errorMessage = nil
            }
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
        .alert("Success", isPresented: .constant(authViewModel.successMessage != nil)) {
            Button("OK") {
                authViewModel.successMessage = nil
            }
        } message: {
            Text(authViewModel.successMessage ?? "")
        }
        .environment(\.colorScheme, themeManager.colorScheme ?? .light)
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Logo
            Circle()
                .fill(Color.blue)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                )
            
            // App Title
            Text("SnapHabit")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            // Welcome Message
            Text(authViewModel.isSignUpMode ? "Create your account" : "Welcome back!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Auth Form Section
    @ViewBuilder
    private var authFormSection: some View {
        VStack(spacing: 20) {
            // Display Name Field (Sign Up Only)
            if authViewModel.isSignUpMode {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        
                        TextField("Enter your full name", text: $authViewModel.displayName)
                            .font(.system(size: 16))
                            .autocapitalization(.words)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
            }
            
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    TextField("Enter your email", text: $authViewModel.email)
                        .font(.system(size: 16))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    if isPasswordVisible {
                        TextField("Enter your password", text: $authViewModel.password)
                            .font(.system(size: 16))
                    } else {
                        SecureField("Enter your password", text: $authViewModel.password)
                            .font(.system(size: 16))
                    }
                    
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            
            // Confirm Password Field (Sign Up Only)
            if authViewModel.isSignUpMode {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        
                        if isConfirmPasswordVisible {
                            TextField("Confirm your password", text: $authViewModel.confirmPassword)
                                .font(.system(size: 16))
                        } else {
                            SecureField("Confirm your password", text: $authViewModel.confirmPassword)
                                .font(.system(size: 16))
                        }
                        
                        Button(action: {
                            isConfirmPasswordVisible.toggle()
                        }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
            }
            
            // Auth Button
            Button(action: {
                Task {
                    if authViewModel.isSignUpMode {
                        await authViewModel.signUp()
                    } else {
                        await authViewModel.signIn()
                    }
                    // Navigation will be handled automatically by ContentView
                    // based on the authState change in AuthenticationViewModel
                }
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text(authViewModel.isSignUpMode ? "Sign Up" : "Sign In")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(authViewModel.isFormValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!authViewModel.isFormValid || authViewModel.isLoading)
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Toggle Auth Mode Button
    @ViewBuilder
    private var toggleAuthModeButton: some View {
        Button(action: {
            authViewModel.toggleAuthMode()
        }) {
            HStack(spacing: 4) {
                Text(authViewModel.isSignUpMode ? "Already have an account?" : "Don't have an account?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(authViewModel.isSignUpMode ? "Sign In" : "Sign Up")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
        }
        .disabled(authViewModel.isLoading)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}