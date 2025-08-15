# QR Scan - A Flutter Project

This is a modern and cross-platform QR code utility application built with Flutter. It was developed as the fifth task (Task 5) during my Developer Internship at **Prodigy InfoTech**. The app provides a clean, animated user interface and goes beyond simple scanning to offer a complete set of tools for handling QR codes, including intelligent actions, scan history, and advanced user settings.

---

## ✨ Features

* **Real-time Scanning:** A high-performance camera view with a custom "twinkling dots" animation to indicate the scanning process.
* **Intelligent Actions:** The app automatically detects the type of content in a QR code and provides specific actions:
    * **URL:** Open links directly in a browser.
    * **Wi-Fi:** Display the network name (SSID) and password with a one-tap copy button.
    * **vCard:** Parse contact information and offer to save it to the device's contacts.
    * **Email/Phone:** Provide buttons to immediately send an email or make a call.
* **Scan from Gallery:** Users can select an image from their photo library to scan for a QR code.
* **Advanced Scanner Controls:**
    * **Pinch-to-Zoom:** An intuitive two-finger gesture to zoom the camera for scanning small or distant codes.
    * **Flashlight Toggle:** Easily turn the device's torch on or off for scanning in low-light conditions.
* **Scan History:**
    * All scans are automatically saved locally on the device.
    * A dedicated history screen allows users to view, search, and delete past scans.
* **Modern UI/UX:**
    * **Animated Navigation:** A custom-built, floating navigation system with smooth animations.
    * **Light & Dark Modes:** A full settings screen allows users to choose between light, dark, or system-default themes.
* **Persistence:** All user settings, including theme preference and zoom sensitivity, are saved and loaded automatically.

## 🛠️ Technologies Used

* **Flutter:** The core framework for building the cross-platform application.
* **Dart:** The programming language used for Flutter development.
* **Development Environment:** Visual Studio Code with official Flutter and Dart extensions.

## 📂 File Structure

The project is organized into a clean and modular structure for better maintainability.

```
quantum_scan/  
├── lib/  
│   ├── main.dart                 # Main entry point, theme definitions, and provider setup.  
│   ├── providers/  
│   │   └── theme_provider.dart   # Manages the state for light/dark mode.  
│   └── screens/  
│       ├── main_screen.dart      # The main screen with the custom animated navigation.  
│       ├── scanner_screen.dart   # Contains the camera view and all scanner logic.  
│       ├── result_screen.dart    # Displays scan results with intelligent action buttons.  
│       ├── history_screen.dart   # Shows the list of saved scans with search functionality.  
│       └── settings_screen.dart  # The UI for all user settings.  
│  
└── pubspec.yaml                  # Project dependencies and configuration.  
```

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### **Prerequisites**

* You must have the Flutter SDK installed on your system.
* An emulator or a physical device to run the application.

### **Installation & Setup**

1.  **Clone the repo**
    ```
    git clone https://github.com/Surya-Kaliappan/prodigy/tree/main/qr_scan
    ```
2.  **Navigate to the project directory**
    ```
    cd qr_scan
    ```
3.  **Install packages**
    ```
    flutter pub get
    ```
4.  **Run the app**
    ```
    flutter run
    ```