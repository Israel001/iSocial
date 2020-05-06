import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/helpers/custom_popup_menu.dart';
import 'package:isocial/pages/comments/replies/replies.dart';
import 'package:isocial/widgets/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import 'package:isocial/pages/home/home.dart';

import 'package:isocial/widgets/header.dart';
import 'package:isocial/widgets/progress.dart';
import 'package:isocial/widgets/popup_menu.dart';

TextEditingController commentController = TextEditingController();
String state = 'add';
String commentIdForEditing;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final dynamic postMediaUrl;

  Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl
  });

  @override
  CommentsState createState() => CommentsState(
    postId: this.postId,
    postOwnerId: this.postOwnerId,
    postMediaUrl: this.postMediaUrl
  );
}

class CommentsState extends State<Comments> {
  final String postId;
  final String postOwnerId;
  final dynamic postMediaUrl;
  String commentId = Uuid().v4();
  bool loading = false;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl
  });

  buildComments() {
    return StreamBuilder(
      stream: commentsRef.document(postId).collection('comments')
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc, false));
        });
        return ListView(children: comments);
      }
    );
  }

  editComment() {
    String comment = commentController.text;
    commentsRef
      .document(postId)
      .collection('comments')
      .document(commentIdForEditing)
      .updateData({
        'comment': comment,
        'updatedAt': DateTime.now()
      });
    state = 'add';
    setState(() {});
    commentController.clear();
  }

  addComment() {
    setState(() => loading = true);
    commentsRef
      .document(postId)
      .collection('comments')
      .document(commentId)
      .setData({
        'username': currentUser.username,
        'comment': commentController.text,
        'createdAt': DateTime.now(),
        'avatarUrl': currentUser.photoUrl,
        'userId': currentUser.id,
        'postId': postId,
        'commentId': commentId,
        'likes': {},
        'isDeleted': false
      });
    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (isNotPostOwner) {
      activityFeedRef
        .document(postOwnerId)
        .collection('feedItems')
        .document(commentId)
        .setData({
          'type': 'comment',
          'data': commentController.text,
          'timestamp': timestamp,
          'postId': postId,
          'postOwnerId': postOwnerId,
          'userId': currentUser.id,
          'username': currentUser.username,
          'userProfileImg': currentUser.photoUrl,
          'mediaUrl': postMediaUrl.isNotEmpty ? postMediaUrl[0] : '',
          'isDeleted': false
        });
    }
    setState(() {
      loading = false;
      commentId = Uuid().v4();
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
            ),
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Post a comment...',
                border: InputBorder.none
              )
            ),
            trailing: OutlineButton(
              onPressed: () => state == 'add' ? addComment() : editComment(),
              borderSide: BorderSide.none,
              child: loading
                  ? circularProgress(context)
                  : Icon(Icons.send, color: Theme.of(context).primaryColor)
            )
          )
        ],
      )
    );
  }
}

class Comment extends StatefulWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  final dynamic likes;
  final String status;
  final String postId;
  final String commentId;
  final bool hideReplyButton;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
    this.likes,
    this.status,
    this.postId,
    this.commentId,
    this.hideReplyButton
  });

  factory Comment.fromDocument(DocumentSnapshot doc, bool hideReplyButton) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['createdAt'],
      avatarUrl: doc['avatarUrl'],
      likes: doc['likes'],
      status: doc['status'],
      postId: doc['postId'],
      commentId: doc['commentId'],
      hideReplyButton: hideReplyButton,
    );
  }

  @override
  _CommentState createState() => _CommentState(
    username: this.username,
    userId: this.userId,
    avatarUrl: this.avatarUrl,
    comment: this.comment,
    timestamp: this.timestamp,
    postId: this.postId,
    commentId: this.commentId,
    likes: this.likes,
    status: this.status,
    likeCount: countTruishObject(this.likes),
    hideReplyButton: this.hideReplyButton
  );
}

class _CommentState extends State<Comment> {
  final String currentUserId = currentUser?.id;
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final String status;
  final Timestamp timestamp;
  final String postId;
  final String commentId;
  final bool hideReplyButton;
  int likeCount;
  Map likes;
  bool isLiked;

  _CommentState({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
    this.postId,
    this.commentId,
    this.likes,
    this.status,
    this.likeCount,
    this.hideReplyButton
  });

