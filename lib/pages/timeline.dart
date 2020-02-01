import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isocial/models/user.dart';
import 'package:isocial/pages/search.dart';

import 'package:isocial/widgets/header.dart';
import 'package:isocial/widgets/post.dart';
import 'package:isocial/widgets/progress.dart';

import 'home.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  final List<Post> posts;
  final List<String> followingList;

  Timeline({ this.currentUser, this.posts, this.followingList });

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
  with AutomaticKeepAliveClientMixin<Timeline> {
  List<Post> posts = [];
  List<String> followingList = [];
  bool havePost = false;
  bool isLoading = false;
  bool hasMore = true;
  int postLimit = 2;
  DocumentSnapshot lastPost;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setState(() {
      havePost = widget.posts.isNotEmpty;
      followingList = widget.followingList;
    });
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) getTimelinePosts(true);
    });
  }

  getTimelinePosts(bool pagination) async {
    if (!hasMore) return;
    if (isLoading) return;
    setState(() { isLoading = true; });
    QuerySnapshot querySnapshot;
    if (lastPost == null) {
      querySnapshot = await timelineRef
        .document(currentUser.id)
        .collection('timelinePosts')
        .where('isDeleted', isEqualTo: false)
        .limit(postLimit)
        .getDocuments();
    } else {
      querySnapshot = await timelineRef
        .document(currentUser.id)
        .collection('timelinePosts')
        .where('isDeleted', isEqualTo: false)
        .startAfterDocument(lastPost)
        .limit(postLimit)
        .getDocuments();
    }
    if (querySnapshot.documents.length < postLimit) {
      hasMore = false;
      return;
    }
    lastPost = querySnapshot.documents[querySnapshot.documents.length - 1];
    postLimit = posts.length + postLimit;
    setState(() { isLoading = false; });
  }

  buildTimeline() {
    if (!havePost) {
      return buildEmptyTimeline();
    } else {
      return StreamBuilder(
        stream: timelineRef
          .document(currentUser.id).collection('timelinePosts')
          .where('isDeleted', isEqualTo: false)
          .limit(postLimit)
          .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return circularProgress();
          posts = [];
          snapshot.data.documents.forEach((doc) {
            posts.add(Post.fromDocument(doc));
          });
          if (posts.isEmpty) buildEmptyTimeline();
          return ListView(controller: scrollController, children: posts);
        }
      );
    }
  }

  buildEmptyTimeline() {
    return StreamBuilder(
      stream: usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress();
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        if (userResults.isEmpty) return buildNoUsersToFollow();
        return buildUsersToFollow(userResults);
      }
    );
  }

  buildNoUsersToFollow() {
    return ListView(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).accentColor.withOpacity(0.2),
          child: Column(
            children: <Widget>[
              Container(
                child: Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Unfortunately, we could not find any users for you '
                          'to follow. You can search for your friends manually '
                          'to follow them and their posts will show up here 🙂',
                          style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                              fontFamily: 'Signatra'
                          )
                        )
                      ],
                    )
                  )
                )
              )
            ],
          )
        )
      ]
    );
  }

  buildUsersToFollow(users) {
    return ListView(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).accentColor.withOpacity(0.2),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      color: Theme.of(context).primaryColor,
                      size: 30.0
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Users to Follow',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 30.0
                      )
                    )
                  ],
                )
              ),
              Column(children: users)
            ],
          )
        )
      ]
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimelinePosts(false),
        child: buildTimeline()
      ),
    );
  }
}