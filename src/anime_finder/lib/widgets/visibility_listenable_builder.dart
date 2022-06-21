import 'package:flutter/material.dart';

class VisibilityListenableBuilder extends ValueListenableBuilder<bool> {
  VisibilityListenableBuilder(
      {super.key, required super.valueListenable, required Widget Function() b})
      : super(
          builder: (_, __, ___) =>
              valueListenable.value ? b() : const SizedBox(),
        );
}
