import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isocial/helpers/custom_popup_menu.dart';

Widget popupMenu({
  String tooltip,
  Function onSelect,
  List<CustomPopupMenu> choices,
  BuildContext context
}) {
  return PopupMenuButton<CustomPopupMenu>(
    tooltip: tooltip,
    onSelected: onSelect,
    itemBuilder: (context) {
      return choices.map((CustomPopupMenu choice) {
        return PopupMenuItem<CustomPopupMenu>(
          value: choice,
          child: Row(
            children: <Widget>[
              Icon(choice.icon, color: Colors.purple),
              Padding(padding: EdgeInsets.only(right: 4.0)),
              Text(choice.title),
              Divider()
            ],
          )
        );
      }).toList();
    },
  );
}