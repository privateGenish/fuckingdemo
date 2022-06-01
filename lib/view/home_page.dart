import 'package:demo_architecture/view/components/avatar.dart';
import 'package:demo_architecture/view/components/button.dart';
import 'package:demo_architecture/view/components/swipes.dart';
import 'package:demo_architecture/view/drawer.dart';
import 'package:demo_architecture/view/loading_page.dart';
import 'package:demo_architecture/viewModel/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<ViewModel>(context, listen: false).fetchUserAndGroup("trg-123"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPage();
          }
          return Scaffold(
            drawer: const DrawerMenu(),
            appBar: AppBar(
              actions: [
                TextButton(
                    child: const Text(
                      "Change Group",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/switch')),
                TextButton(
                    onPressed: () => Provider.of<ViewModel>(context, listen: false).throwError(),
                    child: const Text(
                      "throw random error",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
              leading: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Builder(builder: (context) {
                  return Consumer<ViewModel>(builder: (context, model, _) {
                    return GestureDetector(
                      child: UserAvatar(
                        avatar: model.currentUser?.avatar,
                      ),
                      onTap: () => Scaffold.of(context).openDrawer(),
                    );
                  });
                }),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Swipes(),
                const SizedBox(
                  height: 35,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [XButton(), LikeButton()],
                ),
              ],
            ),
          );
        });
  }
}
