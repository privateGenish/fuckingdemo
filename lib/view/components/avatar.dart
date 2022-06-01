import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({Key? key, this.radius, this.avatar}) : super(key: key);

  final Widget? avatar;
  final double? radius;

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: radius,
        child: avatar,
      );
}
