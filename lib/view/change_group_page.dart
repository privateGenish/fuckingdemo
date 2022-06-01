import 'package:demo_architecture/view/components/group_avatar.dart';
import 'package:demo_architecture/viewModel/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeGroupPage extends StatelessWidget {
  const ChangeGroupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<ViewModel>(builder: (context, model, _) {
        return Center(
          child: SizedBox(
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: model.currentUser?.groups.length ?? 2,
                itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                          onTap: () => model.changeCurrentGroup(model.currentUser?.groups[index]["guid"] ?? "null"),
                          leading: GroupAvatar(model.currentUser?.groups[index]["name"]),
                          title: Text(model.currentUser?.groups[index]["name"] ?? "error")),
                    )),
          ),
        );
      }),
    );
  }
}
