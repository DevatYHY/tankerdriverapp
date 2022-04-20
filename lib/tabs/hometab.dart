import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tankerdriver/brand_colors.dart';
import 'package:tankerdriver/datamodels/driver.dart';
import 'package:tankerdriver/gloabal_variables.dart';
import 'package:tankerdriver/helpers/helpermethods.dart';
import 'package:tankerdriver/helpers/push_notification_service.dart';
import 'package:tankerdriver/widgets/availibiltybutton.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:tankerdriver/widgets/confirmsheet.dart';
import 'package:tankerdriver/widgets/notificationdialog.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  DatabaseReference tripRequestRef;

  var geolocator = Geolocator();
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

//  Color availabilityColor = BrandColors.colorOrange;
//  String availabilityTitle = 'GO ONLINE';
//  bool isvailable = false;

  void getCurrentPosition() async {
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);

    mapController.animateCamera(CameraUpdate.newLatLng(pos));
  }

  void getCurrentDriverInfo() async {
    currentFirebasesUser = await FirebaseAuth.instance.currentUser();

    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebasesUser.uid}');

    driverRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentDriverInfo = Driver.fromSnapshot(snapshot);
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();

    HelperMethods.getHistoryInfo(context);
  }

  void getCurrentProfileImage() async {
    FirebaseUser userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth != null) {
      StorageReference profileRef =
          FirebaseStorage.instance.ref().child('profiles/${userAuth.uid}');

      String url = (await profileRef.getDownloadURL()).toString();

      setState(() {
        imageurl = url;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentDriverInfo();
    getCurrentProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // map code
        GoogleMap(
          padding: EdgeInsets.only(top: 200),
          initialCameraPosition: googlePlex,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;

            getCurrentPosition();
          },
        ),

        // top container
        Container(
          height: 135,
          width: double.infinity,
          color: BrandColors.colorPrimary,
        ),

        // top container availibility button code
        Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvailabiltyButton(
                  color: availabilityColor,
                  title: availabilityTitle,
                  onPressed: () {
                    // goOnline();
                    // getGeolocationUpdates();

                    showModalBottomSheet(
                        isDismissible: false,
                        context: context,
                        builder: (BuildContext context) => ConfirmSheet(
                              title: (!isvailable) ? 'GO ONLINE' : 'GO OFFLINE',
                              subTitle: (!isvailable)
                                  ? 'You are going to receive new trips'
                                  : 'You will stop receiving new trip',
                              onpressed: () {
                                if (!isvailable) {
                                  goOnline();
                                  getGeolocationUpdates();
                                  Navigator.pop(context);

                                  setState(() {
                                    availabilityColor = BrandColors.colorGreen;
                                    availabilityTitle = 'GO OFFLINE';
                                    isvailable = true;
                                  });
                                } else {
                                  goOffline();
                                  Navigator.pop(context);

                                  setState(() {
                                    availabilityColor = BrandColors.colorOrange;
                                    availabilityTitle = 'GO ONLINE';
                                    isvailable = false;
                                  });
                                }
                              },
                            ));
                  },
                )
              ],
            )),
      ],
    );
  }

// go online function
  void goOnline() {
    Geofire.initialize('driversAvailable');

    Geofire.setLocation(currentFirebasesUser.uid, currentPosition.latitude,
        currentPosition.longitude);

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebasesUser.uid}/newtrips');
    tripRequestRef.set('waiting');

    tripRequestRef.onValue.listen((event) {});
  }

// Go offline method

  void goOffline() {
    Geofire.removeLocation(currentFirebasesUser.uid);

    //tripRequestRef.onDisconnect();
    //tripRequestRef.remove();
    tripRequestRef = null;
  }
  //live streaming of updated driver location

  void getGeolocationUpdates() {
    homeTabPositionStrem = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      currentPosition = position;

      if (isvailable) {
        Geofire.setLocation(
            currentFirebasesUser.uid, position.latitude, position.longitude);
      }

      LatLng pos = LatLng(position.latitude, position.longitude);

      mapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }
}
