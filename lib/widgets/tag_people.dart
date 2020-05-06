import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial/models/user.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/widgets/progress.dart';

class TagPeople extends StatefulWidget {
  final Map<String, String> taggedPeople;

  TagPeople({ this.taggedPeople });

  @override
  State<StatefulWidget> createState() {
    return TagPeopleState(isSelected: taggedPeople);
  }
}

class TagPeopleState extends State<TagPeople> {
  List<User> followers;
  Map<String, String> isSelected;
  bool isLoading = false;

  TagPeopleState({ this.isSelected });

  @override
  void initState() {
    super.initState();
    initFollowers();
  }

  initFollowers() async {
    setState(() { isLoading = true; });
    List<User> followers = [];
    QuerySnapshot snapshot = await followersRef
      .document(currentUser.id)
      .collection('userFollowers')
      .getDocuments();
    for (var doc in snapshot.documents) {
      if (doc.documentID != currentUser.id) {
        usersRef
          .document(doc.documentID)
          .get().then((doc) {
            if (doc.exists) {
              User user = User.fromDocument(doc);
              followers.add(user);
            }
          });
      }
    }
    setState(() {
      isLoading = false;
      this.followers = followers;
    });
  }

  toggleSelected(id, displayName) {
    if (isSelected == null) {
      isSelected = { id: displayName };
    } else {
      if (isSelected.containsKey(id)) {
        isSelected.remove(id);
      } else {
        isSelected.addAll({ id: displayName});
      }
    }
    setState(() {});
  }

  buildFollowers() {
    if (followers == null || followers.isEmpty) {
      return Column(
        children: <Widget>[
          Container(
            child: Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'You currently have no one to tag. When people start '
                      'following you, their profile will show up here and you '
                      'can tag them',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent
                      )
                    )
                  ],
                )
              )
            )
          )
        ],
      );
    }
    return ListView(
      children: List.generate(followers.length, (index) {
        return GestureDetector(
          onTap: () => toggleSelected(
            followers[index].id,
            followers[index].displayName
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 10.0)),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected != null
                            ? isSelected.containsKey(followers[index].id)
                            ? Theme.of(context).cardColor
                            : Colors.white : Colors.white,
                        border: Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(50)
                      ),
                      child: isSelected != null
                          ? isSelected.containsKey(followers[index].id)
                          ? Icon(Icons.done, color: Colors.white, size: 15.0)
                          : Text('') : Text('')
                    )
                  ),
                  Padding(padding: EdgeInsets.only(left: 10.0)),
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      followers[index].photoUrl
                    )
                  ),
                  Padding(padding: EdgeInsets.only(left: 10.0)),
                  Text(followers[index].displayName)
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Divider()
            ],
          )
        );
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, isSelected);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Tag People',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0
            )
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context, isSelected),
              icon: Icon(
                Icons.done,
                size: 30.0,
                color: Colors.white
              )
            )
          ],
        ),
        body: isLoading ? circularProgress(context) : buildFollowers()
      )
    );
  }
}
