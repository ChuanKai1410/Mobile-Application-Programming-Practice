import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Icon(Icons.restaurant, size: 80, color: Color(0xFFD32F2F)),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  action == AuthAction.signIn
                      ? 'Welcome to Pasta Shop! Please sign in to continue.'
                      : 'Welcome to Pasta Shop! Please create an account.',
                  style: const TextStyle(fontSize: 16, color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
                ),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Icon(Icons.restaurant, size: 80, color: Color(0xFFD32F2F)),
                ),
              );
            },
          );
        }

        return const HomeScreen();
      },
    );
  }
}
