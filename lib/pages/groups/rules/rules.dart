import 'package:flutter/material.dart';
import 'package:isocial/helpers/reusable_functions.dart';
import 'package:isocial/models/group.dart';
import 'package:isocial/widgets/header.dart';

import 'create_rule.dart';

class Rules extends StatefulWidget {
  final Group group;

  Rules({ this.group });

  @override
  State<StatefulWidget> createState() {
    return _RulesState();
  }
}

class _RulesState extends State<Rules> {
  navigateToCreateRule(ruleTitle, ruleDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateRule(
        group: widget.group,
        ruleTitle: ruleTitle,
        ruleDetails: ruleDetails
      ))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Rules'),
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 40.0)),
              Image.asset('assets/images/book.png'),
              Padding(padding: EdgeInsets.only(top: 40.0)),
              Text(
                'Create rules for your group',
                style: TextStyle(fontSize: 20.0)
              ),
              Padding(padding: EdgeInsets.only(top: 20.0)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Write up to 10 rules for the About area of your group. You can '
                  'create your own or edit the example rules.',
                  textAlign: TextAlign.center,
                )
              ),
              Padding(padding: EdgeInsets.only(top: 20.0)),
              RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                child: Text(
                  'GET STARTED',
                  style: TextStyle(color: Colors.white)
                ),
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0))
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateRule(
                      group: widget.group
                    ))
                  );
                },
              ),
              Padding(padding: EdgeInsets.only(top: 20.0)),
            ],
          ),
          Container(
            color: Colors.grey,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'EXAMPLE RULES',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)
              )
            )
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          Column(children: displayExampleRules(navigateToCreateRule)),
        ],
      )
    );
  }
}
