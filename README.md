
## Overview

This project provides a modern contacts experience with:

- Material 3 interface
- Android dynamic wallpaper-based theming
- Offline local storage using SQLite
- Contact creation, editing, deletion, and detailed profile viewing
- Favorites management
- Call, SMS, and email quick actions
- Custom Android launcher icon with themed icon support

## Features

### Core Contact Features

- View all saved contacts in an organized alphabetical list
- Search contacts by name, phone number, or email
- Add a new contact
- Edit an existing contact
- Delete a contact with confirmation
- View a detailed contact profile
- Mark and unmark contacts as favorites
- Access favorite contacts in a dedicated tab

### Contact Information Fields

- First name
- Last name
- Phone number
- Email address
- Company
- Address
- Notes
- Photo from camera or gallery

### Quick Actions

- Call a contact directly from the app
- Send SMS to a contact
- Send email to a contact

### UI and UX Improvements

- Material 3 design system
- Smooth animated list transitions
- Responsive layouts for different screen sizes
- Polished cards, sections, and contact detail screens
- Hero avatar transitions
- Pull-to-refresh behavior
- Modern bottom navigation

### Android Enhancements

- Dynamic color support using Android wallpaper colors where available
- Adaptive launcher icon
- Android 13 themed icon support
- Camera permission support for profile images

## Tech Stack

- Flutter
- Dart
- Provider for state management
- SQLite with `sqflite`
- `url_launcher` for call, SMS, and email actions
- `image_picker` for profile images
- `dynamic_color` for Android dynamic theming

## Project Structure

```text
lib/
  main.dart
  models/
  screens/
  services/
  utils/
  widgets/
```

## Installation

### Prerequisites

- Flutter SDK installed
- Android Studio or VS Code
- Android SDK configured
- A connected Android device or emulator

### Steps

1. Clone the repository.
2. Open the project folder.
3. Run:

```bash
flutter pub get
```

4. Start the app:

```bash
flutter run
```

## Build APK

To generate a debug APK:

```bash
flutter build apk --debug
```

The APK output will be available at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## How to Use

### Contacts Tab

- Browse contacts grouped alphabetically
- Use the search bar to find contacts
- Tap the create button to add a new contact
- Tap a contact to view full details
- Use the call action directly from the list

### Favorites Tab

- View all starred contacts
- Open favorite contacts quickly from the horizontal favorites section
- Tap any favorite to view its full profile

### Add/Edit Contact

- Fill in contact details
- Add a photo using camera or gallery
- Save to store the contact locally

### Contact Detail Screen

- View full contact information
- Call, message, or email the contact
- Edit the contact
- Delete the contact
- Toggle favorite status

## What Was Implemented


- Full SQLite-based offline contact management
- Bottom navigation with `Contacts` and `Favorites` tabs
- Dynamic Material 3 theming
- Google Contacts-inspired UI refinement
- Improved contact cards and detail screen layout
- Android launcher icon and themed icon support
- Better app theme handling for readable app bar titles
- Updated widget test to match the real application
- Android manifest updates for camera and contact action support

## Permissions Used

On Android, the app uses:

- Camera permission for taking profile photos

System actions like call, SMS, and email are launched using external apps through URL schemes.

## Testing

Used commands:

```bash
dart analyze lib test
flutter test
flutter build apk --debug
```

Note:

- Widget tests pass
- The analyzer may still show a few non-blocking info-level suggestions

## Screenshots / Demo

Add your screenshots or demo video links here before submission.

Suggested items:

- Home screen with contacts list
- Favorites tab
- Add contact screen
- Contact detail screen
- Search flow
- Themed app icon on Android launcher

Example section:

```text
screenshots/
  home.png
  favorites.png
  add_contact.png
  detail.png
```

Or include a demo video link:

```text
Demo Video: <add-your-link-here>
```

## Deliverables

### 1. Source Code on GitHub

- Push this Flutter project to a GitHub repository
- Include clear commit history if possible
- Make sure the repository contains the full source code and assets

### 2. Documentation

This README covers:

- App features
- Installation steps
- Usage instructions
- Tech stack
- Implementation notes

### 3. Screenshots or Video Demo

Before final submission, add:

- App screenshots in the repository
or
- A short video walkthrough showing all major features

## Submission Checklist

- Source code pushed to GitHub
- README updated
- Screenshots or demo video added
- APK tested on Android device/emulator
- All major assignment features demonstrated

## Author

Adarsh  
