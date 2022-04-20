import 'package:flutter/material.dart';
import 'package:tankerdriver/datamodels/history.dart';

class AppData extends ChangeNotifier {
  String earnings = '0';
  int tripCount = 0;

  String ratings = '0';
  int ratingCount = 0;

  List<String> tripHistoryKeys = [];
  List<History> tripHistory = [];

  List<History> ratingsHistory = [];

  void updateEarnings(String newEarnings) {
    earnings = newEarnings;
    notifyListeners();
  }

  void updateTripCount(int newTripCount) {
    tripCount = newTripCount;
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys) {
    // ye 1 line add ki ha masla kr skti ha baad me okay...
    // tripHistoryKeys.clear();

    tripHistoryKeys = newKeys;
    notifyListeners();
  }

  void updateTripHistory(History historyItem) {
    // ye 1 line add ki ha masla kr skti ha baad me okay...
    // tripHistory.clear();

    tripHistory.add(historyItem);
    notifyListeners();
  }

// for removing when logout
  void clearTripKeys() {
    tripHistoryKeys.clear();
    notifyListeners();
  }

  void clearHistoryItem() {
    tripHistory.clear();
    notifyListeners();
  }

  void updateRatingHistory(History ratingItem) {
    // ye 1 line add ki ha masla kr skti ha baad me okay...
    // tripHistory.clear();

    ratingsHistory.add(ratingItem);
    notifyListeners();
  }

// for removing when logout
  void clearRatingHistoryItems() {
    ratingsHistory.clear();
    notifyListeners();
  }

  void updateOverallRatings(String newOverallrating) {
    ratings = newOverallrating;
    notifyListeners();
  }

  void updateRatingsCount(int newCount) {
    ratingCount = newCount;
    notifyListeners();
  }

  void clearOveralRating() {
    ratings = '0';
    notifyListeners();
  }

  void clearRatingCount() {
    ratingCount = 0;
    notifyListeners();
  }
}
