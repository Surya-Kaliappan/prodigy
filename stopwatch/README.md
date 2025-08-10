# Stopwatch Application - A Flutter Project

This project is a modern, highly animated, and fully-featured stopwatch application built with Flutter. It's designed to be a visually engaging and user-centric tool for timekeeping, featuring a dynamic UI that is both beautiful and functional. The application supports both light and dark modes and includes a comprehensive settings panel for user customization.

## 📸 Screenshots

Here are some showcases of the application in both light and dark modes, displaying various features.

| Light Mode | Dark Mode | Settings |
| :---: | :---: | :---: |
| <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/stopwatch/assets/screenshots/white_mode.jpg" alt="Light Mode" width="300"/> | <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/stopwatch/assets/screenshots/dark_mode.jpg" alt="Light Mode" width="300"/> | <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/stopwatch/assets/screenshots/settings.jpg" alt="Light Mode" width="300"/> |
| **Starting Timer** | **Laps and Background Changing** | **Stopping Timer** |
| <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/stopwatch/assets/screenshots/start_watch.jpg" alt="Light Mode" width="300"/> | <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/stopwatch/assets/screenshots/laps.jpg" alt="Light Mode" width="300"/> | <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/stopwatch/assets/screenshots/stop_watch.jpg" alt="Light Mode" width="300"/> |


---
## ✨ Features

- **Dynamic Timer Display:** A central, oval-shaped "rely round" inspired by a running track shows the 60-second progress.
- **Lap & Split Time:** Includes a professional lap system that records both the total time and the split time between laps. A secondary timer displays the running split time.
- **"Energy Level" Color System:** The app's theme color changes every 60 seconds to a new, random, vibrant color, providing visual feedback on duration.
- **Animated Background:** A multi-layered background system features a swirling gradient and moving particles that activate when the timer is running.
- **Glassmorphism UI:** A beautiful "frosted glass" effect is applied to the lap list and control buttons for a modern, layered aesthetic.
- **User Settings:** A dedicated settings screen allows users to:
    - Manually select **Light, Dark, or System** theme.
    - Toggle **Dynamic Color Cycling** on or off.
    - Choose a **static theme color** if dynamic cycling is disabled.
    - Toggle the **background particle effect** on or off.
- **Persistence:** All user settings are saved locally on the device and are remembered when the app is closed and reopened.
- **Responsive Design:** The layout is designed to be responsive and look great on various screen sizes.

---
## ⚠️ Known Limitations

- **Background Execution:** This application is designed to run in the foreground. If the app is minimized (sent to the background) or if the screen is turned off for an extended period, the operating system (iOS/Android) will freeze the app's process to save battery. As a result, the timer will be paused and will **not** continue to run in the background.

---
## 🛠️ Technologies Used

- **Flutter:** The core framework for building the cross-platform application.
- **Dart:** The programming language used for Flutter development.
- **Provider:** For simple and effective state management of user settings.
- **Development Environment:** Visual Studio Code with official Flutter and Dart extensions.

---
## 📂 File Structure

The project is organized into a clean and modular structure for better maintainability.

Of course. My apologies for the misunderstanding. Here is the exact raw text you need to copy and paste into your README.md file to create the file structure section with a fixed, pre-formatted look.

Using triple backticks ``` will ensure it renders as a code block and not a paragraph.

Markdown

---
## 📂 File Structure

stopwatch_app/  
├── lib/  
│   ├── main.dart             # Main entry point, theme definitions, and provider setup.  
│   ├── stopwatch_page.dart   # The main screen, containing all stopwatch logic and UI.  
│   ├── settings_page.dart    # The UI for the user settings screen.  
│   ├── settings_provider.dart# Manages the state and persistence of user settings.  
│   └── widgets.dart          # Contains all custom painters and smaller reusable widgets.  
│  
├── assets/  
│   └── icon.png              # The source image for the app icon.  
│  
└── pubspec.yaml              # Project dependencies and configuration.  


---
## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### **Prerequisites**

- You must have the Flutter SDK installed on your system.
- An emulator or a physical device to run the application.

### **Installation & Setup**

1.  **Clone the repo**
    ```sh
    git clone [https://github.com/Surya-Kaliappan/prodigy/tree/main/stopwatch](https://github.com/Surya-Kaliappan/prodigy/tree/main/stopwatch)
    ```
2.  **Navigate to the project directory**
    ```sh
    cd your-project-folder-name
    ```
3.  **Install packages**
    ```sh
    flutter pub get
    ```
4.  **Run the app**
    ```sh
    flutter run
    ```