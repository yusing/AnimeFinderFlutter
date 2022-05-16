import 'package:anime_finder/service/settings.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      Settings.darkMode.widget,
      Settings.filterNoCHS.widget,
      Settings.textScale.widget,
      Settings.layoutDirection.widget,
      Settings.qBittorrentAPIUrl.widget,
      Settings.animeProvider.widget,
      ListTile(
        title: Text('重置所有設定',
            style: kTitleMedium.copyWith(
              color: Colors.redAccent,
            )),
        onTap: () {
          Get.defaultDialog(
            backgroundColor: kBackgroundColor,
            radius: 16,
            titleStyle: kTitleMedium,
            title: '警告',
            content: Text('確定重置所有設定?', style: kBodySmall),
            actions: [
              MaterialButton(
                child: Text('確定', style: kLabelSmall),
                onPressed: () {
                  Settings.reset().then((_) {
                    Get.forceAppUpdate();
                    Get.back();
                  });
                },
              ),
              MaterialButton(
                child: Text('取消', style: kLabelSmall),
                onPressed: () => Get.back(),
              ),
            ],
          );
        },
      )
    ]);
  }
}
