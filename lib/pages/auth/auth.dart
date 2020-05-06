import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:isocial/pages/auth/sign_up.dart';
import 'package:native_state/native_state.dart';

import 'package:isocial/models/user.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/pages/splash_screen.dart';
import 'package:isocial/widgets/post.dart';
import 'package:isocial/widgets/progress.dart';

import 'create_account.dart';
import 'package:isocial/pages/profile/edit_profile.dart';

class Auth extends StatefulWidget {
  static const String route = '/login';

  final SavedStateData savedState;

  Auth({ this.savedState });

  @override
  State<StatefulWidget> createState() {
    return _AuthState();
  }
}

class _AuthState extends State<Auth> {
  bool isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) async {
      if (account != null) {
        setState(() { isLoggingIn = true; });
        await createUserInFirestore();
        configurePushNotifications(account.id);
        List<Post> posts = await initTimelinePosts(account.id);
        List<String> followingList = await configureTimelineForNoPost(account.id);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(
            posts: posts,
            followingList: followingList,
            savedState: widget.savedState,
          ))
        );
      }
    }, onError: (err) {
      print('Error signing in: $err');
    });
  }

  createUserInFirestore() async {
    // check if user exists in users collection database
    // (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if(!doc.exists) {
      // if the user doesn't exist, take them to the create account page
      final username = await Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: CreateAccount.route),
          builder: (context) => CreateAccount(savedState: widget.savedState)
        )
      );

      // full-text search configuration
      String combinedStr = user.displayName + username;
      List<String> searchKeys = extractUniqueChars(combinedStr);

      // get username from create account,
      // use it to make new user document in users collection
      usersRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'searchKeys': searchKeys,
        'timestamp': timestamp,
        'snoozed': {}
      });

      await followersRef
        .document(user.id)
        .collection('userFollowers')
        .document(user.id)
        .setData({});

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoggingIn ? circularProgress(context) : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).primaryColorDark
            ]
          )
        ),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Image.asset(
                      'assets/launcher/logo.png',
                      width: 80,
                      height: 80
                    )
                  )
                ]
              )
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Sign Up / Log In',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 26.5
                        )
                      )
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(name: SignUp.route),
                          builder: (context) => SignUp(
                            savedState: widget.savedState
                          )
                        )
                      );
                    },
                  )
                ]
              )
            ),
            Expanded(
              flex: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: GestureDetector(
                      onTap: () => googleSignIn.signIn(),
                      child: Container(
                        width: 260.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/google_signin_button.png'
                            ),
                            fit: BoxFit.cover
                          )
                        )
                      )
                    )
                  )
                ],
              )
            )
          ]
        )
      )
    );
  }
}
