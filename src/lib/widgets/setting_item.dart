import 'package:anime_finder/service/settings.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingItem<T> extends StatefulWidget {
  final Setting<T> setting;
  const SettingItem({super.key, required this.setting});

  @override
  State<SettingItem> createState() => _SettingItemState();
}

class _SettingItemState<T> extends State<SettingItem<T>> {
  final _stringSettingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isType<TSetting>() => widget.setting is Setting<TSetting>;
  bool _isDropdown() => widget.setting.values != null;

  @override
  void initState() {
    super.initState();
    if (_isType<String>() && !_isDropdown()) {
      _stringSettingController.text = widget.setting.value as String;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stringSettingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.setting.title, style: kTitleMedium),
      trailing: _isType<bool>()
          ? Switch(
              value: widget.setting.value as bool,
              onChanged: (value) {
                setState(() {
                  widget.setting.value = value as T;
                });
              },
            )
          : _isDropdown()
              ? DropdownButton<T>(
                  alignment: Alignment.center,
                  dropdownColor: kBackgroundColor,
                  style: kTitleMedium,
                  value: widget.setting.value,
                  onChanged: (value) {
                    setState(() {
                      widget.setting.value = value!;
                    });
                  },
                  items: [
                      for (final entry in widget.setting.values!.entries)
                        DropdownMenuItem(
                          alignment: Alignment.center,
                          value: entry.value,
                          child: Text(entry.key),
                        )
                    ])
              : _isType<String>()
                  ? Text(widget.setting.value as String, style: kTitleMedium)
                  : null,
      onTap: !_isDropdown() && _isType<String>()
          ? () {
              Get.defaultDialog(
                contentPadding: const EdgeInsets.all(16),
                radius: 12,
                titleStyle: kTitleMedium,
                title: widget.setting.title,
                content: Form(
                  key: _formKey,
                  child: TextFormField(
                    style: kBodyMedium,
                    controller: _stringSettingController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return "不能為空";
                      }
                      if (widget.setting.validator?.hasMatch(value!) ?? false) {
                        return "格式不正確";
                      }
                      return null;
                    },
                  ),
                ),
                actions: [
                  MaterialButton(
                    child: Text("確定", style: kLabelSmall),
                    onPressed: () {
                      setState(() {
                        widget.setting.value =
                            _stringSettingController.text as T;
                      });
                      Get.back();
                    },
                  ),
                  MaterialButton(
                      child: Text("取消", style: kLabelSmall),
                      onPressed: () => Get.back()),
                ],
              );
            }
          : null,
    );
  }
}
