import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/models/group.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/widgets/custom_image.dart';

class CategoryGroups extends StatefulWidget {
  final String categoryName;
  final String categoryMedia;

  CategoryGroups({ this.categoryMedia, this.categoryName });

  @override
  State<StatefulWidget> createState() {
    return _CategoryGroupsState();
  }
}

class _CategoryGroupsState extends State<CategoryGroups> {
  bool loading = false;
  List<Group> categoryGroups;
  int groupLimit = 50;
  bool hasMore = true;
  DocumentSnapshot lastGroup;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCategoryGroups();
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      if (maxScroll == currentScroll) increaseCategoryGroups();
    });
  }

  getCategoryGroups() async {
    setState(() { loading = true; });
    List<Group> categoryGroups = [];
    QuerySnapshot snapshot = await groupsRef
      .where('isDeleted', isEqualTo: false)
      .where('visibility', isEqualTo: 'visible')
      .where('category', isEqualTo: widget.categoryName)
      .orderBy('membersCount', descending: true)
      .limit(groupLimit)
      .getDocuments();
    snapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      if (!group.members.contains(currentUser.id)) {
        categoryGroups.add(group);
        lastGroup = doc;
      }
    });
    if (categoryGroups.length < groupLimit) hasMore = false;
    setState(() {
      loading = false;
      this.categoryGroups = categoryGroups;
    });
  }

  increaseCategoryGroups() async {
    if (!hasMore) return;
    List<Group> categoryGroups;
    QuerySnapshot snapshot;
    if (lastGroup != null) {
      snapshot = await groupsRef
        .startAfterDocument(lastGroup)
        .where('isDeleted', isEqualTo: false)
        .where('visibility', isEqualTo: 'visible')
        .where('category', isEqualTo: widget.categoryName)
        .orderBy('membersCount', descending: true)
        .limit(groupLimit)
        .getDocuments();
    }
    snapshot.documents.forEach((doc) {
      Group group = Group.fromDocument(doc);
      if (!group.members.contains(currentUser.id)) {
        categoryGroups.add(group);
        lastGroup = doc;
      }
    });
    if (categoryGroups.length < groupLimit) hasMore = false;
    setState(() {
      categoryGroups.forEach((Group group) {
        this.categoryGroups.add(group);
      });
    });
  }

  joinGroup(groupId, members) {
    dynamic membersList = List.from(members);
    membersList.add(currentUser.id);
    groupsRef.document(groupId).updateData({ 'members': membersList });
    getCategoryGroups();
    // navigate to group's page
  }

  List<Widget> displayOtherGroups(List<Group> group) {
    List<Widget> widgetLists = [];
    if (group != null && group.isNotEmpty) {
      for (int i = 0; i < group.length; i++) {
        widgetLists.add(ListTile(
          contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
              group[i].coverPhoto.isNotEmpty
                  ? group[i].coverPhoto : 'https://i.imgur.com/Vsf8MAc.jpg'
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
        return widgetLists;
      }
    } else {
      widgetLists.add(Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 250,
        child: Center(
          child: Text(
            'No Group Found In this Category',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent
            )
          )
        )
      ));
      return widgetLists;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => getCategoryGroups(),
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            Stack(
              alignment: Alignment.bottomLeft,
              children: <Widget>[
                cachedNetworkImage(context, widget.categoryMedia),
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
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        widget.categoryName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold
                        )
                      )
                    )
                  )
                )
              ],
            ),
            Column(children: displayOtherGroups(categoryGroups))
          ]
        )
      )
    );
  }
}
