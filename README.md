# Task Manager

A clean, modern, offline-first Task Management application built with Flutter.

## Overview
This application allows users to create, edit, delete, and manage tasks. It prioritizes offline usability by utilizing an offline-first architecture. Tasks are saved locally to SQLite and automatically synchronized with Firebase Cloud Firestore in the background when an internet connection is available. It also features a robust Firebase Authentication system, ensuring each user has a private, securely isolated workspace for their tasks.

## Architecture

The project strictly follows **Clean Architecture** to ensure testability, maintainability, and a clear separation of concerns.

The codebase is divided into three primary layers:
1. **Domain Layer (`lib/domain`)**: The innermost core of the application. It contains the pure business logic, entities (`Task`, `User`), repository interfaces, and independent Use Cases (e.g., `GetTasks`, `AddTask`, `LoginUseCase`). This layer has absolutely no dependencies on the UI or external data sources like Firebase.
2. **Data Layer (`lib/data`)**: Responsible for data retrieval and manipulation. It contains models for JSON serialization, along with local (`TaskLocalDataSourceImpl` via `sqflite`) and remote (`TaskRemoteDataSourceImpl`, `AuthRemoteDataSourceImpl` via `cloud_firestore` and `firebase_auth`) data sources. Repositories here handle offline-first logic and abstract SDK details away from the Domain.
3. **Presentation Layer (`lib/presentation`)**: Contains the `TaskController`, `AuthController`, and UI components. The UI is built using Material 3. State management, dependency injection, and routing are powered by **GetX**. The controllers exclusively interact with Domain Use Cases, keeping them fully decoupled from the Data Layer.

## Tech Stack
- **Framework**: Flutter / Dart (Null safety enabled)
- **State Management & DI**: GetX
- **Local Storage**: sqflite (SQLite)
- **Remote Storage & Database**: Firebase Cloud Firestore
- **Authentication**: Firebase Auth (Email & Password)
- **Connectivity**: connectivity_plus

## Setup Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (The project uses [FVM](https://fvm.app/) for version management).
- [Firebase CLI](https://firebase.google.com/docs/cli) installed and authenticated.

### 1. Clone the repository
```bash
git clone https://github.com/vishnuv6333/task_manager.gitv
cd task_manager
```

### 2. Install dependencies
```bash
fvm flutter pub get
```

### 3. Configure Firebase
This project relies on Firebase Cloud Firestore and Firebase Authentication. You need to connect it to your own Firebase project.
1. Run the FlutterFire CLI command at the root of the project to generate the `firebase_options.dart` file:
   ```bash
   flutterfire configure
   ```
   *(Select your Firebase project and desired platforms).*
2. **Enable Authentication**: Go to your Firebase Console -> Authentication -> Sign-in method, and enable **Email/Password**.

### 4. Run the App
```bash
fvm flutter run
```

## Features
- **Secure Authentication**: Users can securely sign up and log in using Firebase Auth.
- **Multi-User Isolation**: Tasks are securely scoped per user in both the cloud and local SQLite database.
- **Offline First**: Fully functional without internet access.
- **Background Sync**: Seamlessly syncs local changes to Firestore when the network is restored.
- **CRUD**: Create, read, update, and delete tasks.
- **Search & Filter**: Find tasks by title or filter by Completion/Pending status.
- **Sort**: Order tasks by Due Date or Priority.
- **Dark Mode**: Automatically respects OS-level dark/light mode preferences with a manual toggle switch in the UI.
- **Modern UI**: Clean and responsive Material 3 design.
