import 'package:anime_finder/service/settings.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/callback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingItem<T> extends StatelessWidget {
  final Setting<T> setting;
  final SetStateCallback setState;

  final _stringSettingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get _isSwitch => setting is Setting<bool>;
  bool get _isString => setting is Setting<String>;
  bool get _isDropdown => setting.values != null;
  bool get _isPopup => _isString && !_isDropdown;

  SettingItem({super.key, required this.setting, required this.setState}) {
    if (_isPopup) {
      _stringSettingController.text = setting.value as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(setting.titleDelegate(), style: kTitleMedium),
        trailing: _isSwitch
            ? Switch(
                value: setting.value as bool,
                onChanged: (value) =>
                    setState(() => setting.value = value as T),
              )
            : _isDropdown
                ? DropdownButton<T>(
                    alignment: Alignment.center,
                    dropdownColor: kBackgroundColor,
                    style: kTitleMedium,
                    value: setting.value,
                    onChanged: (value) =>
                        setState(() => setting.value = value as T),
                    items: [
                        for (final entry in setting.values!.entries)
                          DropdownMenuItem(
                            alignment: Alignment.center,
                            value: entry.value,
                            child: Text(entry.key()),
                          )
                      ])
                : !_isString
                    ? null
                    : Text(setting.value as String, style: kTitleMedium),
        onTap: !_isPopup
            ? null
            : () {
                Get.defaultDialog(
                  contentPadding: const EdgeInsets.all(24),
                  radius: 12,
                  titleStyle: kTitleMedium,
                  title: setting.titleDelegate(),
                  backgroundColor: kBackgroundColor,
                  content: Form(
                    key: _formKey,
                    child: TextFormField(
                      style: kBodyMedium,
                      controller: _stringSettingController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return trCannotBeEmpty;
                        }
                        if (setting.validator?.hasMatch(value!) ?? false) {
                          return trInvalidFormat;
                        }
                        return null;
                      },
                    ),
                  ),
                  actions: [
                    MaterialButton(
                      child: Text(trConfirm, style: kLabelSmall),
                      onPressed: () {
                        setState(() =>
                            setting.value = _stringSettingController.text as T);
                        Get.back();
                      },
                    ),
                    MaterialButton(
                        child: Text(trCancel, style: kLabelSmall),
                        onPressed: () => Get.back()),
                  ],
                );
              });
  }
}
