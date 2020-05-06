import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/pages/comments/comments.dart';
import 'package:isocial/widgets/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import 'package:isocial/helpers/custom_popup_menu.dart';

import 'package:isocial/pages/home/home.dart';

import 'package:isocial/widgets/header.dart';
import 'package:isocial/widgets/progress.dart';
import 'package:isocial/widgets/popup_menu.dart';

TextEditingController replyController = TextEditingController();
String state = 'add';
String replyIdForEditing;

class Replies extends StatefulWidget {
  final String commentId;
  final String commentOwnerId;
  final String comment;
  final String postId;

  Replies({
    this.commentId,
    this.commentOwnerId,
    this.comment,
    this.postId
  });

  @override
  RepliesState createState() => RepliesState(
    commentId: this.commentId,
    commentOwnerId: this.commentOwnerId,
    comment: this.comment,
    postId: this.postId
  );
}

class RepliesState extends State<Replies> {
  final String commentId;
  final String commentOwnerId;
  final String comment;
  final String postId;
  String replyId = Uuid().v4();

  RepliesState({
    this.commentId,
    this.commentOwnerId,
    this.comment,
    this.postId
  });

  buildComment() {
    return StreamBuilder(
      stream: commentsRef.document(postId).collection('comments')
          .where('commentId', isEqualTo: commentId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        Comment comment;
        snapshot.data.documents.forEach((doc) {
          comment = Comment.fromDocument(doc, true);
        });
        return comment;
      }
    );
  }

  buildReplies() {
    return StreamBuilder(
      stream: repliesRef.document(commentId).collection('replies')
          .orderBy('createdAt', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        List<Reply> replies = [];
        snapshot.data.documents.forEach((doc) {
          replies.add(Reply.fromDocument(doc));
        });
        return Padding(
          padding: EdgeInsets.only(left: 40.0),
          child: ListView(children: replies)
        );
      }
    );
  }

  editReply() {
    String reply = replyController.text;
    repliesRef
      .document(commentId)
      .collection('replies')
      .document(replyIdForEditing)
      .get().then((doc) {
        if (doc.exists) {
          if (reply != doc.data['reply']) {
            doc.reference.setData({
              'username': doc.data['username'],
              'originalReply': doc.data['reply'],
              'reply': reply,
              'createdAt': doc.data['createdAt'],
              'updatedAt': DateTime.now(),
              'avatarUrl': doc.data['avatarUrl'],
              'userId': doc.data['userId'],
              'commentId': doc.data['commentId'],
              'replyId': doc.data['replyId'],
              'likes': doc.data['likes'],
              'status': 'edited'
            });
          }
        }
    });
    state = 'add';
    replyController.clear();
  }

  addReply() {
    repliesRef
      .document(commentId)
      .collection('replies')
      .document(replyId)
      .setData({
        'username': currentUser.username,
        'reply': replyController.text,
        'createdAt': DateTime.now(),
        'avatarUrl': currentUser.photoUrl,
        'userId': currentUser.id,
        'commentId': commentId,
        'replyId': replyId,
        'likes': {}
    });
    bool isNotCommentOwner = commentOwnerId != currentUser.id;
    if (isNotCommentOwner) {
      activityFeedRef
        .document(commentOwnerId)
        .collection('feedItems')
        .document(replyId)
        .setData({
          'type': 'reply',
          'data': comment,
          'timestamp': timestamp,
          'commentId': commentId,
          'userId': currentUser.id,
          'username': currentUser.username,
          'userProfileImg': currentUser.photoUrl
      });
    }
    setState(() { replyId = Uuid().v4(); });
    replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Replies'),
      body: Column(
        children: <Widget>[
          buildComment(),
          Expanded(child: buildReplies()),
          Divider(),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl)
            ),
            title: TextFormField(
              controller: replyController,
              decoration: InputDecoration(
                labelText: 'Post a reply...',
                border: InputBorder.none
              )
            ),
            trailing: OutlineButton(
              onPressed: () => state == 'add' ? addReply() : editReply(),
              borderSide: BorderSide.none,
              child: Icon(Icons.send, color: Theme.of(context).primaryColor)
            ),
          )
        ]
      )
    );
  }
}

class Reply extends StatefulWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String reply;
  final String originalReply;
  final Timestamp timestamp;
  final dynamic likes;
  final String status;
  final String commentId;
  final String replyId;

  Reply({
    this.username,
    this.userId,
    this.avatarUrl,
    this.reply,
    this.originalReply,
    this.timestamp,
    this.likes,
    this.status,
    this.commentId,
    this.replyId
  });

  factory Reply.fromDocument(DocumentSnapshot doc) {
    return Reply(
      username: doc['username'],
      userId: doc['userId'],
      originalReply: doc['originalReply'],
      reply: doc['reply'],
      timestamp: doc['createdAt'],
      avatarUrl: doc['avatarUrl'],
      likes: doc['likes'],
      status: doc['status'],
      commentId: doc['commentId'],
      replyId: doc['replyId']
    );
  }

  @override
  _ReplyState createState() => _ReplyState(
    username: this.username,
    userId: this.userId,
    avatarUrl: this.avatarUrl,
    reply: this.reply,
    originalReply: this.originalReply,
    timestamp: this.timestamp,
    commentId: this.commentId,
    replyId: this.replyId,
    likes: this.likes,
    status: this.status,
    likeCount: countTruishObject(this.likes)
  );
}

