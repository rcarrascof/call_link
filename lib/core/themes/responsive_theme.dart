import 'package:flutter/material.dart';

class ResponsiveTheme {
  static ThemeData getTheme(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && 
                    MediaQuery.of(context).size.width < 900;

    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      // Textos responsive
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: isMobile ? 18 : isTablet ? 20 : 24,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          fontSize: isMobile ? 14 : isTablet ? 16 : 18,
        ),
      ),
      // Botones responsive
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
            vertical: isMobile ? 12 : 16,
          ),
          textStyle: TextStyle(
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ),
    );
  }
}