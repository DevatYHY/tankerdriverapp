import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tankerdriver/brand_colors.dart';
import 'package:tankerdriver/datamodels/tripdetails.dart';
import 'package:tankerdriver/gloabal_variables.dart';
import 'package:tankerdriver/helpers/helpermethods.dart';
import 'package:tankerdriver/screens/newtrippage.dart';
import 'package:tankerdriver/widgets/brand_divider.dart';
import 'package:tankerdriver/widgets/progress_indicator.dart';
import 'package:tankerdriver/widgets/taxi_button.dart';
import 'package:tankerdriver/widgets/taxioutlinebutton.dart';
import 'package:toast/toast.dart';

class NotificationDialog extends StatelessWidget {
  final TripDetails tripDetail;

  NotificationDialog({this.tripDetail});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset(
              'images/taxi.png',
              width: 100,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'NEW TRIP REQUEST',
              style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'images/pickicon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                          child:
                              Container(child: Text(tripDetail.pickupAddress))),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'images/desticon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                          child: Container(
                              child: Text(tripDetail.destinationAddress))),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            BrandDivider(),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: TaxiOutlineButton(
                      title: 'DECLINE',
                      color: BrandColors.colorPrimary,
                      onPressed: () async {
                        assetsAudioPlayer.stop();

                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Container(
                      child: TaxiButton(
                        title: 'ACCEPT',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          checkAvailability(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkAvailability(context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog('Accepting Trip'),
    );

    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebasesUser.uid}/newtrips');
    ref.once().then((DataSnapshot snapshot) {
      Navigator.pop(context);
      Navigator.pop(context);

      String thisRideId = "";

      if (snapshot.value != null) {
        thisRideId = snapshot.value.toString();
        //print(thisRideId);

      } else {
        print('Ride not found');
      }

      if (thisRideId == tripDetail.rideId) {
        ref.set('accepted');
        HelperMethods.disableHomTabLocationUpdates();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NewTripPage(
                    tripDetail: tripDetail,
                  )),
        );
      } else if (thisRideId == 'cancelled') {
        Toast.show("Ride has been cancelled", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else if (thisRideId == 'timout') {
        Toast.show("Ride has timed out", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        Toast.show("Ride not found", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        print('FARAK YAHA HA');
        print(tripDetail.rideId);
        print(thisRideId);
      }
    });
  }
}
