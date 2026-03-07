# SnapHabit App Styling Guide

This document outlines the design system and styling conventions used throughout the SnapHabit iOS app to ensure consistency across all views and components.

## Table of Contents
- [Color System](#color-system)
- [Typography](#typography)
- [Layout & Spacing](#layout--spacing)
- [Components](#components)
- [Navigation](#navigation)
- [Forms & Input Fields](#forms--input-fields)
- [Buttons](#buttons)
- [Alert Messages](#alert-messages)
- [Code Examples](#code-examples)

---

## Color System

### Primary Colors
- **Background**: `Color(.systemBackground)` - Adapts to light/dark mode
- **Section Background**: `Color(.systemGray6)` - Light gray for card/section backgrounds
- **Primary Text**: `.foregroundColor(.primary)` - Main text color
- **Secondary Text**: `.foregroundColor(.secondary)` - Subtitle and label text

### Habit Colors
Use the predefined `Habit.HabitColor` enum for consistency:
- `.blue`, `.green`, `.red`, `.orange`, `.purple`, `.pink`, `.yellow`, `.teal`

### Status Colors
- **Success**: `Color.green` with `Color.green.opacity(0.1)` background
- **Error**: `Color.red` with `Color.red.opacity(0.1)` background
- **Warning**: `Color.orange` with `Color.orange.opacity(0.1)` background

---

## Typography

### Font Hierarchy

#### Headers
```swift
// Main page title
.font(.system(size: 28, weight: .bold))
.foregroundColor(.primary)

// Section titles
.font(.system(size: 18, weight: .semibold))
.foregroundColor(.primary)

// Subtitle/tagline
.font(.system(size: 16, weight: .medium))
.foregroundColor(.secondary)
```

#### Body Text
```swift
// Regular body text
.font(.system(size: 16))
.foregroundColor(.primary)

// Field labels
.font(.system(size: 14, weight: .medium))
.foregroundColor(.secondary)

// Small text/captions
.font(.system(size: 12, weight: .medium))
.foregroundColor(.secondary)
```

#### Button Text
```swift
// Primary button text
.font(.system(size: 18, weight: .semibold))

// Secondary button text
.font(.system(size: 16, weight: .medium))
```

---

## Layout & Spacing

### Standard Spacing Values
- **Section spacing**: `24px` between major sections
- **Card padding**: `20px` internal padding for cards/sections
- **Element spacing**: `16px` between related elements
- **Small spacing**: `12px` between closely related items
- **Micro spacing**: `8px` for very close elements
- **Field spacing**: `4px` between label and input

### Margins & Padding
```swift
// Page margins
.padding(.horizontal, 20)

// Section internal padding
.padding(20)

// Button padding
.padding(.vertical, 16)

// Top spacing for headers
.padding(.top, 20)

// Bottom spacing for last elements
.padding(.bottom, 30)
```

### Corner Radius
- **Cards/Sections**: `16px` corner radius
- **Buttons**: `12px` corner radius
- **Small elements**: `8px` corner radius

---

## Components

### Section Cards
```swift
VStack(spacing: 16) {
    VStack(alignment: .leading, spacing: 12) {
        Text("Section Title")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.primary)
        
        // Section content here
    }
}
.padding(20)
.background(Color(.systemGray6))
.cornerRadius(16)
.padding(.horizontal, 20)
```

### Header Section
```swift
VStack(spacing: 8) {
    Text("Page Title")
        .font(.system(size: 28, weight: .bold))
        .foregroundColor(.primary)
    
    Text("Subtitle or description")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
}
.padding(.top, 20)
```

---

## Navigation

### Navigation Stack Setup
```swift
NavigationStack {
    // Content here
}
.background(Color(.systemBackground))
.navigationBarTitleDisplayMode(.inline)
.navigationTitle("")
```

### Back Button (if custom needed)
```swift
Button(action: { /* dismiss action */ }) {
    HStack {
        Image(systemName: "chevron.left")
        Text("Back")
    }
    .font(.system(size: 16, weight: .medium))
    .foregroundColor(.primary)
}
```

---

## Forms & Input Fields

### Text Fields
```swift
VStack(alignment: .leading, spacing: 4) {
    Text("Field Label")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.secondary)
    
    TextField("Placeholder text", text: $binding)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .font(.system(size: 16))
}
```

### Pickers

#### Segmented Picker
```swift
Picker("Title", selection: $selection) {
    ForEach(options, id: \.self) { option in
        Text(option.rawValue.capitalized)
            .font(.system(size: 16, weight: .medium))
            .tag(option)
    }
}
.pickerStyle(SegmentedPickerStyle())
```

#### Menu Picker
```swift
Picker("Category", selection: $selection) {
    ForEach(options, id: \.self) { option in
        Text(option.rawValue)
            .font(.system(size: 16))
            .tag(option)
    }
}
.pickerStyle(MenuPickerStyle())
.frame(maxWidth: .infinity, alignment: .leading)
```

### Date Picker
```swift
DatePicker(
    "Select Time",
    selection: $time,
    displayedComponents: .hourAndMinute
)
.datePickerStyle(CompactDatePickerStyle())
.font(.system(size: 16))
```

---

## Buttons

### Primary Button
```swift
Button(action: { /* action */ }) {
    HStack {
        Image(systemName: "icon.name")
            .font(.system(size: 18, weight: .medium))
        
        Text("Button Text")
            .font(.system(size: 18, weight: .semibold))
    }
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(habitColor.color) // or Color.blue for default
    .cornerRadius(12)
}
.padding(.horizontal, 20)
```

### Secondary Button
```swift
Button(action: { /* action */ }) {
    Text("Button Text")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.primary)
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(Color(.systemGray6))
        .cornerRadius(8)
}
```

### Icon Button
```swift
Button(action: { /* action */ }) {
    Image(systemName: "icon.name")
        .font(.system(size: 20, weight: .medium))
        .foregroundColor(.primary)
}
.buttonStyle(PlainButtonStyle())
```

---

## Alert Messages

### Success Message
```swift
HStack {
    Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 16))
        .foregroundColor(.green)
    
    Text("Success message")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.green)
    
    Spacer()
}
.padding(16)
.background(Color.green.opacity(0.1))
.cornerRadius(12)
```

### Error Message
```swift
HStack {
    Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 16))
        .foregroundColor(.red)
    
    Text("Error message")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.red)
    
    Spacer()
}
.padding(16)
.background(Color.red.opacity(0.1))
.cornerRadius(12)
```

---

## Code Examples

### Complete Page Template
```swift
struct NewPageView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 8) {
                        Text("Page Title")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Page description")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Content Sections
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Section Title")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            // Section content here
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Action Button
                    Button(action: { /* action */ }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("Action Button")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
    }
}
```

### Color Selection Grid
```swift
LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
    ForEach(Habit.HabitColor.allCases, id: \.self) { habitColor in
        Button(action: {
            selectedColor = habitColor
        }) {
            VStack(spacing: 8) {
                Circle()
                    .fill(habitColor.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: selectedColor == habitColor ? 3 : 0)
                    )
                
                Text(habitColor.rawValue.capitalized)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(selectedColor == habitColor ? .primary : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

---

## Best Practices

1. **Consistency**: Always use the predefined spacing, colors, and typography scales
2. **Accessibility**: Ensure proper contrast ratios and font sizes
3. **Dark Mode**: Use system colors that adapt automatically
4. **Responsive**: Use `.frame(maxWidth: .infinity)` for full-width elements
5. **Animations**: Add subtle animations for state changes using `.animation(.easeInOut(duration: 0.3), value: stateVariable)`
6. **Safe Areas**: Consider safe area insets for proper spacing
7. **Testing**: Test on different screen sizes and orientations

---

## Quick Reference

### Common Modifiers Chain
```swift
.font(.system(size: 16, weight: .medium))
.foregroundColor(.primary)
.padding(20)
.background(Color(.systemGray6))
.cornerRadius(16)
.padding(.horizontal, 20)
```

### Color Hierarchy
1. Primary text: `.foregroundColor(.primary)`
2. Secondary text: `.foregroundColor(.secondary)`
3. Accent colors: Use `Habit.HabitColor` enum
4. Backgrounds: `Color(.systemBackground)` and `Color(.systemGray6)`
