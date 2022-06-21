import 'package:anime_finder/theme/lib_color_schemes.g.dart';
import 'package:flutter/material.dart';

import 'style.dart';

ThemeData themeData(ColorScheme colorScheme) => ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: kCurrentTextTheme,
    colorScheme: colorScheme,
    brightness: colorScheme.brightness,
    appBarTheme: AppBarTheme(
        color: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        iconTheme: IconThemeData(color: colorScheme.onBackground)),
    primaryColor: colorScheme.primary,
    scaffoldBackgroundColor: colorScheme.background,
    backgroundColor: colorScheme.background,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.background,
      unselectedItemColor: colorScheme.onBackground,
      selectedItemColor: colorScheme.primary,
    ),
    dialogBackgroundColor: colorScheme.background,
    dialogTheme: DialogTheme(
        backgroundColor: colorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: kTitleMedium,
        contentTextStyle: kBodySmall),
    scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(
            colorScheme.onBackground.withOpacity(0.8)),
        trackColor: MaterialStateProperty.all(
            colorScheme.onBackground.withOpacity(0.5))),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.onBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: kBodySmall.copyWith(
        color: colorScheme.background,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: colorScheme.primary,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all(colorScheme.background.withOpacity(0.8)),
      foregroundColor: MaterialStateProperty.all(colorScheme.onBackground),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      )),
    )));

final ThemeData kLightThemeData = themeData(lightColorScheme);
final ThemeData kDarkThemeData = themeData(darkColorScheme);
