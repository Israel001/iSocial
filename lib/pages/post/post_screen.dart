import 'package:flutter/material.dart';

import 'package:isocial/pages/home/home.dart';

import 'package:isocial/widgets/header.dart';
import 'package:isocial/widgets/post.dart';
import 'package:isocial/widgets/progress.dart';
import 'package:native_state/native_state.dart';

class PostScreen extends StatelessWidget {
  final SavedStateData savedState;
  final String userId;
  final String postId;

  PostScreen({ this.userId, this.postId, this.savedState });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
        .document(userId)
        .collection('userPosts')
        .document(postId)
        .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, titleText: post.caption),
            body: ListView(
              children: <Widget>[
                Container(child: post)
              ],
            )
          )
        );
      }
    );
  }
}