import 'dart:io';

class AFPlatform {
  static get isDesktop => Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  static get isMobile => Platform.isAndroid || Platform.isIOS;
}