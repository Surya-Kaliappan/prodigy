# Tic Tac Toe - A Flutter Project

This is a modern, visually engaging, and cross-platform Tic Tac Toe game built with Flutter. It was developed as the fourth task (Task 4) during my Developer Internship at **Prodigy InfoTech**. The app provides a dynamic, glowing "neon" user interface and performs all standard game functions, including score tracking and random player starts, with a focus on a professional and highly polished user experience.

## 📸 Screenshots

Here are some showcases of the application in both light and dark modes, displaying various features.

| **Initial** | **Random Start** | **Game 1** |
| :---: | :---: | :---: |
| <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/tic_tac_toe/assets/screenshot/atStart.jpg" alt="Light Mode" width="300"/> | <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/tic_tac_toe/assets/screenshot/randomSelect.jpg" alt="Light Mode" width="300"/> | <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/tic_tac_toe/assets/screenshot/atWin.jpg" alt="Light Mode" width="300"/> |
| **Game 2** | **Settings Screen** | 
| <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/tic_tac_toe/assets/screenshot/atDraw.jpg" alt="Light Mode" width="300"/> | <img src="https://github.com/Surya-Kaliappan/prodigy/blob/main/tic_tac_toe/assets/screenshot/settings.jpg" alt="Light Mode" width="300"/> | 

---
## ✨ Features

- **Responsive Design:** The layout automatically adapts for optimal viewing on both narrow (mobile) and wide (tablet/desktop) screens.
- **Glowing "Neon" UI:** All interactive elements, including the game board, player symbols, and scoreboard, feature a beautiful and consistent glow effect.
- **Animated Turn Indicator:** An arrow spins like a wheel to randomly select the starting player, then disappears. The active player's symbol glows brightly to indicate their turn.
- **Engaging Animations:**
    - **Winning Celebration:** A vibrant confetti explosion celebrates a player's victory.
    - **Winning Line Highlight:** The three winning cells glow brightly to clearly indicate the win.
- **User Settings:** A dedicated settings screen allows users to:
    - Manually select **Light, Dark, or System** theme.
    - Use a full color picker with transparency control to set a **custom glow color** for empty cells.
    - **Adjust the board size** on wide screens using a slider.
- **Persistence:** All user settings are saved locally on the device and are remembered when the app is closed and reopened.
- **Robust Game Logic:**
    - **Random Start:** The starting player is chosen randomly for each new game to ensure fairness.
    - **Score Tracking:** The score is tracked across multiple rounds and is revealed at the end of each game.
    - **Win/Draw Detection:** The app correctly identifies and handles win and draw conditions.

---
## 🛠️ Technologies Used

- **Flutter:** The core framework for building the cross-platform application.
- **Dart:** The programming language used for Flutter development.
- **Development Environment:** Visual Studio Code with official Flutter and Dart extensions.

---
## 📂 File Structure

The project is organized into a clean and modular structure for better maintainability.

tic_tac_toe/  
├── lib/  
│   ├── main.dart                 # Main entry point, theme definitions, and provider setup.  
│   ├── models/  
│   │   └── settings_provider.dart# Manages the state and persistence of user settings.  
│   ├── screens/  
│   │   ├── game_screen.dart      # The main screen, containing all game logic and UI.  
│   │   └── settings_screen.dart  # The UI for the user settings screen.  
│   └── widgets/  
│       ├── game_board.dart       # The 3x3 game grid widget.  
│       ├── game_cell.dart        # A single interactive cell widget.  
│       ├── glowing_o_painter.dart# Custom painter for the 'O' symbol.  
│       ├── glowing_x_painter.dart# Custom painter for the 'X' symbol.  
│       └── score_board.dart      # Displays player symbols, scores, and turn indicator.  
│  
└── pubspec.yaml                  # Project dependencies and configuration.  


---
## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### **Prerequisites**

- You must have the Flutter SDK installed on your system.
- An emulator or a physical device to run the application.

### **Installation & Setup**

1.  **Clone the repo**
    ```sh
    git clone https://github.com/Surya-Kaliappan/prodigy/tree/main/tic_tac_toe
    ```
2.  **Navigate to the project directory**
    ```sh
    cd tic_tac_toe
    ```
3.  **Install packages**
    ```sh
    flutter pub get
    ```
4.  **Run the app**
    ```sh
    flutter run
    ```