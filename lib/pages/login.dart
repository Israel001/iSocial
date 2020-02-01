import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:isocial/models/user.dart';
import 'package:isocial/pages/home.dart';
import 'package:isocial/pages/splash_screen.dart';
import 'package:isocial/widgets/post.dart';
import 'package:isocial/widgets/progress.dart';

import 'create_account.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  bool isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) async {
      if (account != null) {
        setState(() { isLoggingIn = true; });
        await createUserInFirestore();
        configurePushNotifications();
        List<Post> posts = await initTimelinePosts(account.id);
        List<String> followingList = await configureTimelineForNoPost(account.id);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(
            posts: posts,
            followingList: followingList
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
        MaterialPageRoute(builder: (context) => CreateAccount())
      );

      // get username from create account,
      // use it to make new user document in users collection
      usersRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timestamp
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
        body: isLoggingIn ? circularProgress() : Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ]
                )
            ),
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('iSocial',
                      style: TextStyle(
                          fontFamily: "Signatra",
                          fontSize: 90.0,
                          color: Colors.white
                      )
                  ),
                  GestureDetector(
                      onTap: () => googleSignIn.signIn(),
                      child: Container(
                          width: 260.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/google_signin_button.png'),
                                  fit: BoxFit.cover
                              )
                          )
                      )
                  )
                ]
            )
        )
    );
  }
}
