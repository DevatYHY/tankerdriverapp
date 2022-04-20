import 'package:flutter/material.dart';
import 'package:tankerdriver/brand_colors.dart';
import 'package:tankerdriver/helpers/helpermethods.dart';
import 'package:tankerdriver/widgets/brand_divider.dart';
import 'package:tankerdriver/widgets/taxi_button.dart';

class CollectPaymentDialog extends StatelessWidget {
  final String paymentMethod;
  final int fares;

  CollectPaymentDialog({this.paymentMethod, this.fares});

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
            Text('${paymentMethod.toUpperCase()} PAYMENT'),
            SizedBox(
              height: 20,
            ),
            BrandDivider(),
            SizedBox(
              height: 16,
            ),
            Text(
              'Rs $fares',
              style: TextStyle(fontSize: 50, fontFamily: 'Brand-Bold'),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Amount above is the total fares to be charged to the consumer',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: 230,
              child: TaxiButton(
                title: (paymentMethod == 'cash') ? 'COLLECT CASH' : 'CONFIRM',
                color: BrandColors.colorGreen,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  HelperMethods.enableHomTabLocationUpdates();
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
