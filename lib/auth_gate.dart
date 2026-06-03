import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'main.dart';
import 'responsive_auth_wrapper.dart';
import 'theme/app_colors.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fba.User?>(
      stream: fba.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ResponsiveAuthWrapper(
            title: 'Pasta Shop',
            child: SignInScreen(
              providers: [EmailAuthProvider()],
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
              footerBuilder: (context, action) {
                return _GoogleAccountChooserButton(clientId: clientId);
              },
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

class _GoogleAccountChooserButton extends StatefulWidget {
  const _GoogleAccountChooserButton({required this.clientId});

  final String clientId;

  @override
  State<_GoogleAccountChooserButton> createState() =>
      _GoogleAccountChooserButtonState();
}

class _GoogleAccountChooserButtonState
    extends State<_GoogleAccountChooserButton> {
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      if (kIsWeb) {
        final provider = fba.GoogleAuthProvider()
          ..setCustomParameters(const {'prompt': 'select_account'});
        await fba.FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn(
          clientId: widget.clientId,
          scopes: const ['email', 'profile'],
        ).signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;
        final credential = fba.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await fba.FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(
                    color: AppColors.softInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isSigningIn ? null : _signInWithGoogle,
            icon: _isSigningIn
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'G',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
            label: Text(
              _isSigningIn
                  ? 'Opening Google...'
                  : 'Continue with Google account',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
