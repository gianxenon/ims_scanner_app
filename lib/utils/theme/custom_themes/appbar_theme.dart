import 'package:flutter/material.dart';

class AppbarTheme {
  AppbarTheme._();

  static AppBarTheme light(ColorScheme cs) => AppBarTheme(
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: cs.onPrimary, // 🔥 auto contrast
      );

  static AppBarTheme dark(ColorScheme cs) => AppBarTheme(
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: cs.onPrimary,
      );
}