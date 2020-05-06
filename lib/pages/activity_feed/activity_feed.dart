import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/pages/post/post_screen.dart';
import 'package:isocial/pages/profile/profile.dart';
import 'package:isocial/widgets/drawer.dart';
import 'package:native_state/native_state.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:isocial/pages/home/home.dart';

import 'package:isocial/widgets/header.dart';
import 'package:isocial/widgets/progress.dart';
import 'package:video_player/video_player.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(
        context,
        displayName: currentUser.displayName,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl
      ),
      backgroundColor: Theme.of(context).primaryColorLight.withOpacity(0.2),
      appBar: header(context, titleText: 'Activity Feed'),
      body: Container(
        child: StreamBuilder(
          stream: activityFeedRef.document(currentUser.id)
            .collection('feedItems').orderBy('timestamp', descending: true)
            .limit(50).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress(context);
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
                              'When people react to your activities, '
                              'their actions / reactions '
                              'will be displayed here',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent
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

class ActivityFeedItem extends StatefulWidget {
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String postOwnerId;
  final String userProfileImg;
  final String data;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.postOwnerId,
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
      postOwnerId: doc['postOwnerId'],
      userProfileImg: doc['userProfileImg'],
      data: doc['data'],
      timestamp: doc['timestamp'],
      mediaUrl: doc['mediaUrl']
    );
  }

  @override
  _ActivityFeedItemState createState() => _ActivityFeedItemState();
}

class _ActivityFeedItemState extends State<ActivityFeedItem>
    with StateRestoration {
  SavedStateData savedState;

  @override
  void restoreState(SavedStateData savedState) {
    setState(() { this.savedState = savedState; });
  }

  configureMediaPreview(context) {
    if (widget.type == 'like' || widget.type == 'comment') {
      if (widget.mediaUrl.contains('mp4')) {
        VideoPlayerController videoPlayer = VideoPlayerController.network(
          widget.mediaUrl
        );
        mediaPreview = GestureDetector(
          onTap: () => showPost(context, widget.postId, widget.postOwnerId),
          child: Container(
            height: 50.0,
            width: 50.0,
            child: FutureBuilder(
              future: videoPlayer.initialize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return VideoPlayer(videoPlayer);
                }
                return Center(child: circularProgress(context));
              }
            )
          )
        );
      } else {
        mediaPreview = GestureDetector(
          onTap: () => showPost(context, widget.postId, widget.postOwnerId),
          child: Container(
            height: 50.0,
            width: 50.0,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(widget.mediaUrl)
                  )
                )
              )
            )
          )
        );
      }
    } else {
      mediaPreview = Text('');
    }

    switch(widget.type) {
      case 'like':
        activityItemText = 'liked your post';
      break;

      case 'likeComment':
        activityItemText = "liked your comment: '${widget.data}'";
      break;

      case 'follow':
        activityItemText = 'is following you';
      break;

      case 'comment':
        activityItemText = "commented on your post: '${widget.data}'";
      break;

      case 'reply':
        activityItemText = "replied to your comment: '${widget.data}'";
      break;

      case 'likeReply':
        activityItemText = "liked your reply: '${widget.data}'";
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Theme.of(context).accentColor.withOpacity(0.7),
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(
              context,
              profileId: widget.userId,
              savedState: savedState
            ),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black
                ),
                children: [
                  TextSpan(
                    text: widget.username,
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(text: ' $activityItemText')
                ]
              )
            )
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.userProfileImg),
          ),
          subtitle: Text(
            timeago.format(widget.timestamp.toDate()),
            overflow: TextOverflow.ellipsis
          ),
          trailing: mediaPreview
        )
      )
    );
  }
}

showProfile(BuildContext context, { String profileId, SavedStateData savedState
}) {
  atOtherProfile = true;
  Navigator.push(
    context,
    MaterialPageRoute(
//      settings: RouteSettings(name: Profile.route),
      builder: (context) => Profile(
        profileId: profileId,
        savedState: savedState
      )
    )
  );
}

showPost(context, postId, postOwner) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostScreen(
        postId: postId,
        userId: postOwner
      )
    )
  );
}