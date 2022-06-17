import 'package:anime_finder/service/settings.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/show_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static final actions = <Widget>[];

  @override
  Widget build(BuildContext context) {
    final settings = Settings.list;
    return StatefulBuilder(
      builder: (context, setState) => ListView.builder(
        controller: ScrollController(),
        itemCount: settings.length + 2,
        itemBuilder: (context, index) {
          if (index < settings.length) {
            return settings[index]().widget(setState);
          }
          if (index == settings.length) {
            return Visibility(
              visible: kDebugMode,
              child: ListTile(
                title: Text(trSettingResetAllSettings,
                    style: kTitleMedium.copyWith(
                      color: Colors.redAccent,
                    )),
                onTap: () {
                  Get.defaultDialog(
                    backgroundColor: kBackgroundColor,
                    radius: 16,
                    titleStyle: kTitleMedium,
                    title: trWarning,
                    content:
                        Text(trSettingResetAllSettingsConfirm, style: kBodySmall),
                    actions: [
                      MaterialButton(
                        child: Text(trConfirm, style: kLabelSmall),
                        onPressed: () async {
                          await showToast(message: 'Restart app to apply settings');
                          await Settings.reset();
                          Get.back(closeOverlays: true);
                        },
                      ),
                      MaterialButton(
                        child: Text(trCancel, style: kLabelSmall),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  );
                },
              ),
            );
          } else {
            return ListTile(
              title: Text(trVersion, style: kTitleSmall),
            );
          }
        },
      ),
    );
  }
}
