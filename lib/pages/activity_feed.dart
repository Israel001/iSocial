import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/pages/post_screen.dart';
import 'package:isocial/pages/profile.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:isocial/pages/home.dart';

import 'package:isocial/widgets/header.dart';
import 'package:isocial/widgets/progress.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.2),
      appBar: header(context, titleText: 'Activity Feed'),
      body: Container(
        child: StreamBuilder(
          stream: activityFeedRef.document(currentUser.id)
              .collection('feedItems').orderBy('timestamp', descending: true)
              .limit(50).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            List<ActivityFeedItem> feedItems = [];
            snapshot.data.documents.forEach((doc) {
              feedItems.add(ActivityFeedItem.fromDocument(doc));
            });
            if (feedItems.isEmpty) {
              return Column(
                children: <Widget>[
                  Container(
                    child: Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Your Activity Feed is currently empty. '
                              'When people react to your activities. '
                              'A history of their actions / reactions '
                              'will be displayed here 🙂',
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
              );
            }
            return ListView(children: feedItems);
          }
        )
      )
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String data;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.data,
    this.timestamp
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      data: doc['data'],
      timestamp: doc['timestamp'],
      mediaUrl: doc['mediaUrl'],
    );
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: currentUser.id
        )
      )
    );
  }

  configureMediaPreview(context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl)
                )
              )
            )
          )
        )
      );
    } else {
      mediaPreview = Text('');
    }

    switch(type) {
      case 'like':
        activityItemText = 'liked your post';
      break;

      case 'likeComment':
        activityItemText = "liked your comment: '$data'";
      break;

      case 'follow':
        activityItemText = 'is following you';
      break;

      case 'comment':
        activityItemText = "commented on your post: '$data'";
      break;

      case 'reply':
        activityItemText = "replied to your comment: '$data'";
      break;

      case 'likeReply':
        activityItemText = "liked your reply: '$data'";
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(text: ' $activityItemText')
                ]
              )
            )
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis
          ),
          trailing: mediaPreview
        )
      )
    );
  }
}

showProfile(BuildContext context, { String profileId }) {
  atOtherProfile = true;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(profileId: profileId,)
    )
  );
}