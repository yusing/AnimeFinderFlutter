import 'package:anime_finder/theme/style.dart';
import 'package:get/get.dart';

Future<void> showToast(
    {String? title, required String message, Duration? duration}) async {
  Get.snackbar(title ?? '', message,
      duration: duration ?? kSnackbarDuration,
      backgroundColor: kBackgroundColor,
      colorText: kOnBackgroundColor,
      snackPosition: kSnackbarPosition,
      isDismissible: false);
  await Future.delayed(duration ?? kSnackbarDuration);
}