  handleLikeComment({initIsLiked: false}) {
    if (initIsLiked) {
      setState(() { isLiked = likes[currentUserId] == true; });
    } else {
      bool _isLiked = likes[currentUserId] == true;
      if (_isLiked) {
        commentsRef
          .document(postId)
          .collection('comments')
          .document(commentId)
          .updateData({'likes.$currentUserId': false});
        removeLikeCommentFromActivityFeed();
        setState(() {
          likeCount -= 1;
          isLiked = false;
          likes[currentUserId] = false;
        });
      } else if (!_isLiked) {
        commentsRef
          .document(postId)
          .collection('comments')
          .document(commentId)
          .updateData({'likes.$currentUserId': true});
        addLikeCommentToActivityFeed();
        setState(() {
          likeCount += 1;
          isLiked = true;
          likes[currentUserId] = true;
        });
      }
    }
  }

  addLikeCommentToActivityFeed() {
    bool isNotCommentOwner = currentUserId != userId;
    if (isNotCommentOwner) {
      activityFeedRef
        .document(userId)
        .collection('feedItems')
        .document(commentId)
        .setData({
          'type': 'likeComment',
          'data': comment,
          'username': currentUser.username,
          'userId': currentUser.id,
          'userProfileImg': currentUser.photoUrl,
          'commentId': commentId,
          'timestamp': timestamp
        });
    }
  }

  removeLikeCommentFromActivityFeed() {
    bool isNotCommentOwner = currentUserId != userId;
    if (isNotCommentOwner) {
      activityFeedRef
        .document(userId)
        .collection('feedItems')
        .document(commentId)
        .get().then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });
    }
  }

  buildCommentContent() {
    if (isLiked == null) handleLikeComment(initIsLiked: true);
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
              overflow: TextOverflow.ellipsis,
            ),
            Padding(padding: EdgeInsets.only(bottom: 4.0)),
            Text(comment),
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
              onTap: handleLikeComment,
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
            ),
            Padding(padding: EdgeInsets.only(right: 10.0)),
            hideReplyButton ? Text('') : GestureDetector(
              onTap: () => showReplies(
                context,
                commentId: commentId,
                ownerId: userId,
                comment: comment,
                postId: postId
              ),
              child: Text(
                'Reply',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0
                )
              )
            )
          ],
        )
      ],
    );
  }

  buildCommentList() {
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
              backgroundImage: CachedNetworkImageProvider(avatarUrl),
            )
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 2.0, 0.0),
              child: buildCommentContent()
            )
          ),
          currentUserId == userId ? popupMenu(
            tooltip: 'Comment Options',
            onSelect: handleCommentOption,
            choices: choices,
            context: context
          ) : Text('')
        ],
      )
    );
  }

  handleCommentOption(CustomPopupMenu choice) {
    if (choice.id == 'edit') handleEditComment();
    if (choice.id == 'delete') handleDeleteComment();
  }

  handleEditComment() {
    commentController.text = comment;
    state = 'edit';
    commentIdForEditing = commentId;
  }

  handleDeleteComment() async {
    commentsRef
      .document(postId)
      .collection('comments')
      .document(commentId)
      .updateData({'isDeleted': true});

    activityFeedRef
      .document(currentUserId)
      .collection('feedItems')
      .document(commentId)
      .get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

    QuerySnapshot repliesSnapshot = await repliesRef
      .document(commentId)
      .collection('replies')
      .getDocuments();
    repliesSnapshot.documents.forEach((doc) async {
      if (doc.exists) {
        final String replyId = doc.data['replyId'];
        final String replyOwnerId = doc.data['userId'];

        repliesRef
          .document(commentId)
          .collection('replies')
          .document(replyId)
          .updateData({'isDeleted': true});

        activityFeedRef
          .document(replyOwnerId)
          .collection('feedItems')
          .document(replyId)
          .get().then((doc) {
            if (doc.exists) {
              doc.reference.delete();
            }
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildCommentList(),
        Divider()
      ],
    );
  }
}

showReplies (BuildContext context, { String commentId, String ownerId,
  String comment, String postId }) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) {
      return Replies(
        commentId: commentId,
        commentOwnerId: ownerId,
        comment: comment,
        postId: postId
      );
    })
  );
}
