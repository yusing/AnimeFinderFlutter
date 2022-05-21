import 'dart:io';

import 'package:anime_finder/service/translation.dart';
import 'package:flutter/gestures.dart';
import 'package:get_storage/get_storage.dart';
import 'package:anime_finder/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/nav.dart';
import 'service/settings.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await GetStorage.init();
  runApp(GetMaterialApp(
    theme: kLightThemeData,
    darkTheme: kDarkThemeData,
    themeMode: Settings.darkMode.value ? ThemeMode.dark : ThemeMode.light,
    title: 'AnimeFinder',
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const NavPage(),
    },
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('zh'), Locale('en')],
    locale: Locale(Settings.locale.value),
    fallbackLocale: const Locale('en'),
    translations: TranslationService(),
    builder: (BuildContext context, Widget? child) {
      final MediaQueryData data = MediaQuery.of(context);
      return MediaQuery(
        data: data.copyWith(
            textScaleFactor: data.textScaleFactor * Settings.textScale.value),
        child: child ?? Container(),
      );
    },
    
    scrollBehavior: AFScrollBehaviour(),
  ));
}

class AFScrollBehaviour extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
