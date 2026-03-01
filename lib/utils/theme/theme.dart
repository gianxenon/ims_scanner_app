import 'package:flutter/material.dart';
import 'package:ims_scanner_app/utils/theme/custom_themes/appbar_theme.dart';
import 'package:ims_scanner_app/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:ims_scanner_app/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:ims_scanner_app/utils/theme/custom_themes/chip_theme.dart';
import 'package:ims_scanner_app/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:ims_scanner_app/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:ims_scanner_app/utils/theme/custom_themes/text_field_theme.dart';
import 'package:ims_scanner_app/utils/theme/custom_themes/text_theme.dart';

class AppTheme {
  AppTheme._();

static const _lightScheme = ColorScheme.light(
  surface: Colors.white,
  onSurface: Colors.black, 
  primary: Colors.black,
  onPrimary: Colors.white,
);

static const _darkScheme = ColorScheme.dark(
  surface: Color(0xFF121212),
  onSurface: Colors.white, 
  primary: Colors.white,
  onPrimary: Colors.black,
);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: _lightScheme,
    textTheme: AppTextTheme.lightTextTheme,
    chipTheme: AppChipTheme.lightChipTheme,
    checkboxTheme: AppCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: AppBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: AppTextFieldTheme.lightInputDecorationTheme,
    appBarTheme: AppbarTheme.light(_lightScheme), // ✅
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: _darkScheme,
    textTheme: AppTextTheme.darkTextTheme,
    chipTheme: AppChipTheme.darkChipTheme,
    checkboxTheme: AppCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: AppBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: AppTextFieldTheme.darkInputDecorationTheme,
    appBarTheme: AppbarTheme.dark(_darkScheme), // ✅
  );
}