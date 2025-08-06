# Simple Calculator App

This is a modern, cross-platform calculator application built with Flutter. It was developed as the first task during my Android Developer Internship at @Prodilogy.

The app provides a clean, intuitive user interface and performs standard arithmetic operations with a focus on a professional, responsive user experience.

<br>

<p align="center">
  <!-- Replace this with an actual image URL of your app's UI on GitHub -->
  <img src="https://via.placeholder.com/400x800?text=Calculator+App+Screenshot" alt="Simple Calculator App UI" width="300"/>
</p>

---

## ✨ Features

* **Cross-Platform:** Developed with **Flutter** and **Dart**, enabling a single codebase for both Android and iOS mobile platforms.
* **Intuitive UI:** Features a clean, dark-themed interface with distinct buttons and clear typography.
* **Dynamic Display:** The calculator's display automatically **scales down font size** and **wraps to a maximum of two lines** to accommodate long expressions, ensuring readability without horizontal scrolling.
* **Realistic Calculation Logic:**
    * Correctly evaluates mathematical expressions following **BODMAS** (Order of Operations) using the `math_expressions` package.
    * **Operator Replacement:** Automatically replaces a previously entered operator if a new one is typed consecutively (e.g., `5 + x` becomes `5 x`).
    * **Single Decimal Point:** Prevents multiple decimal points in a single number.
    * **Clean Results:** Formats results to remove unnecessary trailing zeros for whole numbers (e.g., `5` instead of `5.00000000`).
    * **Error Handling:** Displays "Error" for invalid operations like division by zero.
* **Standard Calculator Functions:** Includes all basic arithmetic operations (`+`, `-`, `x`, `÷`, `%`), along with `Clear (C)` and `Delete (⌫)` buttons.
* **Visual Feedback:** Buttons feature subtle elevation and animation on press, enhancing user interaction.
* **Custom App Icon & Name:** Configured for both Android and iOS platforms.

---

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (UI Toolkit)
* **Language:** [Dart](https://dart.dev/) (Programming Language)
* **State Management:** `StatefulWidget` with `setState()` for managing UI updates.
* **Expression Evaluation:** [`math_expressions`](https://pub.dev/packages/math_expressions) package for parsing and evaluating mathematical strings.
* **Dynamic Text Sizing:** [`auto_size_text`](https://pub.dev/packages/auto_size_text) package for intelligent font scaling.
* **App Icon Generation:** [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) package for automating icon generation.
* **Development Environment:** Visual Studio Code with official Flutter and Dart extensions.

---

## 🚀 Getting Started

Follow these steps to get a copy of the project up and running on your local machine.

### Prerequisites

Before you begin, ensure you have the Flutter SDK installed and configured.

* **Flutter SDK:** Follow the official installation guide for your operating system: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
* **Git:** Required for cloning the repository.
* **VS Code:** (Recommended IDE) Download from [Visual Studio Code](https://code.visualstudio.com/).
    * Install the **Flutter** extension (which includes the Dart extension) from the VS Code Marketplace.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/Surya-Kaliappan/prodilogy.git](https://github.com/Surya-Kaliappan/prodilogy.git)
    ```

2.  **Navigate to the project directory:**
    ```bash
    cd prodilogy
    ```

3.  **Install dependencies:**
    Fetch all the required Dart and Flutter packages:
    ```bash
    flutter pub get
    ```

4.  **Generate app icons:**
    Ensure your custom icon is located at `assets/icon/app_icon.png` (as configured in `pubspec.yaml`). Then, run:
    ```bash
    flutter pub run flutter_launcher_icons:main
    ```

### Running the App

1.  **Connect a device:**
    Ensure your Android device (physical or emulator) is connected via USB and has USB debugging enabled.
    Verify Flutter detects it:
    ```bash
    flutter devices
    ```

2.  **Run the application:**
    From the project root directory in your terminal, run:
    ```bash
    flutter run
    ```
    This will build and deploy the app to your connected device.

### Building an APK (Android Package)

To create a release-ready APK file:

1.  Open your terminal in the project root.
2.  Run the build command:
    ```bash
    flutter build apk --release
    ```
3.  The generated APK will be located at:
    `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 App Demonstration

<p align="center">
  <img src="https://media.licdn.com/dms/image/v2/D5622AQElmG3sfCktoQ/feedshare-shrink_1280/B56Zh9tfvNHcAk-/0/1754455736651?e=1757548800&v=beta&t=3-_wE5RexFoV0RndZ9-5PLw-_sTWLC-wsESthgCx1eI" alt="Calculator App Dark Theme" width="150" style="margin-right: 10px;"/>
  <img src="https://media.licdn.com/dms/image/v2/D5622AQEQvg3cPmZBNw/feedshare-shrink_1280/B56Zh9tfvTHcAo-/0/1754455736964?e=1757548800&v=beta&t=EPOCIurWmgEVDo2rMNfD_aFn3DI2ziQXbmFjr1MtaBc" alt="Calculator App Light Theme" width="150" style="margin-right: 10px;"/>
</p>

---

## 🤝 Contribution

This project was developed as a learning exercise during my internship. Feedback, bug reports, and feature suggestions are welcome! Feel free to open an issue or submit a pull request.

---

## 🧑 Author

* SURYA - Android Developer Intern at @Prodilogy

---