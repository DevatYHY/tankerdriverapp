import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tankerdriver/brand_colors.dart';
import 'package:tankerdriver/dataprovider.dart';
import 'package:tankerdriver/widgets/HistoryTile.dart';
import 'package:tankerdriver/widgets/brand_divider.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                'Trip History',
                textAlign: TextAlign.center,
                style: TextStyle(
                    //fontSize: 20,
                    //letterSpacing: 3,
                    //color: Colors.black87,
                    //fontWeight: FontWeight.bold,
                    ),
              ),
            )
          ],
        ),
        backgroundColor: BrandColors.colorPrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return HistoryTile(
            history: Provider.of<AppData>(context).tripHistory[index],
          );
        },
        separatorBuilder: (BuildContext context, int index) => BrandDivider(),
        itemCount: Provider.of<AppData>(context).tripHistory.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
