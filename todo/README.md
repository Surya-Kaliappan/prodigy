# Prodigy Infotech - Task 2: To-Do List Mobile Application

This repository contains the source code for a comprehensive To-Do List mobile application built with Flutter. This project was developed as the second task for my Android Developer Internship at Prodigy InfoTech.

The goal of this task was to create a full-featured to-do application that allows users to manage their daily tasks effectively, with a focus on a clean user interface, intuitive controls, and persistent data storage.

---

## 🌟 Key Features

The application is packed with features designed for a seamless and productive user experience:

-   **Full CRUD Functionality**: Users can easily **C**reate, **R**ead, **U**pdate, and **D**elete tasks.
-   **Intuitive UI**: A clean, modern user interface that is easy to navigate.
-   **Light & Dark Mode**: The app automatically adapts to the system's theme, providing a comfortable experience in any lighting condition.
-   **Persistent Storage**: Tasks are saved locally on the device using `shared_preferences`. This means your to-do list is preserved even after you close and reopen the app.
-   **Advanced Gestures**:
    -   **Swipe-to-Delete**: A user-friendly slide action reveals a delete button, preventing accidental deletions.
    -   **Long-Press for Multi-Select**: A powerful feature that allows users to enter a selection mode to delete multiple tasks at once.
-   **Separate Task Lists**: The UI intelligently separates tasks into "To Be Completed" and "Completed" sections, with the completed list being collapsible to save space.
-   **Dedicated Search Screen**: A smooth, animated transition takes the user to a dedicated screen to search and filter through their tasks.
-   **Custom App Icon**: A unique and professional app icon designed specifically for this application.

---

## 📸 Application Screenshots

*(It is highly recommended to add your own screenshots here to visually showcase the app. Here are some suggestions for what to include.)*

| Light Mode                                      | Dark Mode                                     | Search Action                                     |
| :----------------------------------------------: | :---------------------------------------------: | :---------------------------------------------: |
| <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/todo/assets/screenshots/white_mode.jpg" alt="Light Mode" width="300"/> | <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/todo/assets/screenshots/dark_mode.jpg" alt="Dark Mode" width="300"/> | <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/todo/assets/screenshots/search_screen.jpg" alt="Dark Mode" width="300"/> |

| Swipe Action                                       | Multi-Select Mode                                      |
| :------------------------------------------------: | :----------------------------------------------------: |
| <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/todo/assets/screenshots/swipe_delete.jpg" alt="Swipe Action" width="300"/> | <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/todo/assets/screenshots/multiple_delete.jpg" alt="Multi-Select Mode" width="300"/> |

---

## 🛠️ Tech Stack & Dependencies

This project leverages the power of Flutter and several key packages to deliver a robust experience:

* **Framework:** [Flutter](https://flutter.dev/) (UI Toolkit)
* **Language:** [Dart](https://dart.dev/) (Programming Language)
* **Development Environment:** Visual Studio Code with official Flutter and Dart extensions.

---

## 📂 Project Structure

The project is organized into a clean and scalable structure to ensure maintainability:

lib/  
├── main.dart             # App entry point and theme configuration  
├── models/  
│   └── task.dart         # The data model for a single task  
├── screens/  
│   ├── home_screen.dart    # Main screen displaying task lists  
│   └── search_screen.dart  # Dedicated screen for searching tasks  
├── services/  
│   └── task_storage.dart # Handles saving/loading tasks from storage  
└── widgets/  
├── add_task_bottom_sheet.dart # UI for adding/editing tasks  
└── task_item.dart      # Custom widget for displaying a single task  

---

## (Challenges Faced) & Future Updates

One of the most significant challenges during this project was the implementation of a fully reliable, real-time notification system for task reminders. This feature requires deep integration with the native Android operating system, including managing background services, handling aggressive battery optimization on different devices, and ensuring permissions are correctly handled.

After extensive research and multiple implementation attempts, I recognized that delivering a feature that works flawlessly across all Android devices is a project in itself. I believe in shipping high-quality, reliable features.

Therefore, I have made the strategic decision to perfect the notification system and plan to release it as a **major future update**. This experience was an invaluable lesson in the complexities of native mobile development and has deepened my appreciation for robust, well-tested code.

---
