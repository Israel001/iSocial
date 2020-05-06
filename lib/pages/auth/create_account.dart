import 'dart:async';

import 'package:flutter/material.dart';
import 'package:native_state/native_state.dart';

import 'package:isocial/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  static const String route = '/create_account';

  final SavedStateData savedState;

  CreateAccount({ this.savedState });

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

  @override
  void initState() {
    super.initState();
    setState(() { username = widget.savedState.getString('username'); });
  }

  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(content: Text('Welcome $username!'));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        titleText: 'Set up your profile',
        removeBackButton: true
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      'Create a username',
                      style: TextStyle(fontSize: 25.0)
                    )
                  )
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      onWillPop: () async => false,
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        validator: (val) {
                          if (val.trim().length < 4 || val.isEmpty) {
                            return 'Username is too short';
                          } else if (val.trim().length > 12) {
                            return 'Username is too long';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) {
                          username = val;
                          widget.savedState.putString('username', val);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: 'Must be at least 4 characters'
                        )
                      )
                    )
                  )
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue, 
                      borderRadius: BorderRadius.circular(7.0)
                    ),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold
                        )
                      )
                    )
                  )
                )
              ],
            )
          )
        ],
      )
    );
  }
}