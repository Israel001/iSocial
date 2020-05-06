import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/helpers/custom_popup_menu.dart';
import 'package:isocial/models/group.dart';
import 'package:isocial/models/user.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/widgets/custom_image.dart';
import 'package:isocial/widgets/popup_menu.dart';
import 'package:timeago/timeago.dart' as timeago;

class Members extends StatefulWidget {
  final Group group;

  Members({ this.group });

  @override
  State<StatefulWidget> createState() {
    return _MembersState();
  }
}

class _MembersState extends State<Members> with SingleTickerProviderStateMixin {
  TextEditingController searchController = new TextEditingController();
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void handleMemberOption(CustomPopupMenu choice) {
    if (choice.id == 'removeAdmin') {}
    if (choice.id == 'changeAdmin') {}
    if (choice.id == 'removeMod') {}
    if (choice.id == 'changeMod') {}
    if (choice.id == 'viewProfile') {}
  }

  displayUsers({String type}) async {
    List<Widget> widgetLists = [];
    for (int i = 0; i < widget.group.members.length; i++) {
      String userId;
      if (type == 'admin' && widget.group.members[i]['role'] == 'admin') {
        userId = widget.group.members[i]['id'];
      } else if (type != 'admin') {
        userId = widget.group.members[i]['id'];
      }
      DocumentSnapshot doc = await usersRef.document(userId).get();
      User user = User.fromDocument(doc);
      List<CustomPopupMenu> choices = <CustomPopupMenu>[];
      choices = <CustomPopupMenu>[
        CustomPopupMenu(
          id: widget.group.members[i]['role'] == 'admin'
              ? 'removeAdmin' : 'changeAdmin',
          title: widget.group.members[i]['role'] == 'admin'
              ? 'Remove Admin' : 'Change to Admin'
        ),
        CustomPopupMenu(
          id: widget.group.members[i]['role'] == 'admin'
              ? 'removeMod' : 'changeMod',
          title: widget.group.members[i]['role'] == 'admin'
              ? 'Remove Moderator' : 'Change to Moderator'
        ),
        CustomPopupMenu(
          id: 'viewProfile',
          title: 'View Profile'
        )
      ];
      widgetLists.add(ListTile(
        leading: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 44,
            minHeight: 44,
            maxWidth: 64,
            maxHeight: 64
          ),
          child: cachedNetworkImage(context, user.photoUrl)
        ),
        title: Text(
          user.displayName,
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Text(
          'Joined ${timeago.format(widget.group.createdAt.toDate())}',
          style: TextStyle(color: Colors.grey)
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_horiz),
          onPressed: () {
            return popupMenu(
              tooltip: 'Member Options',
              onSelect: handleMemberOption,
              choices: choices,
              context: context,
              icon: Icons.more_horiz
            );
          },
        )
      ));
    }
    return ListView(children: widgetLists);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          'Members',
          style: TextStyle(color: Colors.white, fontSize: 22.0)
        ),
      ),
      body: Column(
        children: <Widget>[
          TabBar(
            tabs: <Widget>[
              Tab(
                child: Text(
                  'MEMBERS',
                  style: TextStyle(color: Theme.of(context).cardColor)
                )
              ),
              Tab(
                child: Text(
                  'ADMINS',
                  style: TextStyle(color: Theme.of(context).cardColor)
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
                onPressed: () => searchController.clear(),
              ),
              border: InputBorder.none,
            )
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                displayUsers(),
                displayUsers(type: 'admin')
              ],
            )
          )
        ],
      )
    );
  }
}
