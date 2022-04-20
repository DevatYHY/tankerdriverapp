import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tankerdriver/brand_colors.dart';
import 'package:tankerdriver/datamodels/tripdetails.dart';
import 'package:tankerdriver/helpers/helpermethods.dart';
import 'package:tankerdriver/helpers/mapkithelper.dart';
import 'package:tankerdriver/widgets/brand_divider.dart';
import 'package:tankerdriver/widgets/collect_payment_dialog.dart';
import 'package:tankerdriver/widgets/progress_indicator.dart';
import 'package:tankerdriver/widgets/taxi_button.dart';

import 'package:url_launcher/url_launcher.dart';

import '../gloabal_variables.dart';
import 'dart:async';
import 'dart:io';

class NewTripPage extends StatefulWidget {
  final TripDetails tripDetail;

  NewTripPage({this.tripDetail});

  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  GoogleMapController rideMapController;
  Completer<GoogleMapController> _controller = Completer();

  double mapBottomPaddingButton = 0;

  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  Set<Circle> _circles = Set<Circle>();

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  var geoLocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.bestForNavigation);

  BitmapDescriptor movingMarkerIcon;

  Position myPosition;

  String status = 'accepted';

  String durationString = '';

  bool isRequestingDirection = false;

  StreamSubscription<Event> rideSubscription;

  String buttonTitle = 'START TRIP';
  Color buttonColor = BrandColors.colorGreen;

  Timer timer;
  int durationCounter = 0;

  var driverStartingLocationLatLng;

  void createMarker() {
    if (movingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              (Platform.isAndroid)
                  ? 'images/delivery_tanker_onmap.png'
                  : 'images/car_ios.png')
          .then((icon) {
        movingMarkerIcon = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    accepTrip();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPaddingButton),
            initialCameraPosition: googlePlex,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            markers: _markers,
            circles: _circles,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              rideMapController = controller;

              setState(() {
                mapBottomPaddingButton = (Platform.isIOS) ? 255 : 260;
              });

              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);

              driverStartingLocationLatLng = currentLatLng;

              var destinationLatLng = widget.tripDetail.destination;

              await getDirection(currentLatLng, destinationLatLng);

              getLoctionUpdates();
            },
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Container(
                  height: Platform.isIOS ? 280 : 255,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 15.0,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            durationString,
                            style: TextStyle(
                                color: BrandColors.colorAccentPurple,
                                fontFamily: 'Brand-Bold',
                                fontSize: 13),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.tripDetail.riderName,
                                style: TextStyle(
                                    fontFamily: 'Brand-Bold', fontSize: 22),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                    onTap: () {
                                      customLaunch(
                                          'tel:${widget.tripDetail.riderPhone}');
                                    },
                                    child: Icon(Icons.call)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'images/pickicon.png',
                                height: 16,
                                width: 16,
                              ),
                              SizedBox(
                                width: 18,
                              ),
                              Expanded(
                                child: Container(
                                  child: Text(
                                    widget.tripDetail.pickupAddress,
                                    style: TextStyle(fontSize: 18),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 18,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'images/desticon.png',
                                height: 16,
                                width: 16,
                              ),
                              SizedBox(
                                width: 18,
                              ),
                              Expanded(
                                child: Container(
                                  child: Text(
                                    widget.tripDetail.destinationAddress,
                                    style: TextStyle(fontSize: 18),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          TaxiButton(
                            title: buttonTitle,
                            color: buttonColor,
                            onPressed: () async {
                              if (status == 'accepted') {
                                status = 'ontrip';
                                rideRef.child('status').set('ontrip');

                                setState(() {
                                  buttonTitle = 'END TRIP';
                                  buttonColor = Colors.red[900];
                                });
                                startTimer();
                              } else if (status == 'ontrip') {
                                checkIfCancelledOrEnded();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

// drawing directions and polylines on map after accepting the trip

  Future<void> getDirection(
      LatLng pickupLatLng, LatLng destinationLatLng) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog('Loading...'),
    );

    var thisDetail =
        await HelperMethods.getDirectionDetail(pickupLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetail.encodedPoints);

    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 273),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polylines.add(polyline);
    });

    // make polyline to fit into map

    LatLngBounds bounds;

    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
          northeast:
              LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }

    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickupLatLng,
      fillColor: BrandColors.colorGreen,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );
    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

//.............accepting trip

  void accepTrip() {
    String rideId = widget.tripDetail.rideId;
    rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/$rideId');

    rideRef.child('status').set('accepted');

    rideRef.child('driver_id').set(currentDriverInfo.id);
    rideRef.child('driver_name').set(currentDriverInfo.fullname);
    rideRef.child('driver_phone').set(currentDriverInfo.phone);
    rideRef
        .child('car_details')
        .set('${currentDriverInfo.carColor} - ${currentDriverInfo.carModel}');

    Map locationMap = {
      'latitude': currentPosition.latitude.toString(),
      'longitude': currentPosition.longitude.toString(),
    };

    rideRef.child('driver_location').set(locationMap);

    rideSubscription = rideRef.onValue.listen((event) {
      if (event.snapshot.value == null) {
        //Navigator.pop(context);
        return;
      }
      if (event.snapshot.value['status'] == 'cancelled') {
        //timer.cancel();
        ridePositionStrem.cancel();
        rideRef.onDisconnect();
        rideRef.remove();
        rideRef = null;

        HelperMethods.scheduleAlarm(
            'Tanker Soul', 'Your customer have cancelled the trip');
        Navigator.pop(context);
        HelperMethods.enableHomTabLocationUpdates();
      }
    });

    DatabaseReference historyRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebasesUser.uid}/history/$rideId');

    historyRef.set(true);
  }

// Updating trip detailes in real time

  void updateTripDetails() async {
    if (!isRequestingDirection) {
      isRequestingDirection = true;

      if (myPosition == null) {
        return;
      }

      var positionLatLng = LatLng(myPosition.latitude, myPosition.longitude);

      LatLng destinationLatLng;

      if (status == 'accepted' || status == 'ontrip') {
        destinationLatLng = widget.tripDetail.destination;
      }
      // else {
      //  destinationLatLng = widget.tripDetail.destination;
      // }

      var directionDetil = await HelperMethods.getDirectionDetail(
          positionLatLng, destinationLatLng);

      if (directionDetil != null) {
        setState(() {
          durationString = directionDetil.durationText;
        });
      }
      isRequestingDirection = false;
    }
  }

  // for drivers location updates on map

  void getLoctionUpdates() {
    LatLng oldPosition = LatLng(0, 0);

    ridePositionStrem = geoLocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      myPosition = position;
      currentPosition = position;

      LatLng pos = LatLng(position.latitude, position.longitude);

      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude,
          oldPosition.longitude, pos.latitude, pos.longitude);

      Marker movingMarker = Marker(
        markerId: MarkerId('moving'),
        position: pos,
        icon: movingMarkerIcon,
        rotation: rotation,
        infoWindow: InfoWindow(title: 'Current Location'),
      );

      setState(() {
        CameraPosition cP = new CameraPosition(target: pos, zoom: 17);
        rideMapController.animateCamera(CameraUpdate.newCameraPosition(cP));

        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMarker);
      });

      oldPosition = pos;
      updateTripDetails();

      Map locationMap = {
        'latitude': myPosition.latitude.toString(),
        'longitude': myPosition.longitude.toString(),
      };

      rideRef.child('driver_location').set(locationMap);
    });
  }

