import 'dart:ffi';
import 'package:ffi/ffi.dart';

extension StringExtension on String {
  Pointer<Char> toNativeString() {
    return toNativeUtf8().cast<Char>();
  }

  String encodeUrl() {
    return Uri.encodeFull("file://${this}");
  }
}

extension NativeStringExtension on Pointer<Char> {
  String toDartString() {
    try {
      return cast<Utf8>().toDartString();
    }
    catch (e) {
      return '';
    }
  }
}
