import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/models/group.dart';
import 'package:isocial/pages/groups/pin_groups.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_group.dart';

class UserGroups extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserGroupsState();
  }
}

class _UserGroupsState extends State<UserGroups> with
  AutomaticKeepAliveClientMixin<UserGroups> {
  SharedPreferences prefs;
  List<Group> pinnedGroups;
  List<Group> managedGroups;
  List<Group> otherGroups;
  int groupLimit = 50;
  bool hasMore = true;
  DocumentSnapshot lastGroup;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getPinnedGroups();
    getManagedGroups();
    getOtherGroups();
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      if (maxScroll == currentScroll) increaseOtherGroups();
    });
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

  getManagedGroups() async {
    List<Group> managedGroups = [];
    QuerySnapshot snapshot = await groupsRef
      .where('isDeleted', isEqualTo: false)
      .where('ownerId', isEqualTo: currentUser.id)
      .orderBy('membersCount', descending: true)
      .getDocuments();
    snapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      managedGroups.add(group);
    });
    setState(() {
      this.managedGroups = managedGroups;
    });
  }

  getOtherGroups() async {
    List<Group> otherGroups = [];
    QuerySnapshot snapshot = await groupsRef
      .where('isDeleted', isEqualTo: false)
      .where('members', arrayContains: currentUser.id)
      .orderBy('membersCount', descending: true)
      .limit(groupLimit)
      .getDocuments();
    snapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      if (group.ownerId != currentUser.id) otherGroups.add(group);
      lastGroup = doc;
    });
    if (otherGroups.length < groupLimit) hasMore = false;
    setState(() {
      this.otherGroups = otherGroups;
    });
  }

  increaseOtherGroups() async {
    if (!hasMore) return;
    List<Group> otherGroups;
    QuerySnapshot snapshot;
    if (lastGroup != null) {
      snapshot = await groupsRef
        .startAfterDocument(lastGroup)
        .where('isDeleted', isEqualTo: false)
        .where('members', arrayContains: currentUser.id)
        .orderBy('membersCount', descending: true)
        .limit(groupLimit)
        .getDocuments();
    }
    snapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      if (group.ownerId != currentUser.id) {
        otherGroups.add(group);
        lastGroup = doc;
      }
    });
    if (otherGroups.length < groupLimit) hasMore = false;
    setState(() {
      otherGroups.forEach((Group group) {
        this.otherGroups.add(group);
      });
    });
  }

  joinGroup(groupId, members) {
    dynamic membersList = List.from(members);
    membersList.add(currentUser.id);
    groupsRef.document(groupId).updateData({ 'members': membersList });
    getManagedGroups();
    getOtherGroups();
    // navigate to group's page
  }

  displayOtherGroups(List<Group> group) {
    List<Widget> widgetLists = [];
    if (group != null && group.isNotEmpty) {
      for (int i = 0; i <= group.length; i++) {
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
          subtitle: Text('${group[i].membersCount} members')
        ));
        return widgetLists;
      }
    } else {
      widgetLists.add(Container(
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
      ));
      return widgetLists;
    }
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: header(
        context,
        titleText: 'Your groups',
        addAction: true,
        action: Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => CreateGroup()
            )),
            icon: Icon(Icons.add)
          )
        )
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getManagedGroups();
          getOtherGroups();
        },
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: ListView(
            controller: scrollController,
            children: <Widget>[
              ListTile(
                leading: Text(
                  'Pinned groups',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  )
                ),
                trailing: FlatButton(
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0
                    )
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => PinGroups()
                    ));
                  },
                )
              ),
              Column(children: displayOtherGroups(pinnedGroups)),
              Divider(),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  'Groups you manage',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  )
                )
              ),
              Column(children: displayOtherGroups(managedGroups)),
              Divider(),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  'Other groups',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  )
                )
              ),
              Column(children: displayOtherGroups(otherGroups))
            ],
          )
        )
      )
    );
  }
}
