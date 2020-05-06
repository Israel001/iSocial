import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:isocial/models/group.dart';
import 'package:isocial/pages/groups/rules/edit_rules.dart';
import 'package:isocial/pages/groups/rules/rules.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/pages/post/post_studio.dart';
import 'package:isocial/widgets/custom_image.dart';
import 'package:isocial/widgets/progress.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';

import 'group_settings.dart';
import 'members.dart';

class GroupPage extends StatefulWidget {
  final String groupId;

  GroupPage({ this.groupId });

  @override
  State<StatefulWidget> createState() {
    return _GroupPageState();
  }
}

class _GroupPageState extends State<GroupPage> with
  AutomaticKeepAliveClientMixin<GroupPage> {
  Group group;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getGroupInfo();
  }

  getGroupInfo() async {
    setState((){ isLoading = true; });
    DocumentSnapshot doc = await groupsRef.document(widget.groupId).get();
    Group group = Group.fromDocument(doc);
    setState(() {
      isLoading = false;
      this.group = group;
    });
  }

  uploadCoverPhoto(List<Asset> asset) async {
    setState(() { isLoading = true; });
    Asset image = asset[0];
    ByteData byteData = await image.requestOriginal(quality: 85);
    List<int> assetData = byteData.buffer.asUint8List();
    StorageUploadTask uploadTask = storageRef
      .child('group_${Uuid().v4()}.jpg').putData(assetData);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    groupsRef.document(group.groupId).updateData({'coverPhoto': downloadUrl});
    getGroupInfo();
  }

  displayAdminTools() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300.0,
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.close),
                  Padding(padding: EdgeInsets.only(left: 100.0)),
                  Text(
                    'Admin tools',
                    style: TextStyle(fontWeight: FontWeight.bold)
                  )
                ],
              ),
              Divider(),
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Member Requests'),
                onPressed: () {}
              ),
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Admins Activities'),
                onPressed: () {},
              ),
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Members'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Members(group: group)
                    )
                  );
                },
              ),
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Rules'),
                onPressed: () {
                  Navigator.pop(context);
                  if (group.groupRules.length > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditRules(group: group)
                      )
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Rules(group: group)
                      )
                    );
                  }
                },
              ),
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Group Settings'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupSettings(group: group)
                    )
                  );
                },
              ),
            ]
          )
        );
      }
    );
  }

  displayCoverPhotoOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: group.coverPhoto.isNotEmpty ? 150.0 : 125.0,
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.close),
                  Padding(
                    padding: EdgeInsets.only(left: 100.0),
                    child: Text(
                      'Choose an option',
                      style: TextStyle(fontWeight: FontWeight.bold)
                    )
                  )
                ]
              ),
              Divider(),
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Upload Photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  List<Asset> image = new List<Asset>();
                  image = await imagePicker(mounted, 1);
                  if (image.isNotEmpty) {
                    uploadCoverPhoto(image);
                  } else { return; }
                },
              ),
              group.coverPhoto.isNotEmpty ? FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Remove Photo'),
                onPressed: () {
                  Navigator.pop(context);
                  groupsRef.document(group.groupId).updateData({'coverPhoto': ''});
                  getGroupInfo();
                },
              ) : Text('')
            ]
          )
        );
      }
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => {},
        child: isLoading ? Center(child: circularProgress(context)) : ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                cachedNetworkImage(
                  context,
                  group.coverPhoto.isNotEmpty
                      ? group.coverPhoto : 'https://i.imgur.com/Vsf8MAc.jpg',
                  height: 200.0
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(100, 0, 0, 0),
                        Color.fromARGB(100, 0, 0, 0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter
                    )
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 200
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
                    onPressed: () => Navigator.pop(context),
                  )
                ),
                Positioned(
                  top: 0.0,
                  right: 35.0,
                  child: Padding(
                    padding: EdgeInsets.only(right: 30.0),
                    child: IconButton(
                      icon: Icon(Icons.search, color: Colors.white, size: 30.0),
                      onPressed: () {},
                    )
                  )
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: IconButton(
                      icon: Icon(Icons.stars, color: Colors.white, size: 30.0),
                      onPressed: displayAdminTools
                    )
                  )
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: displayCoverPhotoOption,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.camera_alt),
                            Padding(padding: EdgeInsets.only(right: 5.0)),
                            Text('EDIT')
                          ]
                        )
                      )
                    )
                  )
                )
              ]
            )
          ],
        )
      )
    );
  }
}
