import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tankerdriver/screens/historypage.dart';
import 'package:tankerdriver/screens/ratingPage.dart';
import 'package:tankerdriver/widgets/brand_divider.dart';

import '../brand_colors.dart';
import '../dataprovider.dart';

class RatingTab extends StatelessWidget {
  const RatingTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: BrandColors.colorPrimary,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [
                Text(
                  'Overall Ratings',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${Provider.of<AppData>(context).ratings}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontFamily: 'Brand-Bold'),
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 35,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => RatingPage()));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: Row(
              children: [
                Image.asset(
                  'images/logosfour.png',
                  width: 70,
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  'Ratings',
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                    child: Container(
                        child: Text(
                  Provider.of<AppData>(context).ratingCount.toString(),
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 18),
                ))),
              ],
            ),
          ),
        ),
        BrandDivider(),
      ],
    );
  }
}
