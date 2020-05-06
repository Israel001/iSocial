import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/models/group.dart';
import 'package:isocial/pages/groups/user_groups.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_group.dart';
import 'discover.dart';

class Groups extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GroupsState();
  }
}

class _GroupsState extends State<Groups> with
  AutomaticKeepAliveClientMixin<Groups> {
  SharedPreferences prefs;
  List<Group> pinnedGroups;
  List<String> imgUrls = [];
  List<String> imgTitles = [];

  @override
  void initState() {
    super.initState();
    getPinnedGroups();
  }

  getPinnedGroups() async {
    prefs = await SharedPreferences.getInstance();
    List<String> pinnedGroupIds = prefs.getStringList('pinnedGroups') ?? [];
    List<Group> pinnedGroups = [];
    imgUrls = []; imgTitles = [];
    for (String groupId in pinnedGroupIds) {
      QuerySnapshot snapshot = await groupsRef
        .where('isDeleted', isEqualTo: false)
        .where('groupId', isEqualTo: groupId)
        .orderBy('membersCount', descending: true)
        .getDocuments();
      snapshot.documents.forEach((doc) {
        Group group = Group.fromDocument(doc);
        pinnedGroups.add(group);
      });
    }
    for (var group in pinnedGroups) {
      if (group.coverPhoto.isNotEmpty) {
        imgUrls.add(group.coverPhoto);
      } else {
        imgUrls.add('https://i.imgur.com/Vsf8MAc.jpg');
      }
      imgTitles.add(group.name);
    }
    setState(() {
      this.pinnedGroups = pinnedGroups;
    });
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  imgList() {
    return map<Widget>(
      imgUrls,
      (index, i) {
        return Container(
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () {},
                  child: CachedNetworkImage(
                    imageUrl: i, fit: BoxFit.cover, width: 1000.0
                  )
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
                      imgTitles[index],
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
    ).toList();
  }

  Widget groupButton(IconData icon, String label, Function onPressed) {
    return RaisedButton(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: Row(
        children: <Widget>[
          Icon(icon),
          Padding(padding: EdgeInsets.only(right: 5.0)),
          Text(label)
        ]
      ),
      color: Theme.of(context).accentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      onPressed: onPressed,
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: header(context, titleText: 'Groups'),
      body: RefreshIndicator(
        onRefresh: () async => getPinnedGroups(),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                'Groups',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold
                )
              ),
              trailing: IconButton(
                icon: Icon(Icons.search, size: 30.0),
                onPressed: () {},
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: groupButton(
                    Icons.add_circle,
                    'Create',
                    () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => CreateGroup()
                      ));
                    }
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: groupButton(
                    Icons.explore,
                    'Discover',
                    () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Discover()
                      ));
                    }
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: groupButton(
                    Icons.group,
                    'Your groups',
                    () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => UserGroups()
                      ));
                    }
                  )
                ),
              ]
            ),
            imgUrls.length > 0 ? CarouselSlider(
              items: imgList(),
              autoPlay: false,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              viewportFraction: 0.9,
              aspectRatio: 2.0
            ) : Text('')
          ],
        )
      )
    );
  }
}
