import 'package:demo_architecture/model/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CardState {
  like,
  unlike,
}

class ViewModel with ChangeNotifier {
  final Repository _repository = Repository();
  Future<void> initializeResources() async {
    if (kDebugMode) {
      print("initializing...");
    }
    await Future.delayed(const Duration(seconds: 3));
    await _repository.initializeResources();
    navigateToHomePage();
  }

  //Main Navigator Key
  GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "root navigation key");

  //Card state and controllers
  GlobalKey<NavigatorState> cardSwipeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "card swipe key");
  String currentRouteName = "loading";
  CardState? cardState;
  Duration cardSwipeDuration = const Duration(milliseconds: 300);

  _nextCard(String routeName) async {
    if (routeName == "card" || currentRouteName != routeName) {
      currentRouteName = routeName;
      if (routeName == "card") await Future.delayed(cardSwipeDuration); // wait to animation to finish
      if (routeName == "card") pendingCards.removeLast();

      pendingCards.isNotEmpty
          ? cardSwipeNavigatorKey.currentState
              ?.pushReplacementNamed(routeName, arguments: routeName == "card" ? pendingCards.last : null)
          : cardSwipeNavigatorKey.currentState?.pushReplacementNamed("loading");
      cardState = null;
    }
  }

  _startSwiping(SwipeCardModel card) {
    currentRouteName = "card";
    cardSwipeNavigatorKey.currentState?.pushReplacementNamed("card", arguments: card);
  }

  void onPressLikeOrUnlike(CardState currentCardState) async {
    if (cardState == null) {
      if (pendingCards.isNotEmpty) {
        if (currentCardState == CardState.like) {
          await _repository.saveCard(currentGroup?.guid ?? "null", pendingCards.last);
        }
        cardState = currentCardState;
        notifyListeners();
        await _nextCard("card");
      } else {
        _nextCard("loading");
      }
    }
  }

  Future<List<SwipeCardModel>> getLikedCards(String guid) async => _repository.getSavedCards(guid);

  void tryAgain() async => await _nextCard("loading");

  //root Navigator methods
  _navigateToErrorPage(error) => rootNavigatorKey.currentState?.pushReplacementNamed("/error", arguments: error);
  navigateToHomePage() {
    while (rootNavigatorKey.currentState!.canPop()) {
      rootNavigatorKey.currentState!.pop();
    }
    return rootNavigatorKey.currentState?.pushReplacementNamed("/home");
  }

  navigateToLikedCardsPage() => rootNavigatorKey.currentState!.pushNamed("/likedCards");
  pop() => rootNavigatorKey.currentState!.canPop() ? rootNavigatorKey.currentState!.pop() : null;

  //Fetching and managing information
  List<SwipeCardModel> pendingCards = [];

  Future<void> _fetchCard() async {
    List<SwipeCardModel> fetchedCard = await _repository.getNewCards();
    return pendingCards.addAll(fetchedCard);
  }

  fetchCardsOnLoading() async {
    try {
      await _fetchCard();
      _startSwiping(pendingCards.last);
    } catch (e) {
      _errorHandler(e);
    }
  }

  fetchCardsWhileSwiping() async {
    try {
      int kMinNumberToFetch = -1;
      if (pendingCards.length == kMinNumberToFetch) await _fetchCard();
    } catch (e) {
      //do nothing!
    }
  }

  deleteAllCardsAndPop() async => await LocalService.clearAll().then((v) => pop());

  /// User and group management and methods
  User? currentUser;
  Group? currentGroup;
  int index = 0;
  Future<void> fetchUserAndGroup(String uid) async {
    try {
      currentUser ??= await _repository.getUser(uid);
      currentGroup = await _repository.getGroup(currentUser?.groups[index]["guid"] ?? "null");
      notifyListeners();
    } catch (e) {
      _errorHandler(e);
    }
  }

  changeCurrentGroup(String guid) {
    if (kDebugMode) {
      print("changing group and rerouting the main page ('/')");
    }
    try {
      if (currentGroup?.guid == guid) return pop();
      index = currentUser?.groups.indexWhere((element) => element["guid"] == guid) ?? -1;
      navigateToHomePage();
    } catch (e) {
      _errorHandler(e);
    }
  }

  _errorHandler(dynamic error) {
    if (kDebugMode) {
      print("Error has accrued");
      print(error is APIError ? error.cause : "${error.stackTrace} $error");
    }
    if (error is APIError && error.requestType == RequestType.card) return _nextCard("error");
    _navigateToErrorPage(error);
  }

  void reportIssue() => {};

  //throws unknown error
  throwError() {
    try {
      throw Error();
    } catch (e) {
      _errorHandler(e);
    }
  }
}
