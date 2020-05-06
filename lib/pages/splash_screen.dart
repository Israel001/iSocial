import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:isocial/models/user.dart';
import 'package:isocial/widgets/post.dart';
import 'package:native_state/native_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:isocial/pages/home/home.dart';
import 'package:isocial/pages/auth/auth.dart';

class SplashScreen extends StatefulWidget {
  final SavedStateData savedState;
  final BuildContext context;

  SplashScreen(this.context, { this.savedState });

  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Timer _timer;

  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    googleSignIn.signInSilently(suppressErrors: false)
      .then((account) async {
        if (account != null) {
          List<Post> posts = await initTimelinePosts(account.id);
          List<String> followingList = await configureTimelineForNoPost(
            account.id
          );
          currentUser =
            User.fromDocument(await usersRef.document(account.id).get());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(
                posts: posts,
                followingList: followingList,
                savedState: widget.savedState
              )
            )
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: Auth.route),
              builder: (context) => Auth(savedState: widget.savedState)
            )
          );
        }
      }).catchError((_) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String userId = prefs.getString('userId');
        if (userId != null && userId.isNotEmpty) {
          DocumentSnapshot doc = await usersRef.document(userId).get();
          currentUser = User.fromDocument(doc);
          List<Post> posts = await initTimelinePosts(userId);
          List<String> followingList = await configureTimelineForNoPost(userId);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(
                posts: posts,
                followingList: followingList,
                savedState: widget.savedState,
              )
            )
          );
        } else {
          _timer = new Timer(
            Duration(milliseconds: 3000),
            () {
              Future(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: Auth.route),
                      builder: (context) =>
                        Auth(savedState: widget.savedState)
                  )
                );
              });
            }
          );
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/launcher/logo.png'),
              fit: BoxFit.cover
            )
          ),
        )
      )
    );
  }
}

initTimelinePosts(String userId) async {
  QuerySnapshot snapshot = await timelineRef
    .document(userId)
    .collection('timelinePosts')
    .where('hide', isEqualTo: false)
    .where('postAudience', isEqualTo: 'Followers')
    .where('snoozed', isEqualTo: false)
    .limit(1)
    .getDocuments();
  List<Post> posts =
  snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
  return posts;
}

configureTimelineForNoPost(String userId) async {
  QuerySnapshot snapshot = await followingRef
    .document(userId)
    .collection('userFollowing')
    .getDocuments();
  List<String> followingList = snapshot.documents
    .map((doc) => doc.documentID).toList();
  return followingList;
}
