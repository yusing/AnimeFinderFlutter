import 'package:flutter/material.dart';

class AFAnimatedList extends AnimatedList {
  AFAnimatedList(
      {required GlobalKey<AnimatedListState> key,
      required super.initialItemCount,
      required this.builder,
      super.controller})
      : super(
            key: key,
            itemBuilder: (context, index, animation) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  curve: Curves.easeInOut,
                  parent: animation,
                ),
                child: builder(context, index),
              );
            });

  final IndexedWidgetBuilder builder;

  static void removeItem(
      GlobalKey<AnimatedListState> key, int index, VoidCallback remover) {
    try {
      key.currentState!.removeItem(index, (context, animation) {
        final item =
            (key.currentWidget as AFAnimatedList).builder(context, index);
        remover();
        return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: item);
      });
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
    }
  }
}
