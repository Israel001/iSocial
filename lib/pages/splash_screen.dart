import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:isocial/models/user.dart';
import 'package:isocial/widgets/post.dart';

import 'home.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    googleSignIn.signInSilently(suppressErrors: false)
      .then((account) async {
        if (account != null) {
          List<Post> posts = await initTimelinePosts(account.id);
          List<String> followingList = await configureTimelineForNoPost(account.id);
          currentUser =
            User.fromDocument(await usersRef.document(account.id).get());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home(
              posts: posts,
              followingList: followingList
            ))
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login())
          );
        }
      }).catchError((_){
        Timer(
          Duration(seconds: 3),
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login())
              );
            }
        );
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
    .orderBy('createdAt', descending: true)
    .where('isDeleted', isEqualTo: false)
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
  List<String> followingList =
  snapshot.documents.map((doc) => doc.documentID).toList();
  return followingList;
}
