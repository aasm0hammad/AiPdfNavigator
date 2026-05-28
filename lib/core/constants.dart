import 'package:flutter/material.dart';

class AppColors {
  // Common
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Colors.grey;
  static const Color white = Colors.white;

  // Auth Theme (Image 1)
  static const Color authBackground = Color(0xFFF0F1F5);
  static const Color authPrimary = Color(0xFF3EB075); // Green button
  static const Color inputFill =
      Color(0xFFF8F9FA); // Very light grey for inputs

  // App Theme (Image 2)
  static const Color appBgTop = Color(0xFFF3E7E9);
  static const Color appBgBottom = Color(0xFFE4DFEC);
  static const Color iconPink = Color(0xFFF22079);
  static const Color iconBlue = Color(0xFF4285F4);
  static const Color iconYellow = Color(0xFFFFD426);

  static const Color aiBubble = Colors.white;

  // Gradients
  static const LinearGradient appBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [appBgTop, appBgBottom],
  );

  static const LinearGradient userBubbleGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFA4CF), Color(0xFFFFC6CA)],
  );
}

class AppConstants {
  static const String geminiApiKey =
      "AIzaSyD-5q_esIrKCnD-xD7rUJsUC2NN4WgZ5oA";
}
