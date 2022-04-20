import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tankerdriver/datamodels/directiondetail.dart';
import 'package:tankerdriver/datamodels/history.dart';
import 'package:tankerdriver/helpers/requestheper.dart';
import 'package:tankerdriver/gloabal_variables.dart';
import 'package:tankerdriver/widgets/progress_indicator.dart';

import '../dataprovider.dart';
import '../main.dart';

class HelperMethods {
  static Future<DirectionDetail> getDirectionDetail(
      LatLng startPostion, LatLng endPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPostion.latitude},${startPostion.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    if (response == 'failed') {
      return null;
    }

    DirectionDetail directionDetail = DirectionDetail();

    directionDetail.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetail.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];

    directionDetail.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetail.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];

    directionDetail.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];

    return directionDetail;
  }

  static int estimateFares(DirectionDetail detail, int durationValue) {
    // per km 20,
    // per minute 10,
    // base fare 200;

    double basefare = 300;
    double waterfee = 300;
    double distancefare = (detail.distanceValue / 1000) * 30;
    //double timefare = (durationValue / 60) * 20;

    double totalFare = basefare + waterfee + distancefare; //+ timefare;

    return totalFare.truncate();
  }

  static double generateRandomNumber(int max) {
    var randomNumber = Random();
    int randInt = randomNumber.nextInt(max);
    return randInt.toDouble();
  }

  // below 2 methods are For enabling and disabling the Driver Availability on the map for new trips

  static void disableHomTabLocationUpdates() {
    homeTabPositionStrem.pause();
    Geofire.removeLocation(currentFirebasesUser.uid);
  }

  static void enableHomTabLocationUpdates() {
    homeTabPositionStrem.resume();
    Geofire.setLocation(currentFirebasesUser.uid, currentPosition.latitude,
        currentPosition.longitude);
  }

  static void showProgressDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog('Loading...'),
    );
  }

// for EARNINGS TAB

  static void getHistoryInfo(context) {
    DatabaseReference earningRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebasesUser.uid}/earnings');

    earningRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        String earnings = snapshot.value.toString();
        Provider.of<AppData>(context, listen: false).updateEarnings(earnings);
      }
    });

    DatabaseReference historyRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebasesUser.uid}/history');
    historyRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value;
        int tripCount = values.length;

        // update trip count to data provider
        Provider.of<AppData>(context, listen: false).updateTripCount(tripCount);

        List<String> tripHistoryKeys = [];
        values.forEach((key, value) {
          tripHistoryKeys.add(key);
        });

        // update trip keys to data provider
        Provider.of<AppData>(context, listen: false).clearTripKeys();

        Provider.of<AppData>(context, listen: false)
            .updateTripKeys(tripHistoryKeys);

        getHistoryData(context);
      }
    });
  }

  static void getHistoryData(context) {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    String rate = '';
    String review = '';

    for (String key in keys) {
      DatabaseReference historyRef =
          FirebaseDatabase.instance.reference().child('rideRequest/$key');

      Provider.of<AppData>(context, listen: false).clearHistoryItem();
      DatabaseReference ratingRef = FirebaseDatabase.instance
          .reference()
          .child('rideRequest/$key/rateAndReview');
      historyRef.once().then((DataSnapshot snapshot) async {
        if (snapshot.value != null) {
          //var history = History.fromSnapshot(snapshot);
          History history = new History();

          await ratingRef.once().then((DataSnapshot snap) {
            if (snap.value != null) {
              rate = snap.value['rating'].toString();
              review = snap.value['feedback'];
            } else {
              rate = 'Not rated';
              review = '';
            }
          });

          history.pickup = snapshot.value['pickup_address'];
          history.destination = snapshot.value['destination_address'];
          history.fares = snapshot.value['fares'].toString();
          history.createdAt = snapshot.value['created_at'];
          history.status = snapshot.value['status'];
          history.paymentMethod = snapshot.value['payment_method'];
          history.riderName = snapshot.value['rider_name'];
          history.rating = rate;
          history.feedback = review;

          Provider.of<AppData>(context, listen: false)
              .updateTripHistory(history);
          getRatingsAndReviewData(context);
          print(history.destination);
        }
      });
      getRatingsAndReviewData(context);
    }
  }

  // 0311 - 8222091
  static void getRatingsAndReviewData(context) {
    Provider.of<AppData>(context, listen: false).clearRatingHistoryItems();

    if (Provider.of<AppData>(context, listen: false).tripHistory.isNotEmpty) {
      Provider.of<AppData>(context, listen: false).tripHistory.forEach((item) {
        if (item.rating != 'Not rated') {
          Provider.of<AppData>(context, listen: false)
              .updateRatingHistory(item);
        }
      });

      Provider.of<AppData>(context, listen: false).clearRatingCount();
      Provider.of<AppData>(context, listen: false).clearOveralRating();

      countTotalRatingsAndOverallRatings(context);
    }
  }

  static void countTotalRatingsAndOverallRatings(context) {
    if (Provider.of<AppData>(context, listen: false).ratingsHistory.length !=
        0) {
      Provider.of<AppData>(context, listen: false).updateRatingsCount(
          Provider.of<AppData>(context, listen: false).ratingsHistory.length);

      countOverallRatings(context);

      double averageRating = 0.0;

      Provider.of<AppData>(context, listen: false)
          .ratingsHistory
          .forEach((element) {
        //var everyRating = double.parse(element.rating);
        //everyRating = everyRating.toStringAsFixed(2);
        averageRating = averageRating + double.parse(element.rating);
      });

      averageRating = averageRating /
          Provider.of<AppData>(context, listen: false).ratingsHistory.length;

      Provider.of<AppData>(context, listen: false)
          .updateOverallRatings(averageRating.toStringAsFixed(2));
      //.updateOverallRatings(averageRating.toString());
    }
  }

  static void countOverallRatings(context) {}

  static String formatMyDate(String datestring) {
    DateTime thisDate = DateTime.parse(datestring);
    String formattedDate =
        '${DateFormat.MMMd().format(thisDate)}, ${DateFormat.y().format(thisDate)} - ${DateFormat.jm().format(thisDate)}';

    return formattedDate;
  }

  // ye wala notifications ke liye ha

  static void scheduleAlarm(String title, String detail) async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 2));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'Channel for Alarm notification',
      icon: 'codex_logo',
      sound: RawResourceAndroidNotificationSound('zero'),
      largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
      importance: Importance.max,
      playSound: true,
      channelShowBadge: true,
      showWhen: true,
      priority: Priority.high,
      ticker: 'test ticker',
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'zero.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(0, title, detail,
        scheduledNotificationDateTime, platformChannelSpecifics);
  }
}
