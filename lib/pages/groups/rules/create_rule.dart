import 'package:flutter/material.dart';
import 'package:isocial/helpers/reusable_functions.dart';
import 'package:isocial/models/group.dart';
import 'package:isocial/widgets/snackbar.dart';

import 'edit_rules.dart';

class CreateRule extends StatefulWidget {
  final Group group;
  final String ruleTitle;
  final String ruleDetails;

  CreateRule({ this.group, this.ruleTitle, this.ruleDetails });

  @override
  State<StatefulWidget> createState() {
    return _CreateRuleState();
  }
}

class _CreateRuleState extends State<CreateRule> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController ruleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.ruleTitle != null && widget.ruleDetails != null) {
      ruleController.text = widget.ruleTitle;
      detailsController.text = widget.ruleDetails;
    }
  }

  submitRule() {
    String rule = ruleController.text;
    if (rule != null && rule.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditRules(
          ruleTitle: ruleController.text,
          ruleDetails: detailsController.text,
          group: widget.group
        ))
      );
    } else {
      SnackBar snackBar = snackbar(
        msg: 'You have to specify a rule',
        bgColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 5000)
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  navigateToEditRule(ruleTitle, ruleDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditRules(
        ruleTitle: ruleTitle,
        ruleDetails: ruleDetails,
        group: widget.group
      ))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        automaticallyImplyLeading: true,
        title: Text('Create Rule'),
        actions: <Widget>[
          FlatButton(
            onPressed: submitRule,
            child: Text(
              'NEXT',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              )
            )
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: ruleController,
              decoration: InputDecoration(
                hintText: 'Write the rule...',
                contentPadding: EdgeInsets.all(10.0)
              ),
              maxLength: 50,
              maxLines: null
            )
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: detailsController,
              decoration: InputDecoration(
                hintText: 'Add details...',
                contentPadding: EdgeInsets.all(10.0)
              ),
              maxLength: 200,
              maxLines: null
            )
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
          Column(children: displayExampleRules(navigateToEditRule))
        ],
      )
    );
  }
}
