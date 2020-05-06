import 'package:flutter/material.dart';
import 'package:isocial/widgets/progress.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoType;
  final dynamic video;
  
  VideoPlayerWidget({ this.videoType, this.video });
  
  @override
  State<StatefulWidget> createState() {
    return VideoPlayerWidgetState(
      videoType: videoType,
      video: video
    );
  }
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController videoPlayerController;
  Future<void> initializeVideoPlayerFuture;
  final String videoType;
  final dynamic video;
  double videoDuration = 0;
  double currentDuration = 0;
  Duration durationLeft = Duration(hours: 0, minutes: 0, seconds: 0);

  VideoPlayerWidgetState({ this.videoType, this.video });

  @override
  void initState() {
    super.initState();
    if (videoType == 'file') {
      videoPlayerController = VideoPlayerController.file(video);
    } else if (videoType == 'network') {
      videoPlayerController = VideoPlayerController.network(video);
    }
    initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      setState(() {
        videoDuration =
            videoPlayerController.value.duration.inMilliseconds.toDouble();
      });
    });
    videoPlayerController.addListener(() {
      setState(() {
        currentDuration =
            videoPlayerController.value.position.inMilliseconds.toDouble();
        durationLeft =
            videoPlayerController.value.duration -
                videoPlayerController.value.position;
      });
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return circularProgress(context);
        }
        return Container(
          color: Colors.black,
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  videoPlayerController.value.initialized
                    ? AspectRatio(
                      aspectRatio: videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(videoPlayerController)
                  ) : circularProgress(context),
                  !videoPlayerController.value.isPlaying
                      ? FloatingActionButton(
                    elevation: 0,
                    child: Container(
                      constraints: BoxConstraints.expand(),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                      ),
                      child: Icon(Icons.play_arrow)
                    ),
                    onPressed: () {
                      setState(() {
                        videoPlayerController.value.isPlaying
                            ? videoPlayerController.pause()
                            : videoPlayerController.play();
                      });
                    },
                  ) : Text('')
                ]
              ),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: videoPlayerController.value.isPlaying
                      ? Icon(Icons.pause)
                      : Icon(Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        videoPlayerController.value.isPlaying
                          ? videoPlayerController.pause()
                          : videoPlayerController.play();
                      });
                    },
                    color: Colors.white
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    child: Slider(
                      value: currentDuration,
                      max: videoDuration,
                      onChanged: (value) =>
                        videoPlayerController
                          .seekTo(
                          Duration(milliseconds: value.toInt())),
                      activeColor: Colors.white,
                      inactiveColor: Colors.deepPurple,
                    )
                  ),
                  Padding(padding: EdgeInsets.only(left: 20.0)),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                      children: [
                        TextSpan(
                          text: durationLeft.inHours > 0
                            ? '${durationLeft.inHours} : '
                            : ''
                        ),
                        TextSpan(text: '${durationLeft.inMinutes} : '),
                        TextSpan(
                          text: durationLeft.inSeconds < 10
                            ? '0${durationLeft.inSeconds}'
                            : '${durationLeft.inSeconds}'
                        )
                      ]
                    )
                  )
                ]
              )
            ]
          )
        );
      }
    );
  }
}
