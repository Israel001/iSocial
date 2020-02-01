import 'package:flutter/material.dart';
import 'package:isocial/helpers/activities.dart';

class SubActivities extends StatelessWidget {
  final String type;
  final List<Activities> subActivities;

  SubActivities({ this.type, this.subActivities });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            type,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0
            )
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context, ''),
              icon: Icon(
                Icons.close,
                size: 30.0,
                color: Colors.white
              )
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: ListView(
            shrinkWrap: true,
            children: List.generate(subActivities.length, (index) {
              return GestureDetector(
                onTap: () => Navigator.pop(
                  context,
                  subActivities[index].title
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 10.0)),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text(subActivities[index].title)
                    ),
                    Padding(padding: EdgeInsets.only(top: 10.0)),
                    Divider()
                  ],
                )
              );
            })
          )
        )
      )
    );
  }
}
