import 'package:anime_finder/theme/style.dart';
import 'package:get/get.dart';

SnackbarController? _snackbarController;

Future<void> showToast(
    {String? title, required String message, Duration? duration}) async {
  try {
    await _snackbarController?.close(withAnimations: false);
  } catch (e) {
    // ignore
  }
  _snackbarController = Get.snackbar(title ?? '', message,
      duration: duration ?? kSnackbarDuration,
      backgroundColor: kBackgroundColor,
      colorText: kOnBackgroundColor,
      snackPosition: kSnackbarPosition,
      animationDuration: (duration ?? kSnackbarDuration) * 0.8,
      isDismissible: true);
  // await Future.delayed(duration ?? kSnackbarDuration);
}
