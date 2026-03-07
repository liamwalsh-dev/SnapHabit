//
//  ContentView.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 15/9/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showSplash = true

    @StateObject private var authViewModel = AuthViewModel()
    @State private var authState : AuthState = .loading

    @StateObject private var homeViewModel = HomeViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if showSplash {
                VStack {
                    LogoTextLayout {
                        VStack(spacing: 16) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40, weight: .semibold))
                                        .foregroundColor(.white)
                                )
                            Text("SnapHabit")
                                .font(.largeTitle)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSplash = false
                        }
                        homeViewModel.setModelContext(modelContext)
                        authViewModel.checkAuthState()
                    }
                }
            } else {
                switch authViewModel.authState {
                case .loading:
                    ProgressView("Loading...")
                        .onAppear {
                            authViewModel.checkAuthState()
                        }
                case .unauthenticated:
                    LoginView()
                        .environmentObject(authViewModel)
                case .authenticated:
                    Nav()
                        .environmentObject(homeViewModel)
                        .environmentObject(authViewModel)
                }
            }
        }
        .onAppear {
            homeViewModel.setModelContext(modelContext)
        }
    }
}

#Preview {
    ContentView()
}