class _ReplyState extends State<Reply> {
  final String currentUserId = currentUser?.id;
  final String username;
  final String userId;
  final String avatarUrl;
  final String reply;
  final String originalReply;
  final String status;
  final Timestamp timestamp;
  final String commentId;
  final String replyId;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showOriginal = false;

  _ReplyState({
    this.username,
    this.userId,
    this.avatarUrl,
    this.reply,
    this.originalReply,
    this.timestamp,
    this.commentId,
    this.likes,
    this.status,
    this.replyId,
    this.likeCount
  });

  handleLikeReply({initIsLiked: false}) {
    if (initIsLiked) {
      setState(() { isLiked = likes[currentUserId] == true; });
    } else {
      bool _isLiked = likes[currentUserId] == true;
      if (_isLiked) {
        repliesRef
          .document(commentId)
          .collection('replies')
          .document(replyId)
          .updateData({'likes.$currentUserId': false});
        removeLikeReplyFromActivityFeed();
        setState(() {
          likeCount -= 1;
          isLiked = false;
          likes[currentUserId] = false;
        });
      } else if (!_isLiked) {
        repliesRef
          .document(commentId)
          .collection('replies')
          .document(replyId)
          .updateData({'likes.$currentUserId': true});
        addLikeReplyToActivityFeed();
        setState(() {
          likeCount += 1;
          isLiked = true;
          likes[currentUserId] = true;
        });
      }
    }
  }

  addLikeReplyToActivityFeed() {
    bool isNotReplyOwner = currentUserId != userId;
    if (isNotReplyOwner) {
      activityFeedRef
        .document(userId)
        .collection('feedItems')
        .document(commentId)
        .setData({
          'type': 'likeReply',
          'data': reply,
          'username': currentUser.username,
          'userId': currentUser.id,
          'userProfileImg': currentUser.photoUrl,
          'replyId': replyId,
          'timestamp': timestamp
        });
    }
  }

  removeLikeReplyFromActivityFeed() {
    bool isNotReplyOwner = currentUserId != userId;
    if (isNotReplyOwner) {
      activityFeedRef
        .document(userId)
        .collection('feedItems')
        .document(replyId)
        .get().then((doc) {
          if (doc.exists) doc.reference.delete();
        });
    }
  }

  toggleReply(showOriginal) {
    setState(() { this.showOriginal = !showOriginal; });
  }

  buildReplyContent() {
    if (isLiked == null) handleLikeReply(initIsLiked: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$username',
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis
            ),
            Padding(padding: EdgeInsets.only(bottom: 4.0)),
            Text(reply),
            Padding(padding: EdgeInsets.only(bottom: 8.0))
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              '${timeago.format(timestamp.toDate())}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey
              )
            ),
            Padding(padding: EdgeInsets.only(right: 10.0)),
            GestureDetector(
              onTap: handleLikeReply,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.pink
              )
            ),
            Padding(padding: EdgeInsets.only(right: 10.0)),
            Text(
              '$likeCount',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.0
              )
            )
          ],
        )
      ],
    );
  }

  buildReplyList() {
    List<CustomPopupMenu> choices = <CustomPopupMenu>[];
    choices = <CustomPopupMenu>[
      CustomPopupMenu(
        id: 'edit',
        title: 'Edit',
        icon: Icons.edit
      ),
      CustomPopupMenu(
        id: 'delete',
        title: 'Delete',
        icon: Icons.delete
      )
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(avatarUrl)
            )
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 2.0, 0.0),
              child: buildReplyContent()
            )
          ),
          currentUserId == userId ? popupMenu(
            tooltip: 'Reply Options',
            onSelect: handleReplyOption,
            choices: choices,
            context: context
          ) : Text('')
        ],
      )
    );
  }

  handleReplyOption(CustomPopupMenu choice) {
    if (choice.id == 'edit') handleEditReply();
    if (choice.id == 'delete') handleDeleteReply();
  }

  handleEditReply() {
    replyController.text = reply;
    state = 'edit';
    replyIdForEditing = replyId;
  }

  handleDeleteReply() async {
    repliesRef
      .document(commentId)
      .collection('replies')
      .document(replyId)
      .updateData({'isDeleted': true});

    QuerySnapshot activityFeedSnapshot = await activityFeedRef
      .document(currentUserId)
      .collection('feedItems')
      .where('replyId', isEqualTo: replyId)
      .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        activityFeedRef
          .document(currentUserId)
          .collection('feedItems')
          .document(replyId)
          .updateData({'isDeleted': true});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildReplyList(),
        Divider()
      ]
    );
  }
}