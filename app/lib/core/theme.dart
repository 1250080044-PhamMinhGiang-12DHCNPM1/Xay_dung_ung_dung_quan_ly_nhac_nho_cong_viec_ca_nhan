import 'package:flutter/material.dart';

class AppTheme {
  static const Color seed = Color(0xFF2E7D6B);

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );
}
