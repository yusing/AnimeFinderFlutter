import 'package:flutter/material.dart';

class AnimatedRoute extends PageRouteBuilder {
  AnimatedRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
}

void routeTo(BuildContext context, WidgetBuilder builder) {
  Navigator.push(context, AnimatedRoute(builder: builder));
}
