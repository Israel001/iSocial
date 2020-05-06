import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/models/group.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isocial/widgets/header.dart';

class PinGroups extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PinGroupsState();
  }
}

class _PinGroupsState extends State<PinGroups> with
  AutomaticKeepAliveClientMixin<PinGroups> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  List<Group> pinnedGroups;
  List<Group> unPinnedGroups;

  @override
  void initState() {
    super.initState();
    getPinnedGroups();
    getUnPinnedGroups();
  }

  getPinnedGroups() async {
    prefs = await SharedPreferences.getInstance();
    List<String> pinnedGroupIds = prefs.getStringList('pinnedGroups') ?? [];
    List<Group> pinnedGroups = [];
    pinnedGroupIds.forEach((groupId) async {
      QuerySnapshot snapshot = await groupsRef
        .where('isDeleted', isEqualTo: false)
        .where('groupId', isEqualTo: groupId)
        .orderBy('membersCount', descending: true)
        .getDocuments();
      snapshot.documents.forEach((doc) {
        Group group = Group.fromDocument(doc);
        pinnedGroups.add(group);
      });
    });
    setState(() => this.pinnedGroups = pinnedGroups);
  }

  getUnPinnedGroups() async {
    prefs = await SharedPreferences.getInstance();
    List<String> pinnedGroupIds = prefs.getStringList('pinnedGroups') ?? [];
    List<Group> unPinnedGroups = [];
    QuerySnapshot snapshot = await groupsRef
      .where('isDeleted', isEqualTo: false)
      .where('members', arrayContains: currentUser.id)
      .orderBy('membersCount', descending: true)
      .getDocuments();
    snapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      if (!pinnedGroupIds.contains(group.groupId)) unPinnedGroups.add(group);
    });
    setState(() => this.unPinnedGroups = unPinnedGroups);
  }

  pinGroup(String groupId) {
    List<String> pinnedGroupIds = [];
    if (pinnedGroups.length < 10) {
      pinnedGroups.forEach((group) => pinnedGroupIds.add(group.groupId));
      pinnedGroupIds.add(groupId);
      prefs.setStringList('pinnedGroups', pinnedGroupIds);
    } else {
      SnackBar snackBar = snackbar(
        msg: 'Only 10 pinned groups are allowed',
        bgColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 5000)
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
    getPinnedGroups();
    getUnPinnedGroups();
  }

  unPinGroup(String groupId) {
    List<String> pinnedGroupIds = [];
    pinnedGroups.forEach((group) => pinnedGroupIds.add(group.groupId));
    pinnedGroupIds.removeWhere((group) => group == groupId);
    prefs.setStringList('pinnedGroups', pinnedGroupIds);
    getPinnedGroups();
    getUnPinnedGroups();
  }

  Widget displayGroups(List<Group> group, bool pin) {
    if (group != null && group.isNotEmpty) {
      for (int i = 0; i <= group.length; i++) {
        return ListTile(
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
          trailing: IconButton(
            icon: pin ? Icon(Icons.colorize) : Icon(
              Icons.delete, color: Theme.of(context).accentColor
            ),
            onPressed: () {
              if (pin) {
                pinGroup(group[i].groupId);
              } else {
                unPinGroup(group[i].groupId);
              }
            },
          ),
        );
      }
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              'No Group Found',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent
              )
            )
          )
        )
      );
    }
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, titleText: 'Pin groups'),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: () async {
            getPinnedGroups();
            getUnPinnedGroups();
          },
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  'Pinned groups',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  )
                )
              ),
              displayGroups(pinnedGroups, false),
              Divider(),
              Padding(
                padding: EdgeInsets.only(left: 10.0, top: 10.0),
                child: Text(
                  'Unpinned groups',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  )
                )
              ),
              displayGroups(unPinnedGroups, true)
            ]
          )
        )
      )
    );
  }
}
