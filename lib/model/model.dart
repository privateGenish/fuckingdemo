import 'dart:convert';
import 'dart:math';

import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:random_avatar/random_avatar.dart';

//Model
class SwipeCardModel {
  SwipeCardModel({this.title, this.country, this.profession});
  String? title;
  String? country;
  String? profession;
  Widget get avatar => randomAvatar(title ?? "null");

  toMap() => {"title": title, "country": country, "profession": profession};
  static fromMap(map) => SwipeCardModel(title: map["title"], country: map["country"], profession: map["profession"]);
}

//Model
class User{
  String name;
  String uid;
  List<Map<String, String>> groups;
  User(this.uid, this.name, {this.groups = const []});
  Widget get avatar => randomAvatar(name);

  Map toMap() => {"name": name, "uid": uid, "groups": groups};

  static fromMap(Map map) {
    List<Map<String, String>> groups = [];
    for (var group in map["groups"]) {
      groups.add({"guid": group["guid"], "name": group["name"]});
    }

    return User(map["uid"], map["name"], groups: groups);
  }
}

//Model
class Group {
  String name;
  String guid;
  List<User>? members;
  Group(this.guid, this.name, this.members);

  Map toMap() => {"name": name, "guid": guid};
}

/// Repository is the class that manages the various methods and business logic of the various resources
/// The ViewModel should address to the repository when a resources is needed, without consideration to the logic and resource.
/// The only consideration is Error handling
class Repository {
  final HTTPService _httpService = HTTPService();
  final LocalService _localService = LocalService();

  Future<User> getUser(String uid) async {
    if (kDebugMode) {
      print("   fetching user $uid");
    }
    User? user = await _localService.getUser(uid);
    if (user != null) return user;

    var rawData = await _httpService.getUser(uid);
    var rawResults = rawData["Item"];

//parsing to User object
    List<Map<String, String>> groups = [];
    for (var group in rawResults['groups']) {
      groups.add({"name": group["name"], "guid": group["guid"]});
    }
    User fetchedUser = User(rawResults["uid"], rawResults["name"], groups: groups);

    _localService.saveUserInfo(fetchedUser);

    return fetchedUser;
  }

  getGroup(String guid) async {
    if (kDebugMode) {
      print("   fetching group $guid");
    }
    var rawData = await _httpService.getGroup(guid);
    var rawResults = rawData["Item"];
    if (kDebugMode) {
      print("     getting ${rawResults["members"].length} group members ");
    }
    List<User> members = [];
    for (var uid in rawResults["members"]) {
      User? user = await getUser(uid);
      members.add(user);
    }
    return Group(rawResults["guid"], rawResults["name"], members);
  }

  getNewCards() async {
    var rawData = await _httpService.getBulk();
    var rawResults = rawData["items"];
    return List.generate(
        rawResults.length,
        (index) => SwipeCardModel(
            title: rawResults[index]["title"],
            country: rawResults[index]["country"],
            profession: rawResults[index]["profession"]));
  }

  Future<void> saveCard(String guid, SwipeCardModel card) async => await _localService.saveCard(guid, card);

  Future<List<SwipeCardModel>> getSavedCards(String guid) async => await _localService.getSavedCards(guid);

  initializeResources() async {
    await LocalService.initialize();
  }
}

class HTTPService {
  String url = "";

  Future<Map> getBulk() async {
    var responseJson = await FakeServer.getItems(4);
    Map response = jsonDecode(responseJson);
/// Adding request type to easily decide between which error is related in the ui
    return apiResponse(response, RequestType.card);
  }

  Future<Map> getUser(String uid) async {
    var responseJson = await FakeServer.getUser(uid);
    Map response = jsonDecode(responseJson);
    return apiResponse(response);
  }

  Future<Map> getGroup(String uid) async {
    var responseJson = await FakeServer.getGroup(uid);
    Map response = jsonDecode(responseJson);
    return apiResponse(response);
  }

  Map apiResponse(response, [RequestType? type]) {
    switch (response["statusCode"].toString()) {
      case '200':
      case '201':
        return response;
      case '400':
      case '404':
        String cause = "Bad Request";
        response["cause"] != null ? cause = response["cause"] : null;
        throw APIError("4xx", cause: cause, requestType: type);
      case '500':
        throw APIError("5xx", cause: "Server Issue", requestType: type);
      default:
        throw Error();
    }
  }
}

class LocalService {
  static clearAll() async => await Hive.deleteFromDisk();

