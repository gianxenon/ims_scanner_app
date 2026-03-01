import 'package:flutter/material.dart';

class AppBottomSheetTheme {
  AppBottomSheetTheme._();

  // -- light theme
  static   BottomSheetThemeData lightBottomSheetTheme = BottomSheetThemeData( 
      elevation: 0,
      backgroundColor: Colors.white,
      modalBackgroundColor: Colors.white,
      constraints: const BoxConstraints(minWidth: double.infinity),
      shape: RoundedRectangleBorder (borderRadius: BorderRadius.circular(16))
  );

    // -- dark theme
   static   BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData( 
      elevation: 0,
      backgroundColor: Colors.black,
      modalBackgroundColor: Colors.black,
      constraints: const BoxConstraints(minWidth: double.infinity),
      shape: RoundedRectangleBorder (borderRadius: BorderRadius.circular(16))
  );
  
}