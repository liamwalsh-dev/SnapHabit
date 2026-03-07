//
//  HabitWidget.swift
//
//  Created by Agam Singh on 11/10/2025.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

/// A widget that displays the user's habits and their progress.
/// This widget fetches habit data from a shared SwiftData container and updates its display accordingly.
/// 
/// # Properties:
///  - id: A unique identifier for the widget.
///  - description: A brief description of the widget.
///  - habitDescription: A detailed description of the widget's purpose.
///  - streakCounter: The current streak count for the habit.
///  - isCompletedToday: A boolean indicating if the habit is completed for today.
struct HabitSnapshot: Identifiable {
    let id: UUID
    let name: String
    let habitDescription: String
    let streakCounter: Int
    let isCompletedToday: Bool
    // Can add any other properties to display
}

/// Timeline provider for the HabitWidget.
/// 
/// What this does is fetch habit data from the shared SwiftData container and provides timeline entries for the widget.
/// 
/// # Methods:
///  - `placeholder(in:)`: Provides a placeholder entry for the widget.
///  - `getSnapshot(in:completion:)`: Fetches a snapshot of the current habit data.
///  - `getTimeline(in:completion:)`: Generates a timeline of habit data entries.
/// 
/// - SeeAlso: `SimpleEntry`, `HabitWidgetEntryView`
struct Provider: TimelineProvider {
    
/// Function to provide a placeholder entry while the widget is loading.
/// 
/// This function creates a simple entry with the current date and a list of habits fetched from the shared SwiftData container.
/// - Parameters:
///  - context: The context in which the placeholder is requested.
/// - Returns: A `SimpleEntry` containing the current date and a list of habits.
@MainActor
func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), habitList: getHabits())
    }
/// Function to fetch a snapshot of the current habit data.
/// 
/// This function retrieves the current list of habits from the shared SwiftData container and provides it as a snapshot entry.
/// 
/// - Parameters:
///  - context: The context in which the snapshot is requested.
///  - completion: A closure to call with the snapshot entry.
/// Returns: None
@MainActor
func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), habitList: getHabits())
        completion(entry)
    }

/// Function to generate a timeline of habit data entries.
/// 
/// This function creates a timeline of habit data entries for the widget, updating every 5 minutes.
/// 
/// - Parameters:
///  - context: The context in which the timeline is requested.
///  - completion: A closure to call with the timeline entry.
/// Returns: None
@MainActor
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let currentDate = Date()
    let habits = getHabits()
    
    // Create entries for next few hours
    var entries: [SimpleEntry] = []
    for hourOffset in 0..<12 {
        let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset * 5, to: currentDate)!
        entries.append(SimpleEntry(date: entryDate, habitList: habits))
    }
    
    // Refresh every 5 minutes, or at midnight to reset completed status
    let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!)
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
    
    let timeline = Timeline(entries: entries, policy: .after(min(nextUpdate, nextMidnight)))
    completion(timeline)
    }
    
    /// Fetches habits from the shared SwiftData container.
    /// 
    /// This function sets up a ModelContainer with the shared App Group identifier,fetches Habit objects, and converts them to HabitSnapshot for use in the widget.
    /// 
    /// - Returns: An array of HabitSnapshot objects.
    /// - SeeAlso: `Habit`, `ModelContainer`, `FetchDescriptor`
    @MainActor
    private func getHabits() -> [HabitSnapshot] {
    // Debug App Group location
    if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.s4014941.SnapHabit-v2") {
    } else {
        print("Widget - App Group URL is nil!")
    }
    
    let schema = Schema([
        Habit.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, groupContainer: .identifier("group.com.s4014941.SnapHabit-v2"))
    
    guard let modelContainer = try? ModelContainer(for: schema, configurations: [modelConfiguration]) else {
        print("Widget - ModelContainer creation failed")
        return []
    }
    let descriptor = FetchDescriptor<Habit>()
    guard let habitList = try? modelContainer.mainContext.fetch(descriptor) else {
        print("Widget - Fetch failed")
        return []
    }
    
    // Convert to snapshots before the container is deallocated
    let snapshots = habitList.map { habit in
        HabitSnapshot(
            id: habit.id,
            name: habit.name,
            habitDescription: habit.habitDescription,
            streakCounter: habit.streakCounter,
            isCompletedToday: habit.isCompletedToday
            // Can add other properties if needed
        )
    }
    
    return snapshots
    }
}

/// This struct defines a simple timeline entry for the widget. (DEFAULT TEMPLATE CREATED & USED)
/// 
/// # Properties:
///  - date: The date associated with the entry.
///  - habitList: An array of HabitSnapshot objects representing the habits at this entry.
/// 
struct SimpleEntry: TimelineEntry {
    let date: Date
    let habitList: [HabitSnapshot]
}

/// The main view for the HabitWidget.
/// 
/// This view adapts its layout based on the widget family (size) and displays habit information accordingly.
///
/// # Properties:
///  - entry: The timeline entry containing habit data.
///  - widgetFamily: The current widget family (size) from the environment.
/// 
/// - SeeAlso: `Provider`, `SmallWidgetView`, `MediumWidgetView`, `LargeWidgetView`
struct HabitWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(habits: entry.habitList)
        case .systemMedium:
            MediumWidgetView(habits: entry.habitList)
        case .systemLarge:
            LargeWidgetView(habits: entry.habitList)
        default:
            SmallWidgetView(habits: entry.habitList)
        }
    }
}

