import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:isocial/helpers/reusable_functions.dart';
import 'package:isocial/models/group.dart';
import 'package:isocial/pages/groups/set_group_category.dart';
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/pages/post/post_studio.dart';
import 'package:isocial/widgets/header.dart';
import 'package:isocial/widgets/snackbar.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';

class GroupSettings extends StatefulWidget {
  final Group group;

  GroupSettings({ this.group });

  @override
  State<StatefulWidget> createState() {
    return _GroupSettingsState();
  }
}

class _GroupSettingsState extends State<GroupSettings> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController dialogInputController = new TextEditingController();
  bool groupPublicity;
  bool groupVisibility;
  bool requestApproval;
  bool postCreators;
  bool postApproval;

  uploadCoverPhoto(List<Asset> asset) async {
    Asset image = asset[0];
    ByteData byteData = await image.requestOriginal(quality: 85);
    List<int> assetData = byteData.buffer.asUint8List();
    StorageUploadTask uploadTask = storageRef
      .child('group_${Uuid().v4()}.jpg').putData(assetData);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    groupsRef.document(widget.group.groupId).updateData({
      'coverPhoto': downloadUrl
    });
    Navigator.pop(context);
  }

  updateGroupName(enteredText) async {
    if (enteredText.trim().isNotEmpty && enteredText.trim() != widget.group.name) {
      String newGroupName = enteredText.trim();
      QuerySnapshot snapshot = await groupsRef
          .where('name', isEqualTo: newGroupName).getDocuments();
      if (snapshot.documents.isNotEmpty) {
        SnackBar snackBar = snackbar(
          msg: 'Group name already exists',
          bgColor: Theme.of(context).accentColor,
          duration: Duration(milliseconds: 5000)
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else {
        groupsRef.document(widget.group.groupId).updateData({
          'name': newGroupName
        });
        Navigator.pop(context);
      }
    }
  }

  updateGroupLocation(enteredText) {
    if (enteredText.trim().isNotEmpty
        && enteredText.trim() != widget.group.location) {
      String newGroupLocation = enteredText.trim();
      groupsRef.document(widget.group.groupId).updateData({
        'location': newGroupLocation
      });
      Navigator.pop(context);
    }
  }

  setGroupPrivacy() {
    if (!(DateTime.now().day - widget.group.updatedAt.toDate().day > -28)) {
      if (!(widget.group.privacy == 'private' && widget.group.membersCount >= 5000)) {
        setState(() => groupPublicity = !groupPublicity);
        groupsRef.document(widget.group.groupId).updateData({
          'privacy': groupPublicity ? 'public' : 'private',
          'updatedAt': DateTime.now()
        });
        Navigator.pop(context);
      } else {
        displayMsgDialog(
          content: Text(
            "Private groups with 5,000 or more members can't change their privacy "
            "to public"
          )
        );
      }
    } else {
      displayMsgDialog(
        content: Text("You can only change the group's privacy once every 28 days")
      );
    }
  }

  setGroupVisibility(String visibility) {
    if (widget.group.visibility != visibility) {
      groupsRef.document(widget.group.groupId).updateData({
        'visibility': visibility
      });
      Navigator.pop(context);
    }
  }

  setRequestApproval(String requestApprover) {
    if (widget.group.requestApproval != requestApprover) {
      groupsRef.document(widget.group.groupId).updateData({
        'requestApproval': requestApprover
      });
      Navigator.pop(context);
    }
  }

  setPostCreators(String postCreators) {
    if (widget.group.postCreators != postCreators) {
      groupsRef.document(widget.group.groupId).updateData({
        'postCreators': postCreators
      });
      Navigator.pop(context);
    }
  }

  setPostApproval(bool postApproval) {
    if (widget.group.postApproval != postApproval) {
      groupsRef.document(widget.group.groupId).updateData({
        'postApproval': postApproval
      });
      Navigator.pop(context);
    }
  }

  displayMsgDialog({Widget content}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: content,
          actions: <Widget>[
            FlatButton(
              child: Text(
                'CLOSE',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold
                )
              ),
              onPressed: () => Navigator.pop(context)
            )
          ]
        );
      }
    );
  }

  displayDialog(String titleText, Function callback) async {
    final String enteredText = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titleText),
          content: TextFormField(
            decoration: InputDecoration(
              hintText: titleText,
              filled: true
            ),
            controller: dialogInputController
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
              onPressed: () => Navigator.pop(context, dialogInputController.text),
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context, ''),
            )
          ],
        );
      }
    );
    if (enteredText.trim().isNotEmpty) callback(enteredText);
  }

  displayDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this group?'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold
                )
              ),
              onPressed: () {
                groupsRef.document(widget.group.groupId).updateData({
                  'isDeleted': true
                });
                Navigator.pop(context);
                Navigator.pop(context);
              }
            ),
            FlatButton(
              child: Text(
                'No',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold
                )
              ),
              onPressed: () => Navigator.pop(context)
            )
          ]
        );
      }
    );
  }

  displayGroupPrivacyBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 310.0,
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Privacy',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold
                )
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Expanded(
                child: Text(
                  "You can change the group's privacy once every 28 days. "
                  "Private groups with 5,000 or more members can't change their "
                  "privacy to public.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17.0
                  )
                )
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              ListTile(
                leading: Icon(Icons.public, color: Colors.black),
                title: Text(
                  'Public',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  )
                ),
                subtitle: Text(
                  "Anyone can see who's in the group and what they post",
                  style: TextStyle(color: Colors.grey)
                ),
                trailing: Icon(
                  groupPublicity
                    ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: Theme.of(context).accentColor
                ),
                onTap: setGroupPrivacy,
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              ListTile(
                leading: Icon(Icons.lock, color: Colors.black),
                title: Text(
                  'Private',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  )
                ),
                subtitle: Text(
                  "Only members can see who's in the group and what they post",
                  style: TextStyle(color: Colors.grey)
                ),
                trailing: Icon(
                  groupPublicity
                    ? Icons.radio_button_unchecked : Icons.radio_button_checked,
                  color: Theme.of(context).accentColor
                ),
                onTap: setGroupPrivacy,
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
            ],
          )
        );
      }
    );
  }

  displayGroupVisibilityBottomSheet() {
    groupVisibilityBottomSheet(
      context: context,
      contentHeight: 208.0,
      invisibility: groupVisibility,
      callback1: () => setGroupVisibility('visible'),
      callback2: () => setGroupVisibility('hidden')
    );
  }

  displayRequestApprovalBottomSheet() {
    bottomSheetWithTwoOptions(
      context: context,
      contentHeight: 165.0,
      titleText: 'Who can approve member requests?',
      icon1: Icons.people,
      icon2: Icons.stars,
      optionText1: 'Anyone in the group',
      optionText2: 'Only admins',
      option1Selected: requestApproval,
      callback1: () => setRequestApproval('anyone'),
      callback2: () => setRequestApproval('admin')
    );
  }

  displayPostCreatorsBottomSheet() {
    bottomSheetWithTwoOptions(
      context: context,
      contentHeight: 165.0,
      titleText: 'Who can post',
      icon1: Icons.people,
      icon2: Icons.stars,
      optionText1: 'Anyone in the group',
      optionText2: 'Only admins',
      option1Selected: postCreators,
      callback1: () => setPostCreators('anyone'),
      callback2: () => setPostCreators('admin')
    );
  }

  displayPostApprovalBottomSheet() {
    bottomSheetWithTwoOptionsAndTitleDesc(
      context: context,
      contentHeight: 215.0,
      titleText: 'Post approval',
      titleDesc: 'Turn this on if you want admins to approve each post',
      icon1: Icons.chat,
      icon2: Icons.chat,
      optionText1: 'On',
      optionText2: 'Off',
      option1Selected: postApproval,
      callback1: () => setPostApproval(true),
      callback2: () => setPostApproval(false)
    );
  }

  @override
  Widget build(BuildContext context) {
    groupPublicity = widget.group.privacy == 'public' ? true : false;
    groupVisibility = widget.group.visibility == 'hidden' ? true : false;
    requestApproval = widget.group.requestApproval == 'anyone' ? true : false;
    postCreators = widget.group.postCreators == 'anyone' ? true : false;
    postApproval = widget.group.postApproval;
    return Scaffold(
      appBar: header(context, titleText: 'Group Settings'),
      body: ListView(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(10.0)),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              'Basic Group Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              )
            )
          ),
          ListTile(
            title: Text(
              'Group Name',
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            subtitle: Text(
              widget.group.name,
              style: TextStyle(color: Colors.grey)
            ),
            onTap: () {
              dialogInputController.text = widget.group.name;
              displayDialog('Enter the Group Name', updateGroupName);
            },
          ),
          ListTile(
            title: Text(
              'Cover Photo',
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            onTap: () async {
              List<Asset> image = new List<Asset>();
              image = await imagePicker(mounted, 1);
              if (image.isNotEmpty) {
                uploadCoverPhoto(image);
              } else { return; }
            },
          ),
          ListTile(
            title: Text(
              'Group Category',
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            subtitle: Text(
              widget.group.category.isNotEmpty ? widget.group.category : 'None',
              style: TextStyle(color: Colors.grey)
            ),
            onTap: () async {
              String groupCategory = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SetGroupCategory(
                    selectedGroupCategory: widget.group.category
                  )
                )
              );
              if (groupCategory != widget.group.category) {
                groupsRef.document(widget.group.groupId).updateData({
                  'category': groupCategory
                });
                Navigator.pop(context);
              }
            }
          ),
          ListTile(
            title: Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            subtitle: Text(
              widget.group.location.isNotEmpty ? widget.group.location
                  : 'No location',
              style: TextStyle(color: Colors.grey)
            ),
            onTap: () {
              dialogInputController.text = widget.group.location;
              displayDialog('Enter the Group Location', updateGroupLocation);
            }
          ),
          ListTile(
            title: Text(
              'Privacy',
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            subtitle: Text(
              convertFirstLetterToUppercase(widget.group.privacy),
              style: TextStyle(color: Colors.grey)
            ),
            onTap: displayGroupPrivacyBottomSheet
          ),
          ListTile(
            title: Text(
              'Visibility',
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            subtitle: Text(
              convertFirstLetterToUppercase(widget.group.visibility),
              style: TextStyle(color: Colors.grey)
            ),
            onTap: displayGroupVisibilityBottomSheet,
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.only(left: 10.0, top: 10.0),
            child: Text(
              'Membership',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              )
            )
          ),
          ListTile(
            title: Text(
              'Who can approve member requests?',
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            subtitle: Text(
              widget.group.requestApproval == 'admin'
                ? 'Only admins' : 'Anyone in the group',
              style: TextStyle(color: Colors.grey)
            ),
            onTap: displayRequestApprovalBottomSheet
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.only(left: 10.0, top: 10.0),
            child: Text(
              'Discussion',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              )
            )
          ),
          ListTile(
            title: Text(
              'Who can post',
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            subtitle: Text(
              widget.group.postCreators == 'admin'
                ? 'Only admins' : 'Anyone in the group',
              style: TextStyle(color: Colors.grey)
            ),
            onTap: displayPostCreatorsBottomSheet
          ),
          ListTile(
            title: Text(
              'Post approval',
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            subtitle: Text(
              widget.group.postApproval ? 'On' : 'Off',
              style: TextStyle(color: Colors.grey)
            ),
            onTap: displayPostApprovalBottomSheet
          ),
          ListTile(
            title: Text(
              'Delete group',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold
              )
            ),
            onTap: displayDeleteDialog
          )
        ]
      )
    );
  }
}
