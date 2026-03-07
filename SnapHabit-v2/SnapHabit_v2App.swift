//
//  SnapHabit_v2App.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 15/9/2025.
//

import SwiftUI
import SwiftData

@main
struct SnapHabit_v2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, groupContainer: .identifier("group.com.s4014941.SnapHabit-v2"))

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(database(modelContext: sharedModelContainer.mainContext))
        }
        .modelContainer(sharedModelContainer)
    }
}
