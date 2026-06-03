import 'package:flutter/material.dart';

class AppColors {
  static const strawberry = Color(0xFFE85D75);
  static const berry = Color(0xFFB8325F);
  static const coral = Color(0xFFFF8A65);
  static const butter = Color(0xFFFFF4C7);
  static const cream = Color(0xFFFFFCF7);
  static const peach = Color(0xFFFFD6BA);
  static const mint = Color(0xFF79C7B7);
  static const leaf = Color(0xFF4E9F7A);
  static const cocoa = Color(0xFF4A3B35);
  static const softInk = Color(0xFF6B5B55);
  static const line = Color(0xFFFFB7A4);

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF8E7), Color(0xFFFFE1CC)],
  );

  static const authGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE85D75), Color(0xFFFFB86B), Color(0xFF79C7B7)],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFCF7), Color(0xFFFFF4C7)],
  );

  static const highlightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFCF7), Color(0xFFFFE7D8)],
  );
}
