import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isocial/models/user.dart';
import 'package:isocial/pages/search/search.dart';
import 'package:isocial/pages/splash_screen.dart';
import 'package:isocial/widgets/drawer.dart';

import 'package:isocial/widgets/header.dart';
import 'package:isocial/widgets/post.dart';
import 'package:isocial/widgets/progress.dart';

import 'package:isocial/pages/home/home.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  final List<Post> posts;
  final List<String> followingList;

  Timeline({
    this.currentUser,
    this.posts,
    this.followingList,
  });

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
  with AutomaticKeepAliveClientMixin<Timeline> {
  List<Post> posts = [];
  List<String> followingList = [];
  bool isLoading = false;
  bool hasMore = true;
  int postLimit = 2;
  DocumentSnapshot lastPost;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setState(() {
      posts = widget.posts;
      followingList = widget.followingList;
    });
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      if (maxScroll == currentScroll) setState(() => postLimit += 2);
    });
    resetFollowingList();
  }

  getTimelinePosts() async {
    if (!hasMore) return;
    if (isLoading) return;
    setState(() { isLoading = true; });
    QuerySnapshot querySnapshot;
    if (lastPost == null) {
      querySnapshot = await timelineRef
        .document(currentUser.id)
        .collection('timelinePosts')
        .limit(postLimit)
        .where('hide', isEqualTo: false)
        .where('postAudience', isEqualTo: 'Followers')
        .where('snoozed', isEqualTo: false)
        .getDocuments();
    } else {
      querySnapshot = await timelineRef
        .document(currentUser.id)
        .collection('timelinePosts')
        .startAfterDocument(lastPost)
        .limit(postLimit)
        .where('hide', isEqualTo: false)
        .where('postAudience', isEqualTo: 'Followers')
        .where('snoozed', isEqualTo: false)
        .getDocuments();
    }
    if (querySnapshot.documents.length < postLimit) {
      hasMore = false;
      return;
    }
    lastPost = querySnapshot.documents[querySnapshot.documents.length - 1];
    querySnapshot.documents.forEach((doc) {
      posts.add(Post.fromDocument(doc));
    });
    postLimit = posts.length + postLimit;
    setState(() { isLoading = false; });
  }

  buildTimeline() {
    return StreamBuilder(
      stream: timelineRef
        .document(currentUser.id).collection('timelinePosts')
        .where('hide', isEqualTo: false)
        .where('postAudience', isEqualTo: 'Followers')
        .where('snoozed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(postLimit)
        .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress(context);
        posts = [];
        snapshot.data.documents.forEach((doc) {
          posts.add(Post.fromDocument(doc));
        });
        if (posts.isEmpty) return buildEmptyTimeline();
        return ListView(controller: scrollController, children: posts);
      }
    );
  }

  buildEmptyTimeline() {
    return StreamBuilder(
      stream: usersRef.orderBy('timestamp', descending: true).limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress(context);
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
            UserResult userResult = UserResult(user, query: '');
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
                          'Start following users and their posts will show up'
                              'here',
                          style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
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
          color: Theme.of(context).primaryColorLight.withOpacity(0.2),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 30.0
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Users to Follow',
                      style: TextStyle(
                        color: Colors.black,
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

  resetFollowingList() async {
    List<String> newFollowList = await configureTimelineForNoPost(currentUser.id);
    if (newFollowList.length != followingList.length) setState(() {});
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      drawer: drawer(
        context,
        displayName: currentUser.displayName,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl
      ),
      body: RefreshIndicator(
        onRefresh: () => getTimelinePosts(),
        child: posts.isEmpty ? buildEmptyTimeline() : buildTimeline()
      ),
    );
  }
}