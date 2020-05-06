import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:isocial/pages/groups/groups.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/pages/profile/edit_profile.dart';
import 'package:isocial/pages/quiz/quiz.dart';
import 'package:isocial/pages/quotes/quotes.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget drawer(context, {String displayName, String email, String photoUrl}) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(displayName),
          accountEmail: Text(email),
          currentAccountPicture: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              pageController.jumpToPage(4);
            },
            child: CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(photoUrl)
            )
          )
        ),
        ListTile(
          leading: Icon(Icons.group),
          title: Text('Groups'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => Groups()
            ));
          }
        ),
        ListTile(
          leading: Icon(Icons.bookmark),
          title: Text('Saved Items'),
          onTap: () {
            Navigator.pop(context);
          }
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.games),
          title: Text('Play Quiz Game'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => Quiz()
            ));
          }
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.format_quote),
          title: Text('Get Daily Quotes'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => Quotes()
            ));
          }
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.question_answer),
          title: Text('Help & support'),
          onTap: () {
            Navigator.pop(context);
          }
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings & Privacy'),
          onTap: () {
            Navigator.pop(context);
          }
        ),
        ListTile(
          leading: Icon(Icons.close),
          title: Text('Log Out'),
          onTap: () async {
            Navigator.pop(context);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            logout(context, prefs: prefs);
          }
        )
      ]
    )
  );
}
