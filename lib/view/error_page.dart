import 'package:demo_architecture/model/model.dart';
import 'package:demo_architecture/viewModel/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
              Text(
                "Error",
                style: Theme.of(context).textTheme.displayMedium,
              )
            ] +
            _children(context),
      )),
    );
  }

  _children(BuildContext context) {
    dynamic error = ModalRoute.of(context)?.settings.arguments;
    List<Widget> widgets = [];
    if (error is APIError) {
      widgets = [Text(error.cause ?? "")];
      switch (error.statusCode) {
        case "5xx":
          widgets.add(TextButton(
              onPressed: () => Provider.of<ViewModel>(context, listen: false).navigateToHomePage(),
              child: const Text("Try Again")));
          return widgets;
        case "4xx":
          widgets.addAll(<Widget>[
            TextButton(
                onPressed: () => Provider.of<ViewModel>(context, listen: false).navigateToHomePage(),
                child: const Text("Try Again")),
            TextButton(
                onPressed: () => Provider.of<ViewModel>(context, listen: false).reportIssue(),
                child: const Text("Report Issue"))
          ]);
          return widgets;
        default:
      }
    }
    widgets.addAll(<Widget>[
      const Text(
        "We've encountered an unknown issue that caused a crash. please report the issue for us to handle it.",
        textAlign: TextAlign.center,
      ),
      TextButton(
          onPressed: () => Provider.of<ViewModel>(context, listen: false).reportIssue(),
          child: const Text("Report Issue"))
    ]);
    return widgets;
  }
}
