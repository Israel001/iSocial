import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isocial/helpers/custom_popup_menu.dart';

Widget popupMenu({
  String tooltip,
  Function onSelect,
  List<CustomPopupMenu> choices,
  BuildContext context,
  IconData icon
}) {
  return Theme(
    data: Theme.of(context).copyWith(cardColor: Colors.white),
    child: PopupMenuButton<CustomPopupMenu>(
      tooltip: tooltip,
      onSelected: onSelect,
      icon: icon != null ? Icon(icon) : Icon(Icons.more_vert),
      itemBuilder: (context) {
        return choices.map((CustomPopupMenu choice) {
          return PopupMenuItem<CustomPopupMenu>(
            value: choice,
            child: choice.icon != null ? Row(
              children: <Widget>[
                Icon(choice.icon, color: Theme.of(context).accentColor),
                Padding(padding: EdgeInsets.only(right: 4.0)),
                Text(choice.title),
                Divider()
              ],
            ) : Text(choice.title)
          );
        }).toList();
      },
    )
  );
}
