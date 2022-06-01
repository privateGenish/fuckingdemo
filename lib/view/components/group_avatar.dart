import 'package:demo_architecture/viewModel/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupAvatar extends StatelessWidget {
  const GroupAvatar(this.groupName, {Key? key}) : super(key: key);

  final String? groupName;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Consumer<ViewModel>(builder: (context, model, _) {
          return Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
            height: 150,
            width: 150,
            child: Center(
                child: Text(
              _getInitials(groupName) ?? "Error",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )),
          );
        }),
      );

  String? _getInitials(String? str) {
    if (str == null) return str;
    List<String> words = str.split(' ');
    List<String> initials = [];
    for (var i = 0; i < words.length; i++) {
      if (i == 3) break;
      initials.add(words[i][0].toUpperCase());
    }
    return initials.join();
  }
}
