import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tankerdriver/brand_colors.dart';
import 'package:tankerdriver/datamodels/driver.dart';

//import 'datamodels/user.dart';

String mapKey = 'AIzaSyDpDpWKg5LdS3ylXRMM2gqx18_ZhpXYa9Q';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

FirebaseUser currentFirebasesUser;

//User currentUserInfo;

StreamSubscription<Position> homeTabPositionStrem;
StreamSubscription<Position> ridePositionStrem;

final assetsAudioPlayer = AssetsAudioPlayer();

Position currentPosition;

DatabaseReference rideRef;

Driver currentDriverInfo;

// for GoOnline Offline Top nav Bar
Color availabilityColor = BrandColors.colorOrange;
String availabilityTitle = 'GO ONLINE';
bool isvailable = false;

String imageurl;
