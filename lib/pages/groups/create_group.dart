import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/pages/post/post_studio.dart';
import 'package:isocial/pages/profile/edit_profile.dart';
import 'package:isocial/widgets/progress.dart';
import 'package:isocial/widgets/snackbar.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:isocial/helpers/reusable_functions.dart';

class CreateGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateGroupState();
  }
}

class _CreateGroupState extends State<CreateGroup> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController groupNameController = new TextEditingController();
  Asset coverPhoto;
  bool publicity = false;
  bool invisibility = false;
  String groupId = Uuid().v4();
  bool loading = false;

  Future<String> uploadCoverPhoto() async {
    String downloadUrl = '';
    if (coverPhoto != null) {
      ByteData byteData = await coverPhoto.requestOriginal(quality: 85);
      List<int> assetData = byteData.buffer.asUint8List();
      StorageUploadTask uploadTask = storageRef
        .child('group_${Uuid().v4()}.jpg')
        .putData(assetData);
      StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
      downloadUrl = await storageSnap.ref.getDownloadURL();
    }
    return downloadUrl;
  }

  createGroup() async {
    String groupName = groupNameController.text;
    if (groupName != null && groupName.length > 3) {
      setState(() { loading = true; });
      String coverPhoto = await uploadCoverPhoto();
      List<String> searchKeys = extractUniqueChars(groupNameController.text);
      groupsRef.document(groupId).setData({
        'groupId': groupId,
        'ownerId': currentUser.id,
        'name': groupName,
        'coverPhoto': '',
        'privacy': publicity ? 'public' : 'private',
        'visibility': invisibility ? 'hidden' : 'visible',
        'members': {
          0: {
            'id': currentUser.id,
            'role': 'admin',
            'joinDate': DateTime.now()
          }
        },
        'joinRequests': [],
        'membersCount': 1,
        'coverPhoto': coverPhoto.isNotEmpty ? coverPhoto : '',
        'location': currentUserLocation,
        'requestApproval': 'anyone',
        'postCreators': 'anyone',
        'postApproval': false,
        'groupRules': {},
        'isDeleted': false,
        'searchKeys': searchKeys,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now()
      });
      groupNameController.clear();
      setState(() {
        coverPhoto = null;
        loading = false;
        groupId = Uuid().v4();
      });
      Navigator.pop(context);
    } else {
      SnackBar snackBar = snackbar(
        msg: 'Group name is required',
        bgColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 5000)
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  displayGroupVisibilityBottomSheet() {
    groupVisibilityBottomSheet(
      context: context,
      contentHeight: 208.0,
      invisibility: invisibility,
      callback1: () => setState(() => invisibility = false),
      callback2: () => setState(() => invisibility = true)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        automaticallyImplyLeading: true,
        title: Text('Create Group'),
        actions: <Widget>[
          FlatButton(
            onPressed: createGroup,
            child: Text(
              'Create',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              )
            )
          )
        ]
      ),
      body: ListView(
        children: <Widget>[
          loading ? linearProgress() : Text(''),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column (
              children: <Widget>[
                ListTile(
                  title: Text(
                    'Name',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 17.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).accentColor
                        )
                      ),
                      hintText: 'Name your group'
                    ),
                    controller: groupNameController
                  )
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Cover Photo',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                  ),
                  trailing: Text(
                    'Optional',
                    style: TextStyle(color: Colors.grey)
                  ),
                ),
                ListTile(
                  onTap: () async {
                    if (coverPhoto != null) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 140.0,
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  onTap: () async {
                                    List<Asset> resultList = new List<Asset>();
                                    resultList = await imagePicker(mounted, 1);
                                    if (resultList != null) {
                                      setState(() {
                                        coverPhoto = resultList[0];
                                      });
                                      Navigator.pop(context);
                                    } else { return; }
                                  },
                                  leading: Icon(
                                    Icons.add_photo_alternate,
                                    color: Colors.black,
                                    size: 30.0
                                  ),
                                  title: Text(
                                    'Change cover photo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0
                                    )
                                  )
                                ),
                                ListTile(
                                  onTap: () {
                                    setState(() => coverPhoto = null);
                                    Navigator.pop(context);
                                  },
                                  leading: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 30.0
                                  ),
                                  title: Text(
                                    'Remove photo',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold
                                    )
                                  )
                                )
                              ]
                            )
                          );
                        }
                      );
                    } else {
                      List<Asset> resultList = new List<Asset>();
                      resultList = await imagePicker(mounted, 1);
                      if (resultList != null) {
                        setState(() {
                          coverPhoto = resultList[0];
                        });
                      } else { return; }
                    }
                  },
                  leading: coverPhoto != null ? AssetThumb(
                    asset: coverPhoto,
                    width: 50,
                    height: 50
                  ) : Icon(
                    Icons.add_a_photo,
                    color: Colors.black,
                    size: 30.0
                  ),
                  title: Text(
                    coverPhoto != null ? 'Change cover photo' : 'Add cover photo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)
                  )
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Privacy',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                  )
                ),
                ListTile(
                  onTap: () => setState(() => publicity = true),
                  leading: Icon(
                    Icons.public,
                    color: Colors.black,
                    size: 30.0
                  ),
                  title: Text(
                    'Public',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)
                  ),
                  subtitle: Text(
                    "Anyone can see who's in the group and what they post",
                    style: TextStyle(color: Colors.grey)
                  ),
                  trailing: Icon(
                    publicity ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: Theme.of(context).accentColor
                  )
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),
                ListTile(
                  onTap: () => setState(() => publicity = false),
                  leading: Icon(Icons.lock, color: Colors.black, size: 30.0),
                  title: Text(
                    'Private',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)
                  ),
                  subtitle: Text(
                    "Only memebers can see who's in the group and what they post",
                    style: TextStyle(color: Colors.grey)
                  ),
                  trailing: Icon(
                    publicity ? Icons.radio_button_unchecked
                        : Icons.radio_button_checked,
                    color: Theme.of(context).accentColor
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'More options',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0
                    )
                  )
                ),
                ListTile(
                  onTap: displayGroupVisibilityBottomSheet,
                  leading: Icon(
                    invisibility ? Icons.visibility_off: Icons.visibility,
                    color: Colors.black,
                    size: 30.0
                  ),
                  title: Text(
                    'Hide group',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)
                  ),
                  subtitle: Text(
                    invisibility ? 'Hidden' : 'Visible',
                    style: TextStyle(color: Colors.grey)
                  ),
                ),
                Divider()
              ]
            )
          )
        ],
      )
    );
  }
}
