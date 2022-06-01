import 'package:demo_architecture/viewModel/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class XButton extends StatelessWidget {
  const XButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<ViewModel>(builder: (context, model, _) {
        return ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.redAccent.shade200, shape: const CircleBorder(), padding: const EdgeInsets.all(30)),
            onPressed: () => model.onPressLikeOrUnlike(CardState.unlike),
            child: const Icon(
              Icons.cancel,
              color: Colors.white,
            ));
      });
}

class LikeButton extends StatelessWidget {
  const LikeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<ViewModel>(builder: (context, model, _) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.purple, shape: const CircleBorder(), padding: const EdgeInsets.all(30)),
          onPressed: () => model.onPressLikeOrUnlike(CardState.like),
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
          ),
        );
      });
}
