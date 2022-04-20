import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tankerdriver/brand_colors.dart';
import 'package:tankerdriver/gloabal_variables.dart';
import 'package:tankerdriver/screens/mainpage.dart';
import 'package:tankerdriver/screens/registration.dart';
import 'package:tankerdriver/widgets/taxi_button.dart';

class VehicleInfo extends StatelessWidget {
  static const String id = 'vehicleinfo';

  var vehicleModelcontroller = TextEditingController();
  var vehicleColorcontroller = TextEditingController();
  var vehicleNumbercontroller = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void updateProfile(context) {
    String id = currentFirebasesUser.uid;

    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('drivers/$id/vehicle_details');

    Map map = {
      'car_model': vehicleModelcontroller.text,
      'car_color': vehicleColorcontroller.text,
      'vehicle_number': vehicleNumbercontroller.text
    };

    ref.set(map);

    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage("images/loginthree.jpg"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: scaffoldKey,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Image.asset(
                'images/logostwo.png',
                height: 125,
                width: 125,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                child: Column(
                  children: [
                    Text(
                      'Enter Vehicles data',
                      style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 22),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    TextField(
                      controller: vehicleModelcontroller,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Vehicle model',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white)),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: vehicleColorcontroller,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Vehicle color',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white)),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: vehicleNumbercontroller,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Vehicle number',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white)),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                    ),
                    TaxiButton(
                      title: 'Proceed',
                      color: BrandColors.colorGreen,
                      onPressed: () {
                        if (vehicleModelcontroller.text.length < 3) {
                          showSnackBar('Pleae provide a valid model number');
                          return;
                        }
                        if (vehicleColorcontroller.text.length < 3) {
                          showSnackBar('Pleae provide a valid color');
                          return;
                        }
                        if (vehicleNumbercontroller.text.length < 3) {
                          showSnackBar('Pleae provide a valid vehicle number');
                          return;
                        }

                        updateProfile(context);
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
