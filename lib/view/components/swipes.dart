import 'package:demo_architecture/viewModel/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:demo_architecture/model/model.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class Swipes extends StatelessWidget {
  const Swipes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.67,
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Navigator(
            reportsRouteUpdateToEngine: true,
            key: model.cardSwipeNavigatorKey,
            initialRoute: "loading",
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case "loading":
                  return PageTransition(child: const LoadingCard(), type: PageTransitionType.fade);
                case "card": 
                return PageTransition(
                    type: PageTransitionType.fade,
                    child: SwipeCard(
                      card: settings.arguments as SwipeCardModel?,
                    ),
                  );
                default:
                  return PageTransition(
                    type: PageTransitionType.fade,
                    child: const ErrorCard()
                  );
              }
            });
      }),
    );
  }
}

class SwipeCard extends StatelessWidget {
  const SwipeCard({Key? key, this.card})
      : super(
          key: key,
        );

  final SwipeCardModel? card;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //It's important to set listen to false, other wise flutter will rebuild the widget
    //When the function is called causing two trigger and a bad state error.
    Provider.of<ViewModel>(context, listen: false).fetchCardsWhileSwiping();
    return Stack(
      children: [
        Consumer<ViewModel>(
          builder: (context, model, child) {
            return AnimatedPositioned(
              curve: Curves.easeIn,
              left: model.cardState != null
                  ? model.cardState != CardState.like
                      ? -1 * (size.width + 100)
                      : (size.width + 100)
                  : 0,
              width: size.width,
              height: size.height * 0.67,
              duration: model.cardSwipeDuration,
              child: child ?? const SizedBox(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                  color: Colors.primaries[(card?.title?.length ?? 10) % Colors.primaries.length],
                  child: Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      card?.avatar ?? const SizedBox(),
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        card?.title ?? "null",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(card?.profession ?? ""),
                          Text(
                            //parse country code to flag emoji using flutter_emoji lib.
                            EmojiParser().emojify(":flag-${(card?.country ?? "il").toLowerCase()}:"),
                            style: const TextStyle(fontSize: 50),
                          )
                        ],
                      )
                    ],
                  ))),
            ),
          ),
        )
      ],
    );
  }
}

// Loading Card
class LoadingCard extends StatelessWidget {
  const LoadingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<ViewModel>(context).fetchCardsOnLoading();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 10,
              spreadRadius: 2,
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [CircularProgressIndicator(), Text("Loading")],
        ),
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 10,
              spreadRadius: 2,
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Error"),
            TextButton(
                onPressed: () => Provider.of<ViewModel>(context, listen: false).tryAgain(),
                child: const Text("Try again"))
          ],
        ),
      ),
    );
  }
}
