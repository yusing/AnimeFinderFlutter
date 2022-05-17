import 'package:anime_finder/service/settings.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = Settings.instance.list;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: settings.length + 2,
      itemBuilder: (context, index) {
        if (index < settings.length) return settings[index].widget(setState);
        if (index == settings.length) {
          return ListTile(
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
                    onPressed: () {
                      Settings.instance.reset().then((_) {
                        Get.forceAppUpdate();
                        Get.back();
                      });
                    },
                  ),
                  MaterialButton(
                    child: Text(trCancel, style: kLabelSmall),
                    onPressed: () => Get.back(),
                  ),
                ],
              );
            },
          );
        } else {
          return ListTile(
            title: Text(trVersion, style: kTitleSmall),
          );
        }
      },
    );
  }

  //   children: <Widget>[
  //   Settings.locale.widget,
  //   Settings.darkMode.widget,
  //   Visibility(
  //     visible: Settings.filterNoChinese.value == false,
  //     child: Settings.filterNoCHS.widget,
  //   ),
  //   Settings.filterNoChinese.widget,
  //   Settings.textScale.widget,
  //   Settings.layoutOrientation.widget,
  //   Settings.qBittorrentAPIUrl.widget,
  //   Settings.animeProvider.widget,
  //   ListTile(
  //     title: Text(trSettingResetAllSettings,
  //         style: kTitleMedium.copyWith(
  //           color: Colors.redAccent,
  //         )),
  //     onTap: () {
  //       Get.defaultDialog(
  //         backgroundColor: kBackgroundColor,
  //         radius: 16,
  //         titleStyle: kTitleMedium,
  //         title: trWarning,
  //         content: Text(trSettingResetAllSettingsConfirm, style: kBodySmall),
  //         actions: [
  //           MaterialButton(
  //             child: Text(trConfirm, style: kLabelSmall),
  //             onPressed: () {
  //               Settings.reset().then((_) {
  //                 Get.forceAppUpdate();
  //                 Get.back();
  //               });
  //             },
  //           ),
  //           MaterialButton(
  //             child: Text(trCancel, style: kLabelSmall),
  //             onPressed: () => Get.back(),
  //           ),
  //         ],
  //       );
  //     },
  //   ),
  //   ListTile(
  //     title: Text(trVersion, style: kTitleSmall),
  //   )
  // ]);
}
