import 'package:demo_architecture/model/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//**
// My philosophy is due to the nature of flutter, by wrapping our entire navigator with Provider
// we only need one View Model to manage and many models we need.
// The main drawback is it could get messy, but i'd rather have a messy view model then a messy view.
// */
class ViewModel with ChangeNotifier {
  final Repository _repository = Repository();

// This method is called once when the app runs
  Future<void> initializeResources() async {
    if (kDebugMode) {
      print("initializing...");
    }
    await Future.delayed(const Duration(seconds: 3)); //artificial delay
    await _repository.initializeResources();
    navigateToHomePage();
  }

//Main Navigator Key
  GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "root navigation key");

//The swiped cards are actually nested navigator and this is the key
  GlobalKey<NavigatorState> cardSwipeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "card swipe key");

  ///Since the `NavigatorState` Api don't expose the setting of the current state
  ///we need to monitor it manually.
  String currentRouteName = "loading";
  CardState? currentCardState;

  Duration cardSwipeDuration = const Duration(milliseconds: 300);

//Send to the next card
//TODO: implement it better.
  _nextCard(String routeName) async {
    //unless is a normal card, do not route ro a route from itself.
    if (routeName == "card" || currentRouteName != routeName) {
      currentRouteName = routeName;
      if (routeName == "loading") cardSwipeNavigatorKey.currentState?.pushReplacementNamed("loading");
      if (routeName == "card") await Future.delayed(cardSwipeDuration); // wait to animation to finish
      if (routeName == "card") pendingCards.removeLast();
      pendingCards.isNotEmpty
          ? cardSwipeNavigatorKey.currentState
              ?.pushReplacementNamed(routeName, arguments: routeName == "card" ? pendingCards.last : null)
          : _nextCard("loading");
      //resetting the card state for the next card
      currentCardState = null;
    }
  }

  _startSwiping() => cardSwipeNavigatorKey.currentState?.pushReplacementNamed("card", arguments: pendingCards.last);

//Like/Unlike Callback
  void onPressLikeOrUnlike(CardState userDecision) async {
    //To prevent double taps, function only is the card is yet to be interacted with.
    if (currentCardState == null) {
      if (pendingCards.isNotEmpty) {
        if (userDecision == CardState.like) {
          await _repository.saveCard(currentGroup?.guid ?? "null", pendingCards.last);
        }
        currentCardState = userDecision;

        /// we need to notify listeners because the Swipe action is maintained by an `AnimatedPosition`
        /// that listen to ViewModel.currentCardState
        notifyListeners();
        await _nextCard("card");
      } else {
        _nextCard("loading");
      }
    }
  }

// get liked cards from the repository
  Future<List<SwipeCardModel>> getLikedCards(String guid) async => _repository.getSavedCards(guid);

// callback for the ErrorPage -> FlatButton "try again"
  void tryAgain() async => await _nextCard("loading");

//* Root Navigator methods

// All error without dedicated view are referred to the error page.
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
      _startSwiping();
    } catch (e) {
      _errorHandler(e);
    }
  }

  fetchCardsWhileSwiping() async {
    try {
      /// change -1 to disable
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

//enum to check whether the card is a like or a dislike
enum CardState {
  like,
  unlike,
}