// MARK: - Small Widget View
/// A compact view for displaying a single habit in a small widget.
/// 
/// This view shows the habit name, streak count, and completion status.
/// # Properties:
///  - habits: An array of HabitSnapshot objects to display (only the first one is shown).
/// - SeeAlso: `HabitSnapshot`
struct SmallWidgetView: View {
    let habits: [HabitSnapshot]
    
    var body: some View {
        if let firstHabit = habits.first {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(firstHabit.isCompletedToday ? .green : .orange)
                    
                    if firstHabit.isCompletedToday {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Text("\(firstHabit.streakCounter)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(firstHabit.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text("\(habits.count) active habit\(habits.count != 1 ? "s" : "")")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(firstHabit.isCompletedToday ? Color.green.opacity(0.1) : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(firstHabit.isCompletedToday ? Color.green.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 2)
            )
            .cornerRadius(16)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 32))
                    .foregroundColor(.gray)
                
                Text("No Habits")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Medium Widget View
/// A medium-sized view for displaying up to two habits in a medium widget.
/// 
/// This view shows habit cards side by side, each displaying the habit name, streak count, and completion status.
/// # Properties:
///  - habits: An array of HabitSnapshot objects to display (up to two are shown).
/// - SeeAlso: `HabitSnapshot`, `HabitCard`
struct MediumWidgetView: View {
    let habits: [HabitSnapshot]
    
    var body: some View {
        if habits.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 32))
                    .foregroundColor(.gray)
                
                Text("No Habits")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            HStack(spacing: 12) {
                ForEach(habits.prefix(2)) { habit in
                    HabitCard(habit: habit)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Large Widget View
/// A large view for displaying up to four habits in a large widget.
/// 
/// This view shows a list of habits with their names, descriptions, streak counts, and completion statuses.
/// # Properties:
///  - habits: An array of HabitSnapshot objects to display (up to four are shown).
/// - SeeAlso: `HabitSnapshot`, `HabitRow`
struct LargeWidgetView: View {
    let habits: [HabitSnapshot]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("Your Habits")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(habits.count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            if habits.isEmpty {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                    
                    Text("No Habits")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            } else {
                VStack(spacing: 12) {
                    ForEach(habits.prefix(4)) { habit in
                        HabitRow(habit: habit)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
    }
}

// MARK: - Habit Card (for Medium Widget)
/// A card view for displaying a single habit in the medium widget.
/// 
/// This view shows the habit name, streak count, and completion status in a compact card format.
/// # Properties:
///  - habit: A HabitSnapshot object representing the habit to display.
/// - SeeAlso: `HabitSnapshot`
struct HabitCard: View {
    let habit: HabitSnapshot
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(habit.isCompletedToday ? .green : .orange)
                
                if habit.isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Text("\(habit.streakCounter)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(habit.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
        }
        .padding(12)
        .background(habit.isCompletedToday ? Color.green.opacity(0.1) : Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(habit.isCompletedToday ? Color.green.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 2)
        )
        .cornerRadius(12)
    }
}

// MARK: - Habit Row (for Large Widget)
/// A row view for displaying a single habit in the large widget.
/// This view shows the habit name, description, streak count, and completion status in a horizontal layout.
/// # Properties:
///  - habit: A HabitSnapshot object representing the habit to display.
/// - SeeAlso: `HabitSnapshot`
struct HabitRow: View {
    let habit: HabitSnapshot
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(habit.habitDescription)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                if habit.isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }
                
                Text("\(habit.streakCounter)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(habit.isCompletedToday ? .green : .orange)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundColor(habit.isCompletedToday ? .green : .orange)
            }
        }
        .padding(12)
        .background(habit.isCompletedToday ? Color.green.opacity(0.1) : Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(habit.isCompletedToday ? Color.green.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 2)
        )
        .cornerRadius(12)
    }
}

/// An AppIntent to refresh the widget timelines.
/// 
/// This intent is triggered when a habit is added, updated, or deleted in the main app.
/// It calls WidgetCenter to reload all timelines, ensuring the widget displays the latest habit data.
/// 
/// # Methods:
///  - `perform()`: Reloads all widget timelines.
/// 
/// - SeeAlso: `WidgetCenter`, `database.swift`
@available(iOS 17.0, *)
struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Habits"
    
    /// This function performs the intent action to refresh the widget timelines.
    /// 
    /// It calls `WidgetCenter.shared.reloadAllTimelines()` to ensure the widget displays the latest habit data.
    /// - Returns: An `IntentResult` indicating the result of the action.
    /// - SeeAlso: `WidgetCenter`, `database.swift`
    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
/// The main widget configuration for the HabitWidget.
/// This struct defines the widget, its configuration, and widget families.
/// 
/// # Properties:
///  - kind: A unique identifier for the widget family.
///
struct HabitWidget: Widget {
    let kind: String = "HabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                HabitWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                HabitWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("SnapHabit")
        .description("Track your daily habits at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}