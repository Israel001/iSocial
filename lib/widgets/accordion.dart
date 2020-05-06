import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isocial/helpers/quotes.dart';

import '../main.dart';

class Accordion extends StatelessWidget {
  final Quotes quote;

  Accordion(this.quote);

  void showNotificationDailyAtATime() async {
    var time = Time(14, 15, 0);
    var rng = new Random();
    int randomNum = rng.nextInt(quotes.length);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description'
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics
    );
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0, 'Your Daily Quote', quotes[randomNum].title, time,
        platformChannelSpecifics
    );
  }

  Widget _buildTiles(Quotes quote) {
    if (quote.children.isEmpty) return ListTile(
      title: GestureDetector(
        onTap: showNotificationDailyAtATime,
        child: Text(quote.title)
      )
    );
    return ExpansionTile(
      key: PageStorageKey<Quotes>(quote),
      title: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 14.0),
          children: <TextSpan>[
            TextSpan(text: quote.title),
            TextSpan(
              text: ' (${quote.children.length})',
              style: TextStyle(fontSize: 10.0, color: Colors.grey)
            )
          ]
        )
      ),
      children: quote.children.map<Widget>(_buildTiles).toList()
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(quote);
  }
}
