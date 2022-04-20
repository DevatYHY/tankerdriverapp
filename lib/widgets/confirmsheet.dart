import 'package:flutter/material.dart';
import 'package:tankerdriver/brand_colors.dart';
import 'package:tankerdriver/widgets/TaxiOutlineButton.dart';
import 'package:tankerdriver/widgets/taxi_button.dart';

class ConfirmSheet extends StatelessWidget {
  final String title;
  final String subTitle;
  final Function onpressed;

  ConfirmSheet({this.title, this.subTitle, this.onpressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                spreadRadius: 0.5,
                offset: Offset(
                  0.7,
                  0.7,
                ))
          ]),
      height: 220,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Brand-Bold',
                    fontSize: 22,
                    color: BrandColors.colorText),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                subTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Brand-Bold',
                    fontSize: 22,
                    color: BrandColors.colorTextLight),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      child: TaxiOutlineButton(
                        title: 'BACK',
                        color: BrandColors.colorLightGrayFair,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      child: TaxiButton(
                        title: 'CONFIRM',
                        color: (title == 'GO ONLINE')
                            ? BrandColors.colorGreen
                            : Colors.red,
                        onPressed: onpressed,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
