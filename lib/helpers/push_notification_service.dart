import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tankerdriver/datamodels/tripdetails.dart';
import 'package:tankerdriver/gloabal_variables.dart';
import 'package:tankerdriver/widgets/notificationdialog.dart';
import 'dart:io';

import 'package:tankerdriver/widgets/progress_indicator.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging();

  Future initialize(context) async {
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message), context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message), context);
      },
      onResume: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message), context);
      },
    );
  }

  Future<String> getToken() async {
    String token = await fcm.getToken();
    print('Token: $token');

    currentFirebasesUser = await FirebaseAuth.instance.currentUser();

    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebasesUser.uid}/token');
    tokenRef.set(token);

    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');
  }

  String getRideId(Map<String, dynamic> message) {
    String rideId = '';

    if (Platform.isAndroid) {
      rideId = message['data']['ride_id'];
      print('Ride id : $rideId');
    } else {
      rideId = message['data']['ride_id'];
    }
    return rideId;
  }

  void fetchRideInfo(String rideId, context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        'Loading...',
      ),
    );

    DatabaseReference ref =
        FirebaseDatabase.instance.reference().child('rideRequest/$rideId');
    ref.once().then((DataSnapshot snapshot) {
      Navigator.pop(context);

      if (snapshot.value != null) {
        assetsAudioPlayer.open(
          Audio('sounds/alert.mp3'),
        );
        assetsAudioPlayer.play();

        double pickupLat =
            double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng =
            double.parse(snapshot.value['location']['longitude'].toString());
        String pickupAddress = snapshot.value['pickup_address'].toString();

        double destinationLat =
            double.parse(snapshot.value['destination']['latitude'].toString());
        double destinationLng =
            double.parse(snapshot.value['destination']['longitude'].toString());
        String destinationAddress =
            snapshot.value['destination_address'].toString();
        String paymentMethod = snapshot.value['payment_method'];
        String riderName = snapshot.value['rider_name'];
        String riderPhone = snapshot.value['rider_phone'];

        print(destinationAddress);

        TripDetails tripDetail = TripDetails();

        tripDetail.rideId = rideId;
        tripDetail.pickupAddress = pickupAddress;
        tripDetail.destinationAddress = destinationAddress;
        tripDetail.pickup = LatLng(pickupLat, pickupLng);
        tripDetail.destination = LatLng(destinationLat, destinationLng);
        tripDetail.paymentMethod = paymentMethod;
        tripDetail.riderName = riderName;
        tripDetail.riderPhone = riderPhone;

        print(tripDetail.destinationAddress);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(
            tripDetail: tripDetail,
          ),
        );
      }
    });
  }
}
