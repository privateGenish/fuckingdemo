import 'package:demo_architecture/view/change_group_page.dart';
import 'package:demo_architecture/view/error_page.dart';
import 'package:demo_architecture/view/home_page.dart';
import 'package:demo_architecture/view/liked_cards_page.dart';
import 'package:demo_architecture/view/splash_page.dart';
import 'package:demo_architecture/viewModel/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ViewModel())],
        child: Builder(builder: (context) {
          ViewModel model = Provider.of<ViewModel>(context);
          return MaterialApp(
            navigatorKey: model.rootNavigatorKey,
            theme: ThemeData(
              primarySwatch: Colors.primaries[(model.currentGroup?.name.length ?? 5) % Colors.primaries.length],
            ),
            initialRoute: "/",
            onGenerateRoute: (setting) {
              switch (setting.name) {
                case "/":
                  model.initializeResources();
                  return MaterialPageRoute(builder: (context) => const SplashPage());
                case "/home":
                  return MaterialPageRoute(builder: (context) => const HomePage());
                case "/switch":
                  return MaterialPageRoute(builder: (context) => const ChangeGroupPage());
                case "/likedCards":
                  return MaterialPageRoute(builder: (context) => const LikeCardsPage());
                case "/error":
                default:
                  return PageTransition(type: PageTransitionType.fade, child: const ErrorPage());
              }
            },
          );
        }),
      );
}
