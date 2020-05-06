import 'package:flutter/material.dart';
import 'package:isocial/pages/quiz/quiz_game.dart';
import 'package:isocial/widgets/header.dart';

class Quiz extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuizState();
  }
}

class _QuizState extends State<Quiz> {
  List catNames = ['History', 'Celebrities', 'Music', 'Politics', 'Science'];
  List catImages = [
    'assets/images/history.jpg',
    'assets/images/celebrities.png',
    'assets/images/music.png',
    'assets/images/politics.jpg',
    'assets/images/science.png'
  ];

  displayQuizCategories() {
    List<GridTile> gridTiles = [];
    for (int i = 0; i < catNames.length; i++) {
      gridTiles.add(
        GridTile(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String questionNum = '5';
                      return AlertDialog(
                        title: Text('Choose Number of Questions'),
                        content: StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return DropdownButton<String>(
                              hint: Text('Choose number of questions'),
                              value: questionNum,
                              items: <String>['5', '10', '15', '20', '25', '30',
                                '35', '40', '45', '50'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value)
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() { questionNum = value; });
                              }
                            );
                          }
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Done'),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => QuizGame(
                                  category: catNames[i],
                                  questionNum: questionNum
                                )
                              ));
                            }
                          )
                        ]
                      );
                    }
                  );
                },
                child: Image.asset(catImages[i], fit: BoxFit.cover)
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter
                    )
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0
                  ),
                  child: Text(
                    catNames[i],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    )
                  )
                )
              )
            ]
          )
        )
      );
    }
    return gridTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Welcome To Quiz Center'),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Choose a Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)
            )
          ),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: displayQuizCategories()
          )
        ],
      )
    );
  }
}
