[![Flutter CI/CD](https://github.com/ChuanKai1410/Mobile-Application-Programming-Practice/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/ChuanKai1410/Mobile-Application-Programming-Practice/actions/workflows/flutter-ci.yml)
# Pasta Shop Application 🍝

## Project Overview
Pasta Shop is a modern, fully responsive, cross-platform e-commerce application built with Flutter. It allows users to browse an exquisite menu of Italian pasta dishes, view detailed recipes and preparation methods, add items to a dynamic shopping cart, and securely check out. The application features a robust authentication flow, ensuring user sessions and order histories are safely managed.

## Tech Used
*   **Frontend Framework:** Flutter (Dart)
*   **State Management:** Provider
*   **Backend / Database:** Firebase (Cloud Firestore)
*   **Authentication:** Firebase Auth, Google OAuth (`firebase_ui_auth`, `firebase_ui_oauth_google`)
*   **Environment Configuration:** `flutter_dotenv`

## Current Features
*   **Responsive UI:** A beautifully designed interface that seamlessly adapts between mobile portrait and wide-screen web/desktop layouts.
*   **Authentication Flow:** Complete email/password registration, secure Google Sign-In integration, and password recovery.
*   **Interactive Menu:** Detailed screens for each pasta dish (Aglio Olio, Spicy Pasta, Creamy Garlic, Tomato Spaghetti) including ingredients, preparation methods, and pricing.
*   **Shopping Cart System:** A globally accessible cart that tracks selected dishes, handles quantities natively, and automatically calculates real-time total pricing.
*   **Checkout & Order Processing:** A locked receipt view that securely transmits finalized order details (items, total price, user data, timestamps) directly to the Cloud Firestore database.
*   **Secure Profile Management:** A read-only profile screen dynamically displaying the user's active sign-in methods (Google or Email).

## Setup Guidance

### Prerequisites
1.  Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2.  Install an IDE (VS Code or Android Studio) with the Flutter plugin.
3.  Ensure you have a modern web browser (for web testing) or a connected mobile emulator/device.

### Installation
1.  Clone this repository to your local machine.
2.  Open a terminal in the project root and run:
    ```bash
    flutter pub get
    ```
3.  Create a `.env` file in the root directory (see *Firebase Setup Guidance* below).
4.  Run the application on your preferred device (e.g., Chrome):
    ```bash
    flutter run -d chrome
    ```

## Firebase Setup Guidance
This project is deeply integrated with Firebase. To run it locally or deploy it, you must configure it with your own Firebase project.

1.  **Create a Firebase Project:**
    Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2.  **Enable Services:**
    *   **Authentication:** Enable the Email/Password provider. Enable the Google provider.
    *   **Firestore Database:** Create a Cloud Firestore database. Start in Test Mode (or configure your security rules to allow authenticated users to write to the `orders` collection).
3.  **Configure FlutterFire:**
    Install the FlutterFire CLI and run the configuration wizard in the root of your project:
    ```bash
    dart pub global activate flutterfire_cli
    flutterfire configure
    ```
    This will generate the `lib/firebase_options.dart` file automatically.
4.  **Configure Environment Variables (.env):**
    Create a file named `.env` in the root of your project. You must add your Web Client ID (found in your Firebase Console under Authentication -> Sign-in method -> Google -> Web SDK configuration) to this file:
    ```env
    GOOGLE_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
    ```
    *Note: Never commit your `.env` file or `firebase_options.dart` file to public version control if they contain sensitive production keys.*
