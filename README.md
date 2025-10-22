# HabitTracker

**HabitTracker** is a simple and elegant iOS app that helps users build and maintain positive daily habits through motivation, reminders, and tracking progress — all while keeping data completely private on the device.

---

## 📱 App Overview

HabitTracker allows users to:
- Create, edit, and manage personal habits  
- Set individual or global reminders  
- Track completion rates and streaks  
- View motivational quotes through a home screen widget  
- Experience a lightweight, privacy-focused interface built with SwiftUI  

---

## ✨ Key Features

- **Create, Edit, and Manage Habits**  
  Add new habits, update them anytime, or archive when no longer needed.

- **Reminders and Notifications**  
  Set per-habit notifications and an evening summary reminder. The app automatically reschedules local notifications using `UNUserNotificationCenter`.

- **Daily Progress Tracking**  
  View your completion rate and streak statistics per habit.

- **Motivational Widget**  
  A home-screen widget that displays rotating motivational quotes each day, encouraging consistency and positivity.

- **Offline and Secure**  
  All data is stored locally using Core Data — no cloud sync, no data collection.

---

## 🧠 System Extensions

### Current Extensions
- **Widget Extension (WidgetKit)** – Displays daily motivational quotes, refreshed automatically every 24 hours.
- **Control Widget (AppIntent + WidgetKit)** – Example timer control using AppIntent, showcasing interactive widget capability.
- **Live Activity (ActivityKit)** – Demonstrates integration with Dynamic Island and Lock Screen Live Activities.

### Future Enhancements
- Siri Shortcuts integration for one-tap check-ins  
- Apple Watch companion app  
- Enhanced statistics charts for 30/60/90-day trends  

---

## ⚙️ Technical Details

### Platform & Requirements
- **iOS:** 16.0 or later  
- **Language:** Swift 5.9+  
- **Frameworks:** SwiftUI, CoreData, WidgetKit, AppIntents, ActivityKit, UserNotifications  

### Architecture
- **SwiftUI** handles UI and navigation (`NavigationStack`, `List`, `sheet`, `swipeActions`).  
- **Core Data** stores habit entities locally in an App Group container, enabling shared access between the app and widget.  
- **Notifications** manage daily and per-habit reminders.  
- **WidgetKit** provides static timeline-based content (daily quotes).  

### Data Model
| Attribute | Type | Description |
|------------|------|-------------|
| `id` | UUID | Unique habit identifier |
| `tittle` | String | Name of the habit |
| `createdAt` | Date | Creation timestamp |
| `isArchived` | Bool | Marks a habit as hidden instead of deleting |
| `hasGlobalReminder` | Bool | Whether global reminder is enabled |
| `reminderTime` | Date? | Time of individual reminder |
| `completionDates` | Transformable | Array of completion dates for streak calculation |

---

## 🔔 Notifications

- **Individual Habit Reminders:** Users can enable reminders for specific habits.  
- **Evening Summary:** Optional daily notification showing unfinished habits.  
- **Permission Handling:** Notification access requested once on first use.  

---

## 🔐 Privacy & Security

- All user data is stored locally on device (Core Data, App Group container).  
- No cloud synchronization or remote servers.  
- No analytics, tracking, or third-party SDKs.  
- Minimal permissions: only local notifications are requested.

---

## 🧩 Project Structure
```text
HabitTracker/
├── Models/
│   ├── Habit.swift
│   ├── NotificationManager.swift
│   ├── PersistenceController.swift
│   └── SharedDataManager.swift
│
├── Views/
│   ├── TodayView.swift
│   ├── HabitEditView.swift
│   ├── HabitRow.swift
│   ├── StatsView.swift
│   └── SettingsView.swift
│
├── HabitTrackerWidgetExtension/
│   ├── HabitTrackerWidget.swift
│   ├── HabitTrackerWidgetControl.swift
│   ├── HabitTrackerWidgetLiveActivity.swift
│   ├── AppIntent.swift
│   └── HabitTrackerWidgetBundle.swift
│
├── Assets/
├── HabitTrackerTests/
├── HabitTrackerUITests/
└── HabitTrackerApp.swift
```

---

## 🧪 Testing

- **Unit Tests (`HabitTrackerTests`):**
  - `testCreateHabitAndFetch()`
  - `testMarkCompleteAndRecalculate()`
  - `testStreakCalculation()`
  - `testCompletionRate30Days()`

- **UI Tests (`HabitTrackerUITests`):**
  - `testCreateEditDeleteHabitFlow()`
  - `testLaunch()`

All tests pass successfully on Xcode 15.0 with iPhone 16 simulator.

---

## 🚀 How to Run

1. Open `HabitTracker.xcodeproj` in Xcode 15 or later  
2. Select **iPhone 16** (or any iOS 16+ device) as target  
3. Press **Run (⌘ + R)**  
4. Allow notification permissions when prompted  

> If you wish to preview widgets, build the **HabitTrackerWidgetExtension** target and add it to your simulator’s home screen.

---

## 👨‍💻 Authors

- **Soorya Sanand** — Notification System, Shared Data Management, Settings UI, Habit Row  
- **Yash Patil** — Core View Development, Habit Editing & Statistics View, Today Screen Logic  
- **Tingxuan Zhang** — Core Data Stack, UI & Unit Testing, App Structure, Today View Integration  
- **Grace Cen** — WidgetKit Integration, Daily Quote Widget, Control Widget, Live Activity Extension  

---

## 💬 Support

For questions, bug reports, or feedback:  
- **GitHub Repository:** [https://github.com/YuukiAsuna-520/habit-tracker](https://github.com/YuukiAsuna-520/habit-tracker)
- **Issues:** [https://github.com/your-username/habit-tracker/issues](https://github.com/YuukiAsuna-520/habit-tracker/issues)

---

## 🏁 Summary

HabitTracker is designed to make habit-building simple, motivating, and privacy-first. With Core Data persistence, local notifications, and dynamic widgets, it offers an end-to-end iOS-native experience built for consistency and mindfulness.

