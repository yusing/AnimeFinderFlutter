import 'dart:io';

import 'package:anime_finder/service/libtorrent.dart';
import 'package:anime_finder/service/storage.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/theme.dart';
import 'package:anime_finder/utils/http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/route_manager.dart';

import 'pages/nav.dart';
import 'service/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  await TranslationService.init();
  await initStorage();

  HttpOverrides.global = MyHttpOverrides();
  await initLibTorrent();

  runApp(GetMaterialApp(
    theme: kLightThemeData,
    darkTheme: kDarkThemeData,
    themeMode: Settings.darkMode.value ? ThemeMode.dark : ThemeMode.light,
    title: 'AnimeFinder',
    debugShowCheckedModeBanner: false,
    home: const NavPage(),
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
