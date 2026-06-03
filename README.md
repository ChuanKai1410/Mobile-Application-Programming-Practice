[![Flutter CI/CD](https://github.com/ChuanKai1410/Mobile-Application-Programming-Practice/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/ChuanKai1410/Mobile-Application-Programming-Practice/actions/workflows/flutter-ci.yml)

# Pasta Shop Firebase Recipe App

## Project Overview

Pasta Shop is a Flutter recipe and ordering application integrated with Firebase. The app stores recipe data in Cloud Firestore, supports authenticated users, and provides complete recipe CRUD operations. Users can browse recipes, search by keyword, filter by category or vegetarian status, view recipe details, add items to cart, and place orders that are saved to Firestore.

The interface has been redesigned with a cheerful, balanced theme so important actions such as adding recipes, viewing details, checkout, and authentication are easy to notice without making the screen visually overwhelming.

## Tech Used

* **Frontend:** Flutter and Dart
* **State Management:** Provider
* **Backend Database:** Firebase Cloud Firestore
* **Authentication:** Firebase Authentication, Email/Password, Google Sign-In
* **Configuration:** FlutterFire CLI, `flutter_dotenv`
* **Networking Demo:** HTTP-style request and response simulation using current recipe data
* **Serialization Demo:** JSON serialization, deserialization, and background parsing with isolates

## Firebase Database Design

### `recipes` collection

Each recipe document stores:

* `name` - recipe title
* `description` - recipe summary
* `category` - recipe category for filtering
* `price` - displayed recipe price
* `prepTime`, `cookTime`, `feeds` - recipe timing and serving information
* `ingredients` - list of ingredient strings
* `method` - list of cooking method steps
* `imageUrl` - online image URL used for display
* `isVegetarian` - vegetarian filter flag
* `createdBy` - Firebase Auth user id
* `createdAt`, `updatedAt` - Firestore timestamps

### `orders` collection

Each order document stores:

* `userId`
* `userEmail`
* `createdAt`
* `totalPrice`
* `items`

## Current Features

* **Firebase Authentication:** Users can sign in with email/password or choose an existing Google account through Google account chooser.
* **Recipe CRUD:** Users can add, view, edit, and delete recipes stored in Firestore.
* **Firestore Recipe Display:** Recipes are retrieved from Firestore and sorted by creation date.
* **Recipe Details:** Details page includes tabs for dish information, ingredients, and method steps.
* **Search:** Users can search recipes by name, description, or category.
* **Category Filtering:** Users can filter recipes using category chips.
* **Vegetarian Filtering:** Users can show only vegetarian recipes.
* **Recipe Images:** Users can paste an online image URL, which is saved in Firestore and displayed in the app.
* **Shopping Cart:** Users can add recipes to cart, adjust quantities, and view total price.
* **Checkout:** Orders are saved into the Firestore `orders` collection.
* **Favorites:** Users can mark recipes as favorites during the session.
* **Serialization Section:** Fetches current Firestore recipe data, converts it to JSON, deserializes it back into Dart objects, and demonstrates background parsing.
* **Networking & HTTP Section:** Uses current recipe data to demonstrate HTTP-style GET, POST, PATCH, and DELETE request/response flows.
* **Live Feed Simulation:** Simulates recipe-related live updates using a stream.

## Setup Guidance

### Prerequisites

1. Install the Flutter SDK.
2. Install VS Code or Android Studio with Flutter support.
3. Create or access a Firebase project.
4. Enable Firebase Authentication and Cloud Firestore.

### Installation

1. Clone or open this project.
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Create a `.env` file in the project root:

   ```env
   GOOGLE_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
   ```

4. Run the application:

   ```bash
   flutter run -d chrome
   ```

## Firebase Setup Guidance

1. Create a Firebase project in the Firebase Console.
2. Enable Authentication providers:
   * Email/Password
   * Google
3. Create a Cloud Firestore database.
4. Configure FlutterFire:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

5. Confirm that `lib/firebase_options.dart` and platform Firebase config files are generated.

## Suggested Firestore Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /recipes/{recipeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if request.auth != null;
    }

    match /orders/{orderId} {
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
      allow read: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }
  }
}
```

## Reflection

Integrating the mobile recipe application with Firebase made the app feel more complete and realistic because the data is no longer limited to local hardcoded recipes. By using Cloud Firestore, recipes can be created, read, updated, and deleted dynamically, and changes are reflected across the app without rebuilding it. Firebase Authentication also improves the application by allowing users to sign in securely before managing recipes or placing orders. Another advantage is that Firestore supports real-time synchronization, so updated recipe information can appear immediately on screens such as the recipe list and detail page. This makes the user experience smoother and more interactive.

However, integrating Firebase also introduced several challenges. The app needed a proper database structure, including fields such as recipe name, category, ingredients, method, image URL, creation date, and user information. Validation was also important to prevent incomplete or meaningless recipe data from being saved. Another challenge was handling platform-specific behavior, especially Google sign-in on web and image handling. Firebase Storage upload required additional configuration such as CORS and security rules, so using image URLs became a simpler and more reliable approach for this lab. Security rules were also important because unrestricted database access would be unsafe.

Overall, Firebase helped transform the recipe app into a cloud-based application with authentication, real-time data, and practical CRUD functionality, but it required careful planning, validation, and configuration.
