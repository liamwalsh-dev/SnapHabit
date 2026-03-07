//
//  AuthViewModel.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 7/10/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

/// ViewModel for managing user authentication state and operations.
///
/// This ViewModel handles all authentication-related functionality including:
/// - Email/password sign up and sign in
/// - User session management
/// - Authentication state tracking
/// 
/// # Properties:
/// - `authState`: The current authentication state of the user.
/// - `isLoading`: Indicates if an authentication operation is in progress.
/// - `errorMessage`: Holds error messages for display in the UI.
/// - `successMessage`: Holds success messages for display in the UI.
/// - `email`, `password`, `confirmPassword`, `displayName`: Form fields for authentication.
/// - `isSignUpMode`: Toggles between sign in and sign up modes.
/// # Methods:
/// - `signUp()`: Handles user sign up with email and password.
/// - `signIn()`: Handles user sign in with email and password.
/// - `signOut()`: Signs out the current user.
/// - `toggleAuthMode()`: Switches between sign in and sign up modes.
/// - `checkAuthState()`: Manually checks the current authentication state.
/// - `isFormValid`: Validates the current form based on the mode (sign in/sign up).
///
@MainActor
class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""
    @Published var photoURL = ""
    
    // UI state
    @Published var isSignUpMode = false
    
    init() {
        checkAuthState()
    }
    
    /// Manually checks the current authentication state
    /// 
    /// This method checks if there's a currently authenticated user and updates the authState accordingly.
    /// Call this method when you need to refresh the authentication status.
    ///
    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            authState = .authenticated(User(firebaseUser: user))
        } else {
            authState = .unauthenticated
        }
    }
    
    /// Sign up with email and password
    /// 
    /// This method handles user registration, including form validation,
    /// creating the user in Firebase Auth, and updating the user's display name.
    /// 
    /// - Throws: An error message if the sign-up process fails
    /// 
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()

            clearForm()
            successMessage = "Account created successfully!"
            checkAuthState() 
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Sign in with email and password
    /// 
    /// This method handles user login, including form validation and signing in the user with Firebase Auth.
    /// 
    /// - Throws: An error message if the sign-in process fails
    ///
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            clearForm()
            successMessage = "Login successful!"
            checkAuthState()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Sign out current user
    /// 
    /// This method signs out the currently authenticated user from Firebase Auth and clears the form fields.
    /// - Throws: An error message if the sign-out process fails
    ///
    func signOut() {
        do {
            try Auth.auth().signOut()
            clearForm()
            checkAuthState() // Update auth state after signout
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Toggle between sign in and sign up modes
    /// 
    /// This method switches the authentication mode and clears the form fields and error messages.
    ///
    func toggleAuthMode() {
        isSignUpMode.toggle()
        clearForm()
        errorMessage = nil
    }
    
    /// Clear form fields
    /// This method clears all form fields and resets the error message.
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        errorMessage = nil
    }
    
    /// Check if form is valid for current mode
    /// This computed property validates the form fields based on whether the user is in sign-in or sign-up mode.
    /// 
    /// - Returns: `true` if the form is valid, `false` otherwise
    var isFormValid: Bool {
        if isSignUpMode {
            return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !displayName.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
}