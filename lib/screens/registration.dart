import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tankerdriver/gloabal_variables.dart';
import 'package:tankerdriver/screens/vehicleinfor.dart';
import 'package:tankerdriver/widgets/progress_indicator.dart';
import 'package:tankerdriver/widgets/taxi_button.dart';

import '../brand_colors.dart';
import 'login.dart';
import 'mainpage.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

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

  void register() async {
    // code to show custom loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        'Registering You',
      ),
    );

    final FirebaseUser user = (await auth
            .createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
            .catchError((ex) {
      Navigator.pop(context);
      PlatformException pE = ex;
      showSnackBar(pE.message);
    }))
        .user;
    Navigator.pop(context);
    if (user != null) {
      DatabaseReference newuserRef =
          FirebaseDatabase.instance.reference().child('drivers/${user.uid}');

      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };
      newuserRef.set(userMap);

      currentFirebasesUser = user;

      Navigator.of(context).pushNamed(VehicleInfo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage("images/loginthree.jpg"), fit: BoxFit.cover)),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                  ),
                  Image(
                    alignment: Alignment.center,
                    width: 150.0,
                    height: 100.0,
                    image: AssetImage('images/logostwo.png'),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Register as a Driver',
                    style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          style: TextStyle(color: Colors.white),
                          controller: fullNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Enter your name',
                            labelStyle:
                                TextStyle(fontSize: 14.0, color: Colors.white),
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 10.0),
                            filled: true,
                            fillColor: Colors.black26,
                            border: new OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.white)),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Enter your email',
                            labelStyle:
                                TextStyle(fontSize: 14.0, color: Colors.white),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0),
                            filled: true,
                            fillColor: Colors.black26,
                            border: new OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.white)),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Enter your contact number',
                            labelStyle:
                                TextStyle(fontSize: 14.0, color: Colors.white),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0),
                            filled: true,
                            fillColor: Colors.black26,
                            border: new OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.white)),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Enter your password',
                            labelStyle:
                                TextStyle(fontSize: 14.0, color: Colors.white),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0),
                            filled: true,
                            fillColor: Colors.black26,
                            border: new OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.white)),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        TaxiButton(
                            title: 'REGISTER',
                            color: BrandColors.colorGreen,
                            onPressed: () async {
                              var connRes =
                                  await Connectivity().checkConnectivity();

                              if (connRes != ConnectivityResult.mobile &&
                                  connRes != ConnectivityResult.wifi) {
                                showSnackBar(
                                    'Please check your connection and try again');
                                return;
                              }

                              if (fullNameController.text.length <= 3) {
                                showSnackBar('Please provide your full name');
                                return;
                              }
                              if (phoneController.text.length < 10) {
                                showSnackBar(
                                    'Please provide a valid phone number');
                                return;
                              }
                              if (!emailController.text.contains('@')) {
                                showSnackBar('Please provide a valid email');
                                return;
                              }
                              if (passwordController.text.length < 8) {
                                showSnackBar(
                                    'Please provide atleast 8 characters password ');
                                return;
                              }

                              register();
                            }),
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginPage.id, (route) => false);
                    },
                    child: Text(
                      'Already have account, login here',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
