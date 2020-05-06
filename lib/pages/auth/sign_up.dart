import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:isocial/widgets/progress.dart';
import 'package:isocial/widgets/snackbar.dart';

import 'package:native_state/native_state.dart';

import 'package:isocial/pages/profile/edit_profile.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/pages/auth/login.dart';

class SignUp extends StatefulWidget {
  static const String route = '/sign_up';
  final SavedStateData savedState;

  SignUp({ this.savedState });

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp>
  with AutomaticKeepAliveClientMixin<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FocusNode _displayNameFocusNode = FocusNode();
  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _mobileFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _obscureText = true;
  bool _isLoading = false;
  String _displayName, _username, _email, _mobile, _password;

  InputDecoration textFieldDecoration(
    {String labelText, String hintText, Icon icon, FocusNode focusNode,
    bool obscureText = false}) {
    return InputDecoration(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).accentColor)
      ),
      labelStyle: TextStyle(
        color: focusNode.hasFocus ? Theme.of(context).accentColor : Colors.grey
      ),
      suffixIcon: obscureText ? GestureDetector(
        onTap: () => setState(() =>  _obscureText = !_obscureText),
        child: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: focusNode.hasFocus ? Theme.of(context).accentColor : Colors.grey
        )
      ) : Text(''),
      labelText: labelText,
      hintText: hintText,
      icon: icon
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Text(
        'Sign Up',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30.0
        )
      )
    );
  }

  Widget _showDisplayNameInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        focusNode: _displayNameFocusNode,
        onSaved: (val) => _displayName = val,
        validator: (val) {
          if (val.isEmpty) {
            return 'This field cannot be blank';
          } else if (val.trim().length < 3) {
            return 'Display name is too short';
          } else if (val.trim().length > 30) {
            return 'Display name is too long';
          } else if (!RegExp(r'^[a-zA-Z\s]{0,255}$').hasMatch(val)) {
            return 'Name must contain alphabets ONLY';
          } else {
            return null;
          }
        },
        decoration: textFieldDecoration(
          labelText: 'Display Name',
          hintText: 'Enter your display name, max: 30',
          icon: Icon(
            Icons.person,
            color: _displayNameFocusNode.hasFocus
                ? Theme.of(context).accentColor : Colors.grey
          ),
          focusNode: _displayNameFocusNode,
        )
      )
    );
  }

  Widget _showUsernameInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        focusNode: _usernameFocusNode,
        onSaved: (val) => _username = val,
        validator: (val){
          if (val.isEmpty) {
            return 'This field cannot be blank';
          } else if (val.trim().length < 4) {
            return 'Username is too short';
          } else if (val.trim().length > 12) {
            return 'Username is too long';
          } else if (!RegExp(r'[a-zA-Z0-9]').hasMatch(val)) {
            return 'Username must contain alphanumerics ONLY';
          } else {
            return null;
          }
        },
        decoration: textFieldDecoration(
          labelText: 'Username',
          hintText: 'Enter your username, min: 4, max: 12',
          icon: Icon(
            Icons.face,
            color: _usernameFocusNode.hasFocus
                ? Theme.of(context).accentColor : Colors.grey
          ),
          focusNode: _usernameFocusNode,
        )
      )
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        focusNode: _emailFocusNode,
        onSaved: (val) => _email = val,
        validator: (val) {
          if (val.isEmpty) {
            return 'This field cannot be blank';
          } else if (!RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
            r"*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*["
            r"a-z0-9])?").hasMatch(val)) {
            return 'Invalid email';
          } else {
            return null;
          }
        },
        decoration: textFieldDecoration(
          labelText: 'Email Address',
          hintText: 'Enter your email address',
          icon: Icon(
            Icons.mail,
            color: _emailFocusNode.hasFocus
                ? Theme.of(context).accentColor : Colors.grey,
          ),
          focusNode: _emailFocusNode,
        )
      )
    );
  }

  Widget _showMobileInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        focusNode: _mobileFocusNode,
        keyboardType: TextInputType.number,
        onSaved: (val) => _mobile = val,
        validator: (val) {
          if (val.isNotEmpty && !RegExp(r'[+0-9]').hasMatch(val)) {
            return 'Invalid phone number';
          } else {
            return null;
          }
        },
        decoration: textFieldDecoration(
          labelText: 'Phone Number',
          hintText: 'Enter your phone number',
          icon: Icon(
            Icons.phone_android,
            color: _mobileFocusNode.hasFocus
                ? Theme.of(context).accentColor : Colors.grey,
          ),
          focusNode: _mobileFocusNode,
        )
      )
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        focusNode: _passwordFocusNode,
        onSaved: (val) => _password = val,
        onFieldSubmitted: (val) => _password = val,
        validator: (val) {
          if (val.isEmpty) {
            return 'This field cannot be blank';
          } else if (val.trim().length < 8) {
            return 'Password is too short';
          } else if (val.trim().length > 30) {
            return 'Password is too long';
          } else if (!RegExp(
              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$'
            ).hasMatch(val)) {
            return 'Password is too weak';
          } else {
            return null;
          }
        },
        obscureText: _obscureText,
        decoration: textFieldDecoration(
          labelText: 'Password',
          hintText: 'Enter your password, min: 8, max: 30',
          icon: Icon(
            Icons.lock,
            color: _passwordFocusNode.hasFocus
                ? Theme.of(context).accentColor : Colors.grey
          ),
          focusNode: _passwordFocusNode,
          obscureText: true
        )
      )
    );
  }

  Widget _showConfirmPasswordInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        focusNode: _confirmPasswordFocusNode,
        validator: (val) => val != _password ? 'Passwords do not match' : null,
        obscureText: _obscureText,
        decoration: textFieldDecoration(
          labelText: 'Confirm Password',
          hintText: 'Re-enter your password',
          icon: Icon(
            Icons.lock,
            color: _confirmPasswordFocusNode.hasFocus
                ? Theme.of(context).accentColor : Colors.grey
          ),
          focusNode: _confirmPasswordFocusNode,
          obscureText: true
        )
      )
    );
  }

  Widget _showFormActions() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          _isLoading ? circularProgress(context) : RaisedButton(
            child: Text(
              'Submit',
              style: TextStyle(
                color: Colors.black
              )
            ),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            color: Theme.of(context).accentColor,
            onPressed: _submit,
          ),
          FlatButton(
            child: Text('Existing user? Login'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: Login.route),
                builder: (context) => Login(savedState: widget.savedState)
              )
            ),
          )
        ]
      )
    );
  }

  Future<bool> _checkForDuplicate() async {
    bool duplicate = true;
    QuerySnapshot usernameQuerySnapshot = await usersRef
      .where('username', isEqualTo: _username)
      .getDocuments();
    QuerySnapshot mobileQuerySnapshot = await usersRef
      .where('mobile', isEqualTo: _mobile)
      .getDocuments();
    QuerySnapshot emailQuerySnapshot = await usersRef
      .where('email', isEqualTo: _email)
      .getDocuments();
    if (usernameQuerySnapshot.documents.length > 0) {
      SnackBar snackBar = snackbar(
        msg: 'The username provided already exists',
        bgColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 5000)
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return duplicate;
    } else if (mobileQuerySnapshot.documents.length > 0) {
      SnackBar snackBar = snackbar(
        msg: 'The phone number provided already exists',
        bgColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 5000)
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return duplicate;
    } else if (emailQuerySnapshot.documents.length > 0) {
      SnackBar snackBar = snackbar(
        msg: 'The email provided already eixsts',
        bgColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 5000)
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return duplicate;
    } else { return !duplicate; }
  }

  void _submit() async {
    setState(() { _isLoading = true; });
    final form = _formKey.currentState;
    bool isDuplicate;
    if (form.validate()) {
      form.save();
      isDuplicate = await _checkForDuplicate();
      if (!isDuplicate) {
        String combinedStr = _displayName + _username;
        List<String> searchKeys = extractUniqueChars(combinedStr);
        FirebaseUser user = await firebaseAuth
          .createUserWithEmailAndPassword(email: _email, password: _password);
        usersRef.document(user.uid).setData({
          'id': user.uid,
          'username': _username,
          'photoUrl': '',
          'email': user.email,
          'displayName': _displayName,
          'bio': '',
          'mobile': _mobile,
          'searchKeys': searchKeys,
          'timestamp': timestamp,
          'snoozed': {}
        });
        await followersRef
          .document(user.uid)
          .collection('userFollowers')
          .document(user.uid)
          .setData({});
        try {
          await user.sendEmailVerification();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Email Verification'),
                content: Text('Your account has been created successfully. '
                    'Visit your email and click on the verification link sent to '
                    'you from iSocial.'
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Done'),
                    onPressed: () {
                      setState(() { _isLoading = false; });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(name: Login.route),
                          builder: (context) => Login(savedState: widget.savedState)
                        )
                      );
                    }
                  ),
                  FlatButton(
                    child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                    onPressed: () => Navigator.pop(context)
                  )
                ],
              );
            }
          );
        } catch (e) {
          SnackBar snackBar = snackbar(
            msg: 'An error occurred while trying to send email verification',
            bgColor: Theme.of(context).accentColor,
            duration: Duration(milliseconds: 5000)
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      }
    }
    setState(() { _isLoading = false; });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _showTitle(),
                  _showDisplayNameInput(),
                  _showUsernameInput(),
                  _showEmailInput(),
                  _showMobileInput(),
                  _showPasswordInput(),
                  _showConfirmPasswordInput(),
                  _showFormActions()
                ]
              )
            )
          )
        )
      )
    );
  }
}