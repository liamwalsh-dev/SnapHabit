//
//  User.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 7/10/2025.
//

import Foundation
import FirebaseAuth

/// User model representing an authenticated user in the app.
///
/// This model contains properties for managing user authentication state and profile information.
/// It integrates with Firebase Auth to handle user sessions and profile data.
///
/// # Properties:
///  - `id`: A unique identifier for the user.
///  - `email`: The user's email address.
///  - `displayName`: An optional display name for the user.
///  - `photoURL`: An optional URL string for the user's profile photo.
///  - `isEmailVerified`: A boolean indicating if the user's email is verified.
/// # Methods:
///  - `init(firebaseUser:)`: Initializes a User instance from a Firebase Auth user object.
struct User: Identifiable, Codable {
    let id: String
    let email: String
    let displayName: String?
    let photoURL: String?

    init(id: String, email: String, displayName: String? = nil, photoURL: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
    }
    
    /// Initialize User from Firebase Auth User
    /// - Parameters:
    ///   - firebaseUser: The Firebase Auth user object
    /// - Returns: A User instance populated with data from the Firebase user
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.displayName = firebaseUser.displayName
        self.photoURL = firebaseUser.photoURL?.absoluteString
        self.password = nil
    }
}

/// Authentication state enum to track user login status
/// 
/// # States:
/// - loading: The authentication state is being determined
/// - authenticated(User): The user is logged in and authenticated
/// - unauthenticated: The user is not logged in
/// 
enum AuthState {
    case loading
    case authenticated(User)
    case unauthenticated
}
