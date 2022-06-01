import 'package:demo_architecture/view/components/avatar.dart';
import 'package:demo_architecture/viewModel/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Consumer<ViewModel>(builder: (context, model, _) {
            return Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                UserAvatar(
                  avatar: model.currentUser?.avatar,
                  radius: 70,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  model.currentUser?.name ?? "error",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                TextButton.icon(
                  onPressed: () => model.navigateToLikedCardsPage(),
                  label: Text(
                    "Favorite",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  icon: const Icon(Icons.favorite),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    model.currentGroup?.name ?? "Error",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: model.currentGroup?.members?.length ?? 0,
                    itemBuilder: ((context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              UserAvatar(
                                radius: 35,
                                avatar: model.currentGroup?.members?[index].avatar,
                              ),
                              Text(model.currentGroup?.members?[index].name ?? "error")
                            ],
                          ),
                        )))
              ],
            );
          }),
        ),
      ),
    );
  }
}
