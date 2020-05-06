import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

FlatButton postButton({
  Function handlePressed,
  BuildContext context,
  String text
}) {
  return FlatButton(
    onPressed: handlePressed,
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).accentColor,
          fontWeight: FontWeight.bold
        )
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).accentColor),
        borderRadius: BorderRadius.circular(3.0)
      )
    )
  );
}