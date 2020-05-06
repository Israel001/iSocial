import 'package:flutter/material.dart';
import 'package:isocial/models/group.dart';
import 'package:isocial/pages/home/home.dart';

import 'create_rule.dart';

class EditRules extends StatefulWidget {
  final Group group;
  final String ruleTitle;
  final String ruleDetails;

  EditRules({ this.group, this.ruleTitle, this.ruleDetails });

  @override
  State<StatefulWidget> createState() {
    return _EditRulesState(
      group: this.group,
      groupRules: this.group.groupRules,
      ruleTitle: this.ruleTitle,
      ruleDetails: this.ruleDetails
    );
  }
}

class _EditRulesState extends State<EditRules> {
  Group group;
  dynamic groupRules;
  String ruleTitle;
  String ruleDetails;
  int rulesLeft = 0;

  _EditRulesState({ 
    this.group, 
    this.groupRules, 
    this.ruleTitle, 
    this.ruleDetails 
  });

  @override
  void initState() {
    super.initState();
    if (ruleTitle != null && ruleTitle.isNotEmpty) {
      int index;
      if (groupRules.length <= 1) {
        index = 0;
      } else {
        index = (groupRules.length / 2).toInt();
      }
      groupRules.addAll({
        'title$index': ruleTitle,
        'details$index': ruleDetails
      });
    }
    rulesLeft = (10.0 - (groupRules.length / 2)).toInt();
  }

  void moveRule(int index, String direction) {
    setState(() {
      String ruleTitle = groupRules['title$index'];
      String ruleDetails = groupRules['details$index'];
      groupRules['title$index'] = direction == 'upward'
          ? groupRules['titles${index-1}']
          : groupRules['title${index+1}'];
      groupRules['details$index'] = direction == 'upward'
          ? groupRules['details${index-1}']
          : groupRules['details${index+1}'];
      if (direction == 'upward') {
        groupRules['title$index'] = groupRules['title${index - 1}'];
        groupRules['title${index - 1}'] = ruleTitle;
        groupRules['details${index - 1}'] = ruleDetails;
      } else if (direction == 'downward') {
        groupRules['title${index + 1}'] = ruleTitle;
        groupRules['details${index + 1}'] = ruleDetails;
      }
    });
  }

  List<Widget> displayGroupRules() {
    List<Widget> widgetLists = [];
    for (int i = 0; i < groupRules.length / 2; i++) {
      widgetLists.add(ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Container(
            color: Colors.white,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 5.0
              ),
              leading: Column(
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.arrow_upward),
                      color: Colors.black,
                      onPressed: i == 0 ? null : () => moveRule(i, 'upward'),
                      disabledColor: Colors.grey,
                    )
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.arrow_downward),
                      color: Colors.black,
                      onPressed: groupRules.length / 2 == 1.0 ? null
                          : i.toDouble() == (groupRules.length / 2) - 1
                          ? null : () => moveRule(i, 'downward'),
                      disabledColor: Colors.grey,
                    )
                  )
                ],
              ),
              title: Text(
                '${i+1}. ${groupRules['title$i']}',
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
              subtitle: Text('${groupRules['details$i']}'),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle_outline),
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    if (groupRules.length / 2 == 1.0 || i == (groupRules.length / 2).toInt() - 1) {
                      groupRules.remove('title$i');
                      groupRules.remove('details$i');
                    } else {
                      groupRules['title$i'] = groupRules['title${i+1}'];
                      groupRules['details$i'] = groupRules['details${i+1}'];
                      groupRules.remove('title${i+1}');
                      groupRules.remove('details${i+1}');
                    }
                    rulesLeft += 1;
                  });
                },
              ),
            )
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
        ],
      ));
    }
    return widgetLists;
  }

  Future<bool> handleBackPressed() {
    if (ruleTitle != null && ruleTitle.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Discard changes?',
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            content: Text(
              "You haven't finished this rule yet. If you discard your changes, "
              "they won't be saved."
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context)
              ),
              FlatButton(
                child: Text(
                  'DISCARD',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold
                  )
                ),
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/group_page'));
                },
              )
            ],
          );
        }
      );
    } else { Navigator.pop(context); }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white70,
          automaticallyImplyLeading: true,
          title: Text('Edit Rules'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                groupsRef.document(group.groupId).updateData({
                  'groupRules': groupRules
                });
                Navigator.pop(context, ModalRoute.withName('/group_page'));
              },
              child: Text(
                'PUBLISH',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0
                )
              )
            )
          ],
        ),
        body: Container(
          color: Colors.grey,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'YOU CAN CREATE $rulesLeft MORE RULES',
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)
                )
              ),
              Expanded(
                flex: 9,
                child: ListView(children: displayGroupRules())
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateRule(
                          group: group
                        ))
                      );
                    },
                    color: Theme.of(context).accentColor,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0
                    ),
                    child: Text('Create Another Rule')
                  )
                )
              )
            ],
          )
        )
      )
    );
  }
}
