import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        child: Center(
            child: Text(
          "Demo App",
          style: Theme.of(context).textTheme.bodyMedium,
        )),
      );
}
