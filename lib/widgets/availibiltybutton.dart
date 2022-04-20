import 'package:flutter/material.dart';

class AvailabiltyButton extends StatelessWidget {
  final String title;
  final Color color;
  final Function onPressed;
  AvailabiltyButton({this.title, this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      child: Container(
        height: 50,
        width: 200,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(25),
      ),
      color: color,
      textColor: Colors.white,
    );
  }
}
