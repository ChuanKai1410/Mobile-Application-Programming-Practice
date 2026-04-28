import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'responsive_auth_wrapper.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ResponsiveAuthWrapper(
            title: 'Pasta Shop',
            child: SignInScreen(
              providers: [
                EmailAuthProvider(),
                GoogleProvider(clientId: "75890959312-qrvet5ognpqo1nf9in4b3e81hmuai5d7.apps.googleusercontent.com"),
              ],
              actions: [
                ForgotPasswordAction((context, email) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResponsiveAuthWrapper(
                        title: 'Reset Password',
                        child: ForgotPasswordScreen(
                          email: email,
                          headerMaxExtent: 0,
                        ),
                      ),
                    ),
                  );
                }),
              ],
              headerMaxExtent: 0,
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    action == AuthAction.signIn
                        ? 'Sign in to continue'
                        : 'Create your account',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
          );
        }

        return const HomeScreen();
      },
    );
  }
}
