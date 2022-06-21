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
      if (this == nullptr) return '';
      return cast<Utf8>().toDartString();
    } catch (e) {
      return '';
    }
  }
}

extension FormatExtension on num {
  String toReadableSize() {
    if (this < 1024) {
      return '${toStringAsFixed(1)} B';
    } else if (this < 1024 * 1024) {
      return '${(this / 1024).toStringAsFixed(1)} KB';
    } else if (this < 1024 * 1024 * 1024) {
      return '${(this / 1024 / 1024).toStringAsFixed(1)} MB';
    } else {
      return '${(this / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
    }
  }
}
