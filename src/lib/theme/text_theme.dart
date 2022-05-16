import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lib_color_schemes.g.dart';

TextTheme textTheme(ColorScheme colorScheme) =>
    GoogleFonts.droidSansTextTheme(TextTheme(
        displayLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        displayMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        displaySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onBackground,
        ),
        headlineLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        headlineSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onBackground,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        bodyLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w500,
          color: colorScheme.onBackground,
        ),
        bodyMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: colorScheme.onBackground,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onBackground,
        ),
        labelLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w500,
          color: colorScheme.onBackground,
        ),
        labelMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: colorScheme.onBackground,
        ),
        labelSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onBackground,
        )));

final TextTheme kDarkTextTheme = textTheme(darkColorScheme);
final TextTheme kLightTextTheme = textTheme(lightColorScheme);
