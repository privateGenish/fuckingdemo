import 'package:demo_architecture/model/model.dart';
import 'package:flutter/material.dart';

class LikedCardsTile extends StatelessWidget {
  const LikedCardsTile(this.card, {Key? key}) : super(key: key);
  final SwipeCardModel card;
  @override
  Widget build(BuildContext context) => ListTile(
        leading: card.avatar,
        title: Text(card.title ?? "Error"),
      );
}
