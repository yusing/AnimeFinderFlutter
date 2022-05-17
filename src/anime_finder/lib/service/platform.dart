import 'dart:io';

class AFPlatform {
  static get isDesktop => Platform.isMacOS || Platform.isLinux || Platform.isWindows;
}