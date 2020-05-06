import 'package:flutter/material.dart';

AppBar header(context, { bool isAppTitle = false, String titleText,
  bool removeBackButton = false, bool addAction = false, Widget action }) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? 'iSocial' : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50.0 : 22.0
      ),
      overflow: TextOverflow.ellipsis
    ),
    iconTheme: IconThemeData(color: Colors.white),
    centerTitle: true,
    backgroundColor: Theme.of(context).cardColor,
    actions: <Widget>[ addAction ? action : Text('') ]
  );
}