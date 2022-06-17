import 'package:anime_finder/service/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'lib_color_schemes.g.dart';
import 'text_theme.dart';

const double kAnimeCardHeight = 180;
const double kAnimeCardBorderRadius = 8;
const double kAnimeCardImageMaxHeight = 50;
const double kAnimeCardVImagePadding = 32;
const double kIconButtonSplashRadius = 24;
const kSnackbarDuration = Duration(seconds: 1);
const kSnackbarPosition = SnackPosition.TOP;

TextTheme get kCurrentTextTheme =>
    Settings.darkMode.value ? kDarkTextTheme : kLightTextTheme;

TextStyle get kTitleLarge => kCurrentTextTheme.titleLarge!;
TextStyle get kTitleMedium => kCurrentTextTheme.titleMedium!;
TextStyle get kTitleSmall => kCurrentTextTheme.titleSmall!;

TextStyle get kBodyLarge => kCurrentTextTheme.bodyLarge!;
TextStyle get kBodyMedium => kCurrentTextTheme.bodyMedium!;
TextStyle get kBodySmall => kCurrentTextTheme.bodySmall!;

TextStyle get kHeadlineLarge => kCurrentTextTheme.headlineLarge!;
TextStyle get kHeadlineMedium => kCurrentTextTheme.headlineMedium!;
TextStyle get kHeadlineSmall => kCurrentTextTheme.headlineSmall!;

TextStyle get kLabelLarge => kCurrentTextTheme.labelLarge!;
TextStyle get kLabelMedium => kCurrentTextTheme.labelMedium!;
TextStyle get kLabelSmall => kCurrentTextTheme.labelSmall!;

ColorScheme get currentColorScheme =>
    Settings.darkMode.value ? darkColorScheme : lightColorScheme;

Color get kBackgroundColor => currentColorScheme.background;
Color get kOnBackgroundColor => currentColorScheme.onBackground;
Color get kOnBackgroundColorDark =>
    currentColorScheme.onBackground.withOpacity(0.8);
Color get kOnBackgroundColorDarker =>
    currentColorScheme.onBackground.withOpacity(0.6);
Color get kHighlightColor => currentColorScheme.primary;
Color get kHighlightColorAlt => currentColorScheme.secondary;