// Timer method for getting the time duration of the trip

  void startTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter++;
    });
  }

//////////// Cancel trip by end button before reching to the desination point ///////////////

  void checkIfCancelledOrEnded() async {
    var directionDetails = await HelperMethods.getDirectionDetail(
        driverStartingLocationLatLng, widget.tripDetail.destination);

    if (directionDetails.distanceValue <= 0) {
      endTrip();
    } else {
      timer.cancel();
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ShowcancellationDialog(),
      );
      // HelperMethods.showProgressDialog(context);
      HelperMethods.scheduleAlarm('Tanker Soul',
          'You have ended the trip before reaching at destination point');

// yaha rideStream me masla lag raha ha
      ridePositionStrem.cancel();
      Navigator.pop(context);
    }
  }

// Faires according to minutes spend on the trip... after Ending the trip...

  void endTrip() async {
    timer.cancel();

    HelperMethods.showProgressDialog(context);

    //var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);

    var directionDetails = await HelperMethods.getDirectionDetail(
        driverStartingLocationLatLng, widget.tripDetail.destination);

    //(widget.tripDetail.pickup, currentLatLng);

    Navigator.pop(context);

    int fares = HelperMethods.estimateFares(directionDetails, durationCounter);

    rideRef.child('fares').set(fares.toString());

    rideRef.child('status').set('ended');

    HelperMethods.scheduleAlarm(
        'Tanker Soul', 'Your order trip has been ended successfully');

// yaha rideStream me masla lag raha ha
    ridePositionStrem.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CollectPaymentDialog(
        paymentMethod: widget.tripDetail.paymentMethod,
        fares: fares,
      ),
    );
    topUpEarning(fares);
  }

  // saving total earning after ending the trip

  void topUpEarning(int fares) {
    DatabaseReference earningRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebasesUser.uid}/earnings');

    earningRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        double oldEarnings = double.parse(snapshot.value.toString());

        double adjustedEarings = (fares.toDouble() * 0.85) + oldEarnings;

        earningRef.set(adjustedEarings.toStringAsFixed(2));
      } else {
        double adjustedEarings = (fares.toDouble() * 0.85);

        earningRef.set(adjustedEarings.toStringAsFixed(2));
      }
    });
  }

// url launcher for call and msgs

  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print('Can not Launch the Command right now');
    }
  }
}

class ShowcancellationDialog extends StatefulWidget {
  @override
  _ShowcancellationDialogState createState() => _ShowcancellationDialogState();
}

class _ShowcancellationDialogState extends State<ShowcancellationDialog> {
  String _dropDownValue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            Text('Reason of cancelling trip'),
            SizedBox(
              height: 20,
            ),
            BrandDivider(),
            SizedBox(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.all(15),
              height: 55,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(5))),
              child: DropdownButton(
                hint: _dropDownValue == null
                    ? Text('Reasons',
                        style: TextStyle(fontSize: 20, color: Colors.black))
                    : Text(
                        _dropDownValue,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                underline: Text(''),
                isExpanded: true,
                iconSize: 30.0,
                style: TextStyle(color: Colors.black),
                items: [
                  'Are you stuck in traffic for long time?',
                  'Are you cancelling this trip in an emergency?',
                  'Is your vehicle broke down?',
                  'Others',
                ].map(
                  (val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  },
                ).toList(),
                onChanged: (val) {
                  setState(
                    () {
                      _dropDownValue = val;
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: 230,
              child: TaxiButton(
                title: 'CONFIRM',
                color: BrandColors.colorGreen,
                onPressed: () async {
                  await rideRef.child('status').set('cancelled');
                  // Navigator.pop(context);
                  // Navigator.pop(context);

                  HelperMethods.enableHomTabLocationUpdates();
                  //Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
