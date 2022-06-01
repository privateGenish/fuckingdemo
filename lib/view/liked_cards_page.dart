import 'package:demo_architecture/model/model.dart';
import 'package:demo_architecture/view/components/like_cards_tile.dart';
import 'package:demo_architecture/view/loading_page.dart';
import 'package:demo_architecture/viewModel/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LikeCardsPage extends StatelessWidget {
  const LikeCardsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => Provider.of<ViewModel>(context, listen: false).deleteAllCardsAndPop(),
              icon: const Icon(Icons.delete))
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<SwipeCardModel>>(
            future: Provider.of<ViewModel>(context, listen: false)
                .getLikedCards(Provider.of<ViewModel>(context, listen: false).currentGroup?.guid ?? " null"),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const LoadingPage();
              List<SwipeCardModel> cards = snapshot.data ?? [];
              return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  itemBuilder: (context, index) => LikedCardsTile(cards[index]));
            }),
      ));
}