  static initialize() async {
    if (kDebugMode) {
      print("   initializing local database (hive) ...");
    }
    await Hive.initFlutter();
  }

  saveUserInfo(User user) async {
    Box userBox = await Hive.openBox(user.uid);
    await userBox.putAll(user.toMap());
    await userBox.close();
  }

  Future<User?> getUser(String uid) async {
    Box userBox = await Hive.openBox(uid);
    if (userBox.isEmpty) return null;
    User user = User.fromMap(userBox.toMap());
    userBox.close();
    return user;
  }

  Future<void> saveCard(String guid, SwipeCardModel card) async {
    Box groupBox = await Hive.openBox("$guid#CARDS");
    await groupBox.add(card.toMap());
    await groupBox.close();
  }

  Future<List<SwipeCardModel>> getSavedCards(String guid) async {
    Box groupBox = await Hive.openBox("$guid#CARDS");
    List<SwipeCardModel> savedCards = [];
    for (var card in groupBox.values) {
      savedCards.add(SwipeCardModel.fromMap(card));
    }
    return savedCards;
  }
}

/// play with the random error to test the app soundness.
class FakeServer {
  static getItems(int n) async {
    int oddsToMakeAnError = 7; // set to 1 to get only error
    Faker faker = Faker();
    Map<dynamic, dynamic> response = {"items": []};
    await Future.delayed(const Duration(seconds: 2));
    if (Random().nextInt(oddsToMakeAnError) != oddsToMakeAnError - 1) {
      for (var i = 0; i < n; i++) {
        response["items"].add(
            {"title": faker.person.name(), "country": faker.address.countryCode(), "profession": faker.job.title()});
      }
      response["statusCode"] = 200;
    } else {
      oddsToMakeAnError = 4;
      Random().nextInt(oddsToMakeAnError) != oddsToMakeAnError - 1
          ? response["statusCode"] = 400
          : response["statusCode"] = 500;
    }
    return jsonEncode(response);
  }

  static getUser(String uid) async {
    final List<Map> users = [
      User("trg-123", "Yoav Genish", groups: [
        {"guid": "group1", "name": "School friends"},
        {"guid": "group2", "name": "Gym buddies"}
      ]).toMap(),
      User("user1", "Avi").toMap(),
      User("user2", "Moses").toMap(),
      User("user3", "Lea").toMap(),
      User("user4", "Rachel").toMap(),
      User("user5", "George").toMap()
    ];
    int oddsToMakeAnError = 500; // set to 1 to get only error
    Map<dynamic, dynamic> response = {};
    await Future.delayed(const Duration(milliseconds: 200));
    if (Random().nextInt(oddsToMakeAnError) != oddsToMakeAnError - 1) {
      try {
        response["Item"] = users.firstWhere((element) => element["uid"] == uid);
        response["statusCode"] = 200;
      } on StateError {
        response["cause"] = "User doesn't exist";
        response["statusCode"] = 404;
      }
    } else {
      oddsToMakeAnError = 4;
      Random().nextInt(oddsToMakeAnError) != oddsToMakeAnError - 1
          ? response["statusCode"] = 400
          : response["statusCode"] = 500;
    }
    return jsonEncode(response);
  }

  static getGroup(String guid) async {
    List<Map> groups = [
      {
        "name": "School friends",
        "guid": "group1",
        "members": ["user1", "user2", "user3"]
      },
      {
        "name": "Gym buddies",
        "guid": "group2",
        "members": ["user1", "user4", "user5"]
      }
    ];
    int oddsToMakeAnError = 500; // set to 1 to get only error
    Map<dynamic, dynamic> response = {};
    await Future.delayed(const Duration(seconds: 2));
    if (Random().nextInt(oddsToMakeAnError) != oddsToMakeAnError - 1) {
      try {
        response["Item"] = groups.firstWhere((element) => element["guid"] == guid);
        response["statusCode"] = 200;
      } on StateError {
        response["cause"] = "No Group";
        response["statusCode"] = 404;
      }
    } else {
      //odds ratio to get a server error
      oddsToMakeAnError = 4;
      Random().nextInt(oddsToMakeAnError) != oddsToMakeAnError - 1
          ? response["statusCode"] = 400
          : response["statusCode"] = 500;
    }
    return jsonEncode(response);
  }
}

enum RequestType { card }


class APIError implements Exception {
  String statusCode;
  String? cause;
  RequestType? requestType;
  APIError(this.statusCode, {this.cause, this.requestType});
}
