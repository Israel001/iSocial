import 'package:flutter/material.dart';

dialog({
  BuildContext parentContext,
  String titleText,
  String contentText,
  String firstButtonText,
  String secondButtonText,
  Function firstButtonClicked,
  Function secondButtonClicked
}) {
  return showDialog(
    context: parentContext,
    builder: (context) {
      return AlertDialog(
        title: Text(titleText),
        content: Text(contentText),
        actions: <Widget>[
          FlatButton(
            child: Text(
              firstButtonText,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold
              )
            ),
            onPressed: firstButtonClicked(),
          ),
          FlatButton(
            child: Text(secondButtonText),
            onPressed: secondButtonClicked(),
          )
        ],
      );
    }
  );
}