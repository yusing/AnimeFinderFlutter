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
