import 'package:flutter/material.dart';
import 'package:isocial/helpers/activities.dart';
import 'package:isocial/helpers/feelings.dart';
import 'package:isocial/widgets/sub_activities.dart';

class FeelingsOrActivities extends StatefulWidget {
  final Map<String, String> selectedFeelingOrActivity;

  FeelingsOrActivities({this.selectedFeelingOrActivity});

  @override
  State<StatefulWidget> createState() {
    return FeelingsOrActivitiesState(
      selectedFeelingOrActivity: selectedFeelingOrActivity
    );
  }
}

class FeelingsOrActivitiesState extends State<FeelingsOrActivities> with
  SingleTickerProviderStateMixin {
  TextEditingController searchController = new TextEditingController();
  TextEditingController activityController = new TextEditingController();
  TabController tabController;
  Map<String, String> selectedFeelingOrActivity;
  String feelingOrActivity;
  String pageState = 'feelings';
  Map<String, String> returnValue;
  List<Feelings> _feelings = feelings;
  List<Activities> _activities = activities;

  FeelingsOrActivitiesState({this.selectedFeelingOrActivity});

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
    tabController.addListener(onTabChange);
    if (selectedFeelingOrActivity != null) {
      returnValue = selectedFeelingOrActivity;
      if (selectedFeelingOrActivity['feelings'] != null) {
        feelingOrActivity = 'Feeling ${selectedFeelingOrActivity['feelings']}';
        searchController.text = feelingOrActivity;
      } else if (selectedFeelingOrActivity['activities'] != null) {
        feelingOrActivity = '${selectedFeelingOrActivity['activities']}';
        searchController.text = feelingOrActivity;
      }
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  onTabChange() {
    setState(() {
      pageState = tabController.index == 0 ? 'feelings' : 'activities';
    });
  }

  clearSearch() {
    searchController.clear();
    setState(() { _feelings = feelings; });
  }

  closeAndReturnValue(feelingOrActivity, type) {
    returnValue = { type: feelingOrActivity };
    Navigator.pop(context, returnValue);
  }

  buildGridTiles(arr, onTap) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 3.0,
      children: List.generate(arr.length, (index) {
        return GestureDetector(
          onTap: () => onTap(
            pageState == 'feelings' ? arr[index].title : arr[index].title,
            pageState == 'feelings' ? 'feelings' : 'activities'
          ),
          child: Center(
            child: GridTile(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.3
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(arr[index].title)
                    ],
                  )
                )
              )
            )
          )
        );
      })
    );
  }

  chooseActivity(String activityId, String type) async {
    List<Activities> subActivities;
    String prefix;
    switch(activityId.toLowerCase()) {
      case 'celebrating...':
        subActivities = celebrating;
        prefix = 'Celebrating';
      break;
      case 'attending...':
        subActivities = attending;
        prefix = 'Attending';
      break;
      case 'looking for...':
        subActivities = looking;
        prefix = 'Looking for';
      break;
      case 'thinking about...':
        subActivities = thinking;
        prefix = 'Thinking about';
      break;
      case 'watching...': prefix = 'Watching'; break;
      case 'drinking...': prefix = 'Drinking'; break;
      case 'eating...': prefix = 'Eating'; break;
      case 'travelling to...': prefix = 'Travelling to'; break;
      case 'listening to...': prefix = 'Listening to'; break;
      case 'reading...': prefix = 'Reading'; break;
      case 'playing...': prefix = 'Playing'; break;
      case 'supporting...': prefix = 'Supporting'; break;
    }
    if (subActivities != null) {
      final String chosenActivity = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubActivities(
            type: activityId,
            subActivities: subActivities
          )
        )
      );
      if (chosenActivity.isNotEmpty) {
        returnValue = { type: '$prefix $chosenActivity'};
        Navigator.pop(context, returnValue);
      }
    } else {
      final String enteredActivity = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(activityId),
            content: TextFormField(
              decoration: InputDecoration(
                hintText: activityId,
                filled: true
              ),
              controller: activityController
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold
                  )
                ),
                onPressed: () => Navigator.pop(context, activityController.text),
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context, ''),
              )
            ],
          );
        }
      );
      if (enteredActivity.isNotEmpty) {
        returnValue = { type: '$prefix $enteredActivity'};
        Navigator.pop(context, returnValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, returnValue);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            pageState == 'feelings'
                ? 'How are you feeling?'
                : 'What are you doing?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0
            )
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context, returnValue),
              icon: Icon(
                Icons.close,
                size: 30.0,
                color: Colors.white
              )
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            TabBar(
              tabs: <Widget>[
                Tab(
                  child: Text(
                    'FEELINGS',
                    style: TextStyle(
                      color: Theme.of(context).cardColor
                    )
                  )
                ),
                Tab(
                  child: Text(
                    'ACTIVITIES',
                    style: TextStyle(
                      color: Theme.of(context).cardColor
                    )
                  )
                )
              ],
              indicatorColor: Theme.of(context).cardColor,
              controller: tabController,
            ),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: clearSearch,
                ),
                border: InputBorder.none,
                filled: true
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: <Widget>[
                  buildGridTiles(_feelings, closeAndReturnValue),
                  buildGridTiles(_activities, chooseActivity)
                ],
              )
            )
          ],
        )
      )
    );
  }
}