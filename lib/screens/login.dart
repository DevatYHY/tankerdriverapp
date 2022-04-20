import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tankerdriver/screens/mainpage.dart';
import 'package:tankerdriver/screens/registration.dart';
import 'package:tankerdriver/widgets/taxi_button.dart';
import '../brand_colors.dart';
import '../widgets/progress_indicator.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  FirebaseAuth auth = FirebaseAuth.instance;

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

  void login() async {
    // code to show custom loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        'Logging You In',
      ),
    );

    // code to signin connection
    final FirebaseUser user = (await auth
            .signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
            .catchError((ex) {
      Navigator.pop(context);
      PlatformException pE = ex;
      showSnackBar(pE.message);
    }))
        .user;

    if (user != null) {
      DatabaseReference newuserRef =
          FirebaseDatabase.instance.reference().child('drivers/${user.uid}');

      newuserRef.once().then((DataSnapshot snapshot) {
        if (snapshot != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainPage.id, (route) => false);
        }
      });
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
                    'Sign In as a Driver',
                    style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                  ),
                  SizedBox(
                    height: 90,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(23.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Enter your email',
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
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
                          height: 10,
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Enter your password',
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
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
                          height: 70,
                        ),
                        TaxiButton(
                          title: 'LOGIN',
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

                            if (!emailController.text.contains('@')) {
                              showSnackBar('Please provide a valid email');
                              return;
                            }
                            if (passwordController.text.length < 8) {
                              showSnackBar('Please provide valid password ');
                              return;
                            }
                            login();
                          },
                        ),
                      ],
                    ),
                  ),
                  /*
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, RegistrationPage.id, (route) => false);
                    },
                    child: Text(
                      'Don\'t have an account, sign up here',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
