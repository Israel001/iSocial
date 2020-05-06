import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:isocial/models/user.dart';
import 'package:isocial/pages/splash_screen.dart';
import 'package:isocial/widgets/post.dart';
import 'package:isocial/widgets/progress.dart';
import 'package:isocial/widgets/snackbar.dart';

import 'package:native_state/native_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:isocial/pages/home/home.dart';

class Login extends StatefulWidget {
  static const String route = '/login';
  final SavedStateData savedState;

  Login({ this.savedState });

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login>
  with AutomaticKeepAliveClientMixin<Login> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  bool _obscureText = true;
  bool _isLoading = false;
  String _email, _password;

  InputDecoration textFieldDecoration(
      {String labelText, String hintText, Icon icon, FocusNode focusNode,
        bool obscureText}) {
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
          _obscureText ? Icons.visibility : Icons.visibility_off,
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
        'Log In',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30.0
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
        decoration: textFieldDecoration(
          labelText: 'Email Address',
          hintText: 'Enter your email address',
          icon: Icon(
            Icons.mail,
            color: _emailFocusNode.hasFocus
                ? Theme.of(context).accentColor : Colors.grey
          ),
          focusNode: _emailFocusNode,
          obscureText: false
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
        obscureText: _obscureText,
        decoration: textFieldDecoration(
          labelText: 'Password',
          hintText: 'Enter your password',
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

  Widget _showFormActions() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          _isLoading ? circularProgress(context) : RaisedButton(
            child: Text(
              'Login',
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
            child: Text('New user? Sign Up'),
            onPressed: () => Navigator.pop(context),
          )
        ]
      )
    );
  }

  void _submit() async {
    setState(() { _isLoading = true; });
    final form = _formKey.currentState;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (form.validate()) {
      form.save();
      try {
        FirebaseUser user = await firebaseAuth.signInWithEmailAndPassword(
          email: _email,
          password: _password
        );
        if (user.isEmailVerified) {
          prefs.setString('userId', user.uid);
          prefs.setString('password', _password);
          prefs.setString('signInMethod', 'password');
          DocumentSnapshot doc = await usersRef.document(user.uid).get();
          currentUser = User.fromDocument(doc);
          configurePushNotifications(user.uid);
          List<Post> posts = await initTimelinePosts(user.uid);
          List<String> followingList = await configureTimelineForNoPost(user.uid);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Home(
                posts: posts,
                followingList: followingList,
                savedState: widget.savedState
              )
            ),
            (Route<dynamic> route) => false
          );
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Email Verification'),
                content: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.title.copyWith(
                      fontSize: 15.0
                    ),
                    children: [
                      TextSpan(
                        text: 'Please check your email for a verification link '
                            'sent from iSocial. If your email is valid, and you '
                            'did not receive a verification link, '
                      ),
                      TextSpan(
                        text: 'click on this to get a new verification link',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).accentColor
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () async {
                          Navigator.pop(context);
                          try {
                            await user.sendEmailVerification();
                            SnackBar snackBar = snackbar(
                              msg: 'Please check your email',
                              bgColor: Theme.of(context).accentColor,
                              duration: Duration(milliseconds: 5000)
                            );
                            _scaffoldKey.currentState.showSnackBar(snackBar);
                          } catch (e) {
                            SnackBar snackBar = snackbar(
                              msg: 'An error occurred while trying to send email '
                                  'verification',
                              bgColor: Theme.of(context).accentColor,
                              duration: Duration(milliseconds: 5000)
                            );
                            _scaffoldKey.currentState.showSnackBar(snackBar);
                          }
                        }
                      )
                    ]
                  )
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Dismiss', style: TextStyle(color: Colors.grey)),
                    onPressed: () => Navigator.pop(context),
                  )
                ]
              );
            }
          );
        }
      } catch (e) {
        SnackBar snackBar = snackbar(
          msg: 'Something went wrong. Please review your details',
          bgColor: Theme.of(context).accentColor,
          duration: Duration(milliseconds: 5000)
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
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
                  _showEmailInput(),
                  _showPasswordInput(),
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