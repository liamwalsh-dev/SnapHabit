# SnapHabit

A photo-based habit tracking iOS app built with SwiftUI.

**Built by:** Agampreet Singh



## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Architecture](#architecture)
- [Navigation Flow](#navigation-flow)

---

## Overview

SnapHabit is a habit tracking app that uses **photo evidence** to confirm habit completion. Instead of a simple checkbox, users snap a photo each time they complete a habit, making tracking more engaging and accountable. The app also provides AI-powered analysis of habit patterns using Google Gemini.

---

## Features

- **Photo-Based Completion** : Take or select a photo to mark a habit as done
- **Habit Management** : Create, edit, and delete habits with a custom name, category, color, and frequency (daily / weekly / monthly)
- **Streak Tracking** : Current streak, longest streak, and total days-active counters
- **Progress Indicators** : Visual progress bars for weekly and monthly habits
- **AI Insights** : Gemini AI analysis of habit patterns with personalised recommendations
- **Photo Gallery** : Browse all completion photos with timestamps and notes per habit
- **Home Screen Widget** : iOS widget showing today's pending habits via WidgetKit
- **Firebase Auth** : Email/password sign-up and login with persistent session state
- **Dark Mode** : Full light/dark mode support via `ThemeManager`

---

## Tech Stack

| Area | Technology |
|---|---|
| UI Framework | SwiftUI + UIKit (camera) |
| Architecture | MVVM |
| Persistence | SwiftData |
| Authentication | Firebase Auth |
| AI Integration | Google Gemini API |
| Image Handling | PhotosUI, AVFoundation |
| Widget | WidgetKit |
| Testing | Swift Testing |

---

## Installation

**Prerequisites**
- Xcode 16+
- iOS 18.5+ device or simulator
- A Firebase project with Email/Password Authentication enabled
- A Google AI Studio API key for Gemini

**Steps**

1. Clone the repository
2. Add your `GoogleService-Info.plist` from Firebase into `SnapHabit-v2/`
3. Create `SnapHabit-v2/Secrets.swift` (already git-ignored):
   ```swift
   enum Secrets {
       static let geminiAPIKey = "YOUR_GEMINI_API_KEY"
   }
   ```
4. Open `SnapHabit-v2.xcodeproj` in Xcode
5. Set your development team in **Signing & Capabilities**
6. Build and run

---

## Architecture

```
SnapHabit-v2/
├── Views/          # SwiftUI screens
├── ViewModels/     # MVVM view models (@MainActor, ObservableObject)
├── Models/         # SwiftData models (Habit, HabitPhoto) and value types
├── Services/       # External API clients (Gemini AI)
├── Components/     # Reusable UI components and layout helpers
├── Database/       # SwiftData context wrapper
└── HabitWidget/    # WidgetKit extension (shared App Group)
```

**Key design decisions:**
- **SwiftData + App Group** , shares the same persistent store between the main app and the widget extension
- **`@MainActor`** , applied to all view models and the database layer to guarantee UI updates on the main thread
- **`Secrets.swift`** , git-ignored file that holds the Gemini API key so no credentials are committed to the repository

---


## Navigation Flow

```
Splash Screen
├── → Login / Sign Up        (unauthenticated)
└── → Home (Tab Bar)         (authenticated)
       ├── Home Tab
       │    ├── → Add Habit
       │    └── → Habit Detail
       │             ├── → Complete Habit  (camera / photo library)
       │             ├── → Edit Habit
       │             └── → Photo Gallery → Photo Detail
       ├── AI Insights Tab
       ├── Gallery Tab
       └── Profile Tab
```

---

_RMIT University - iPhone Software Engineering (iPSE), 2025_
