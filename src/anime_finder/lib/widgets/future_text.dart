import 'package:flutter/material.dart';

class FutureText extends StatelessWidget {
  final Future<String> future;
  final String placeHolder;
  final TextStyle? style;
  const FutureText(
      {super.key, this.style, required this.future, required this.placeHolder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!, style: style, softWrap: true);
        } else {
          return Text(placeHolder, style: style, softWrap: true);
        }
      },
    );
  }
}
