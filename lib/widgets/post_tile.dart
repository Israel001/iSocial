import 'package:flutter/material.dart';

import 'package:isocial/pages/post_screen.dart';

import 'package:isocial/widgets/custom_image.dart';
import 'package:isocial/widgets/post.dart';
import 'package:isocial/widgets/progress.dart';
import 'package:video_player/video_player.dart';

class PostTile extends StatefulWidget {
  final Post post;

  PostTile(this.post);

  @override
  PostTileState createState() => PostTileState();
}

class PostTileState extends State<PostTile> {
  VideoPlayerController videoPlayerController;
  Future<void> initializeVideoPlayerFuture;

  @override
  void initState() {
    if (widget.post.mediaUrl.length > 0) {
      if (widget.post.mediaUrl[0].runtimeType == String) {
        videoPlayerController = VideoPlayerController.network(
          widget.post.mediaUrl[0]
        );
      } else {
        videoPlayerController = VideoPlayerController.file(
          widget.post.mediaUrl[0]
        );
      }
      initializeVideoPlayerFuture = videoPlayerController.initialize();
    }
    super.initState();
  }

  showVideo() {
    return FutureBuilder(
      future: initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VideoPlayer(videoPlayerController);
        }
        return Center(child: circularProgress());
      },
    );
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: widget.post.postId,
          userId: widget.post.ownerId
        )
      )
    );
  }

  buildChild() {
    if (widget.post.mediaUrl[0].runtimeType == String) {
      if (widget.post.mediaUrl[0].contains('mp4')) {
        return showVideo();
      } else {
        return cachedNetworkImage(context, widget.post.mediaUrl[0]);
      }
    } else {
      return showVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.post.mediaUrl.length > 0 ? GestureDetector(
      onTap: () => showPost(context),
      child: buildChild()
    ) : Text('');
  }
}