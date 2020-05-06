import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:isocial/helpers/questions.dart';

class QuizGame extends StatefulWidget {
  final String category;
  final String questionNum;

  QuizGame({ this.category, this.questionNum });

  @override
  State<StatefulWidget> createState() {
    return _QuizGameState();
  }
}

class _QuizGameState extends State<QuizGame> {
  int questionsTaken = 0;
  List<Questions> questions = [];
  int countDown = 10;
  int correctAnswers = 0;
  Timer timer;
  Map<int, Color> optionsColor = {
    0: Colors.transparent, 1: Colors.transparent,
    2: Colors.transparent, 3: Colors.transparent
  };
  bool isAnswered = false;
  AudioPlayer audioPlayer = new AudioPlayer();
  AudioCache audioCache = new AudioCache();
  AudioPlayer audioPlayer1 = new AudioPlayer();
  AudioPlayer audioPlayer2 = new AudioPlayer();
  File successAudioFile;
  File failureAudioFile;

  @override
  void initState() {
    super.initState();
    startBackgroundMusic();
    switch (widget.category) {
      case 'History':
        for (int i = 0; i < int.parse(widget.questionNum); i++) {
          questions.add(historyQuestions[i]);
        }
      break;
      case 'Celebrities':
        for (int i = 0; i < int.parse(widget.questionNum); i++) {
          questions.add(celebritiesQuestions[i]);
        }
      break;
      case 'Music':
        for (int i = 0; i < int.parse(widget.questionNum); i++) {
          questions.add(musicQuestions[i]);
        }
      break;
      case 'Politics':
        for (int i = 0; i < int.parse(widget.questionNum); i++) {
          questions.add(politicsQuestions[i]);
        }
      break;
      case 'Science':
        for (int i = 0; i < int.parse(widget.questionNum); i++) {
          questions.add(scienceQuestions[i]);
        }
      break;
      default: questions = historyQuestions; break;
    }
    setCountDownTimer();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    AudioPlayer.players.forEach((e, el) { el.stop(); });
  }

  startBackgroundMusic() async {
    File audioFile = await audioCache.load('music/bg_music.mp3');
    successAudioFile = await audioCache.load('music/success.mp3');
    failureAudioFile = await audioCache.load('music/failure.mp3');
    int result = await audioPlayer.play(audioFile.path, isLocal: true);
    if (result == 1) audioPlayer.setReleaseMode(ReleaseMode.LOOP);
  }

  setCountDownTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (timer.tick <= 10) {
        if (mounted) {
          setState(() { countDown -= 1; });
        }
      } else {
        audioPlayer.setVolume(0.7);
        File audioFile = await audioCache.load('music/wrong_answer.mp3');
        audioPlayer1.play(audioFile.path, isLocal: true);
        timer.cancel();
        setState(() {
          optionsColor[questions[questionsTaken].answer - 1] = Colors.green;
          isAnswered = true;
        });
      }
    });
  }

  displayOptionGridTiles() {
    List<GridTile> gridTiles = [];
    for (int i = 0; i < 4; i++) {
      gridTiles.add(GridTile(
        child: GestureDetector(
          onTap: !isAnswered ? () async {
            if (questions[questionsTaken].answer == i + 1) {
              audioPlayer.setVolume(0.7);
              File audioFile = await audioCache.load('music/right_answer.mp3');
              audioPlayer1.play(audioFile.path, isLocal: true);
              setState(() {
                optionsColor[i] = Colors.green;
                isAnswered = true;
                correctAnswers += 1;
              });
            } else {
              audioPlayer.setVolume(0.7);
              File audioFile = await audioCache.load('music/wrong_answer.mp3');
              audioPlayer1.play(audioFile.path, isLocal: true);
              setState(() {
                optionsColor[i] = Colors.red;
                optionsColor[questions[questionsTaken].answer - 1] = Colors.green;
                isAnswered = true;
              });
            }
          } : null,
          child: Container(
            width: (MediaQuery.of(context).size.width / 2),
            height: 50.0,
            decoration: BoxDecoration(
              color: Color.fromARGB(200, 61, 61, 61),
              border: Border.all(color: optionsColor[i], width: 4.0),
              borderRadius: BorderRadius.circular(4.0)
            ),
            margin: EdgeInsets.only(
              left: i == 0 || i == 2 ? 10.0 : 0.0,
              right: i == 1 || i == 3 ? 10.0 : 0.0
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  questions[questionsTaken].objectives[i],
                  style: TextStyle(color: Colors.white, fontSize: 20.0)
                )
              )
            )
          )
        )
      ));
    }
    return gridTiles;
  }

  Widget playMusicAndSetText() {
    audioPlayer.stop();
    if (correctAnswers.toDouble() > (questions.length / 2)) {
      audioPlayer2.play(successAudioFile.path, isLocal: true);
    } else { audioPlayer2.play(failureAudioFile.path, isLocal: true); }
    return Text(
      'Your Score: $correctAnswers/${questions.length}',
      style: TextStyle(color: Colors.white, fontSize: 30.0)
    );
  }

  Future<bool> handleQuitGame() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quit Game'),
          content: Text('Are you sure you want to quit the game?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () { Navigator.pop(context); },
            )
          ],
        );
      }
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleQuitGame,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/bg_stars.png')),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(200, 0, 3, 81),
                Color.fromARGB(200, 0, 0, 61),
                Color.fromARGB(200, 0, 0, 41),
                Color.fromARGB(200, 0, 0, 26),
                Color.fromARGB(200, 0, 0, 0),
              ]
            )
          ),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 0,
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, size: 30.0),
                          color: Colors.white,
                          onPressed: handleQuitGame
                        )
                      ),
                      Text(
                        widget.category,
                        style: TextStyle(color: Colors.white, fontSize: 15.0)
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Text(
                          '$correctAnswers/${questions.length}',
                          style: TextStyle(color: Colors.white, fontSize: 15.0)
                        )
                      )
                    ]
                  )
                )
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    questionsTaken > questions.length - 1 ? playMusicAndSetText()
                      : Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        questions[questionsTaken].question,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0
                        )
                      )
                    ),
                    Padding(padding: EdgeInsets.only(top: 10.0)),
                    questionsTaken > questions.length - 1 ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 0.0),
                          child: FlatButton.icon(
                            icon: Icon(Icons.replay),
                            label: Text(
                              'Restart Game',
                              style: TextStyle(color: Colors.white, fontSize: 15.0)
                            ),
                            color: Colors.green,
                            onPressed: () {
                              setState(() {
                                correctAnswers = 0;
                                questionsTaken = 0;
                                isAnswered = false;
                                optionsColor.updateAll((i, j) => Colors.transparent);
                                countDown = 10;
                                setCountDownTimer();
                              });
                            },
                          )
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: FlatButton.icon(
                            icon: Icon(Icons.power_settings_new),
                            label: Text(
                              'Quit Game',
                              style: TextStyle(color: Colors.white, fontSize: 15.0)
                            ),
                            color: Colors.red,
                            onPressed: handleQuitGame
                          )
                        )
                      ],
                    ) : GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: displayOptionGridTiles()
                    )
                  ],
                )
              ),
              questionsTaken > questions.length - 1 ? Text('') : Expanded(
                flex: 0,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: GestureDetector(
                      onTap: isAnswered ? () {
                        setState(() {
                          timer.cancel();
                          if (questionsTaken <= questions.length - 1) {
                            questionsTaken += 1;
                            isAnswered = false;
                            optionsColor.updateAll((i, j) => Colors.transparent);
                            countDown = 10;
                            setCountDownTimer();
                          }
                        });
                      } : null,
                      child: Text(
                        isAnswered
                            ? 'Tap here to Continue'
                            : countDown < 10 ? '0$countDown' : '$countDown',
                        style: TextStyle(color: Colors.white, fontSize: 20.0)
                      )
                    )
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}
