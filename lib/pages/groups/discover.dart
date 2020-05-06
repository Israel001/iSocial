import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/helpers/categories.dart';
import 'package:isocial/models/group.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/widgets/custom_image.dart';
import 'package:isocial/widgets/header.dart';

import 'category_groups.dart';
import 'group_page.dart';

class Discover extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DiscoverState();
  }
}

class _DiscoverState extends State<Discover> with
  AutomaticKeepAliveClientMixin<Discover> {
  List<Group> suggestedGroups;
  List<Group> friendsGroups;
  List<Group> closeGroups;
  List<Group> moreSuggestions = [];
  int groupLimit = 5;
  bool hasMore = true;
  DocumentSnapshot lastGroup;
  ScrollController scrollController = ScrollController();

  static List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    getSuggestedGroups();
    getFriendsGroups();
    getCloseGroups();
    getMoreSuggestions();
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      if (maxScroll == currentScroll) increaseGroupSuggestions();
    });
  }

  getSuggestedGroups() async {
    List<Group> suggestedGroups = [];
    QuerySnapshot snapshot = await groupsRef
      .where('isDeleted', isEqualTo: false)
      .where('visibility', isEqualTo: 'visible')
      .orderBy('membersCount', descending: true)
      .limit(5).getDocuments();
    snapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      if (group != null) {
        group.members.forEach((index, member) {
          if (member['id'] != currentUser.id) suggestedGroups.add(group);
        });
      }
    });
    setState((){
      this.suggestedGroups = suggestedGroups;
    });
  }

  getFriendsGroups() async {
    List<String> followingIds = [];
    List<Group> friendsGroups = [];
    QuerySnapshot snapshot = await followingRef
      .document(currentUser.id)
      .collection('userFollowing')
      .getDocuments();
    snapshot.documents.forEach((doc) => followingIds.add(doc.documentID));
    QuerySnapshot groupSnapshot = await groupsRef
      .where('isDeleted', isEqualTo: false)
      .where('visibility', isEqualTo: 'visible')
      .orderBy('membersCount', descending: true)
      .limit(5)
      .getDocuments();
    groupSnapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      if (group != null) {
        group.members.forEach((index, member) {
          if (member['id'] != currentUser.id && followingIds.contains(member['id'])) {
            friendsGroups.add(group);
          }
        });
      }
    });
    setState((){
      this.friendsGroups = friendsGroups;
    });
  }

  getCloseGroups() async {
    List<Group> closeGroups = [];
    QuerySnapshot snapshot = await groupsRef
      .where('isDeleted', isEqualTo: false)
      .where('visibility', isEqualTo: 'visible')
      .where('location', isEqualTo: currentUserLocation)
      .limit(5).getDocuments();
    snapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      if (group != null) {
        group.members.forEach((index, member) {
          if (member['id'] != currentUser.id) closeGroups.add(group);
        });
      }
    });
    setState(() {
      this.closeGroups = closeGroups;
    });
  }

  getMoreSuggestions() async {
    List<Group> moreSuggestions = [];
    QuerySnapshot snapshot = await groupsRef
      .where('isDeleted', isEqualTo: false)
      .where('visibility', isEqualTo: 'visible')
      .orderBy('membersCount', descending: true)
      .limit(groupLimit)
      .getDocuments();
    bool isInThisGroup = false;
    snapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      if (group != null) {
        for (int i = 0; i < group.members.length; i++) {
          if (group.members[i]['id'] == currentUser.id) isInThisGroup = true;
        }
        if (isInThisGroup) {
          moreSuggestions.add(group);
          lastGroup = doc;
        }
      }
    });
    if (moreSuggestions.length < groupLimit) hasMore = false;
    setState(() {
      this.moreSuggestions = moreSuggestions;
    });
  }

  increaseGroupSuggestions() async {
    if (!hasMore) return;
    List<Group> moreSuggestions;
    QuerySnapshot snapshot;
    if (lastGroup != null) {
      snapshot = await groupsRef
        .startAfterDocument(lastGroup)
        .where('isDeleted', isEqualTo: false)
        .where('visibility', isEqualTo: 'visible')
        .orderBy('membersCount', descending: true)
        .limit(groupLimit)
        .getDocuments();
    }
    snapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      if (group != null) {
        group.members.forEach((index, member) {
          if (member['id'] != currentUser.id) {
            moreSuggestions.add(group);
            lastGroup = doc;
          }
        });
      }
    });
    if (moreSuggestions.length < groupLimit) hasMore = false;
    setState(() {
      moreSuggestions.forEach((Group group) {
        this.moreSuggestions.add(group);
      });
    });
  }

  imgList() {
    return map<Widget>(
      categoryImgUrls,
      (index, i) {
        return Container(
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CategoryGroups(
                        categoryName: categoryTitles[index],
                        categoryMedia: i,
                      )
                    ));
                  },
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
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Text(
                      categoryTitles[index],
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

  Widget displayTopGroup(List<Group> group) {
    if (group != null && group.isNotEmpty) {
      return RaisedButton(
        elevation: 8.0,
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
        ),
        color: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: '/group_page'),
              builder: (context) => GroupPage(groupId: group[0].groupId)
            )
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 350,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0)
                  ),
                  child: group[0].coverPhoto.isNotEmpty
                    ? cachedNetworkImage(
                      context,
                      group[0].coverPhoto
                    ) : Image.asset('assets/images/groups_default.jpg', width: 350)
                )
              ),
              ListTile(
                contentPadding: EdgeInsets.only(left: 20.0),
                title: Text(
                  group[0].name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  )
                ),
                subtitle: Text('${group[0].membersCount} members')
              ),
              SizedBox(
                width: 290,
                child: RaisedButton(
                  child: Text('Join Group'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  color: Theme.of(context).accentColor,
                  onPressed: () => joinGroup(group[0].groupId, group[0].members),
                )
              ),
              Padding(padding: EdgeInsets.only(bottom: 15.0))
            ]
          )
        )
      );
    } else {
      return Text(
        'No Group Found',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: Colors.redAccent
        )
      );
    }
  }

  List<Widget> displayOtherGroups(List<Group> group, { bool skip = true }) {
    List<Widget> widgetLists = [];
    int startIndex = skip ? 1 : 0;
    if (group != null && group.isNotEmpty && group.length > 1) {
      for (int i = startIndex; i < group.length; i++) {
        widgetLists.add(ListTile(
          contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          leading: group[i].coverPhoto.isNotEmpty ? CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(group[i].coverPhoto)
          ) : CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              'https://i.imgur.com/Vsf8MAc.jpg'
            )
          ),
          title: Text(
            group[i].name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0
            )
          ),
          subtitle: Text('${group[i].membersCount} members'),
          trailing: RaisedButton(
            child: Text('Join'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            color: Theme.of(context).accentColor,
            onPressed: () => joinGroup(group[i].groupId, group[i].members),
          ),
        ));
      }
      return widgetLists;
    } else {
      if (skip) widgetLists.add(Text(''));
      widgetLists.add(Text(
        'No Suggestions',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: Colors.redAccent
        )
      ));
      return widgetLists;
    }
  }

  joinGroup(groupId, members) {
    dynamic membersList = List.from(members);
    membersList.add({
      'id': currentUser.id,
      'role': 'member',
      'joinDate': DateTime.now()
    });
    groupsRef.document(groupId).updateData({
      'members': membersList ,
      'membersCount': membersList.length
    });
    refreshState();
    // navigate to group's page
  }

  refreshState() {
    getSuggestedGroups();
    getFriendsGroups();
    getCloseGroups();
    getMoreSuggestions();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: header(
        context,
        titleText: 'Discover',
        addAction: true,
        action: Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Icon(Icons.search)
        )
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshState(),
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      'Suggested for you',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0
                      )
                    ),
                    subtitle: Text('Groups you might be interested in'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    child: displayTopGroup(suggestedGroups)
                  ),
                  Padding(padding: EdgeInsets.only(top: 10.0)),
                  Column(children: displayOtherGroups(suggestedGroups)),
                  Divider(),
                  ListTile(
                    title: Text(
                      'Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0
                      )
                    ),
                    subtitle: Text('Find a group by browsing top categories'),
                  ),
                  CarouselSlider(
                    items: imgList(),
                    autoPlay: false,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    aspectRatio: 2.0
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "Friends' groups",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0
                      )
                    ),
                    subtitle: Text('Groups that your friends are in')
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    child: displayTopGroup(friendsGroups)
                  ),
                  Padding(padding: EdgeInsets.only(top: 10.0)),
                  Column(children: displayOtherGroups(friendsGroups)),
                  Divider(),
                  ListTile(
                    title: Text(
                      'Popular near you',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0
                      )
                    ),
                    subtitle: Text('Groups that people in your area are in')
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    child: displayTopGroup(closeGroups)
                  ),
                  Padding(padding: EdgeInsets.only(top: 10.0)),
                  Column(children: displayOtherGroups(closeGroups)),
                  Divider(),
                  ListTile(
                    title: Text(
                      'More suggestions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0
                      )
                    )
                  ),
                  Column(children: displayOtherGroups(moreSuggestions, skip: false))
                ]
              )
            )
          ]
        )
      )
    );
  }
}
