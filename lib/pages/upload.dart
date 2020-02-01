import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:isocial/pages/post_studio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:isocial/models/user.dart';
import 'package:isocial/pages/home.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({ this.currentUser });

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with
  AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController captionController = TextEditingController();
  File file;
  bool isUploading = false;
  bool showPostStudio = false;
  String postId = Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960
    );
    setState(() { this.file = file; });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() { this.file = file; });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text('Create Post'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Photo with Camera'),
              onPressed: handleTakePhoto
            ),
            SimpleDialogOption(
              child: Text('Image from Gallery'),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context)
            )
          ],
        );
      }
    );
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)
              ),
              child: Text(
                'Enter Post Studio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0
                )
              ),
              color: Colors.deepOrange,
              onPressed: () => setState((){ showPostStudio = true; })
            )
          )
        ],
      )
    );
  }

  goBack() { setState(() { showPostStudio = false; }); }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() { file = compressedImageFile; });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask = storageRef.child('post_$postId.jpg')
        .putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({ String mediaUrl, String location, String description }) {
    postsRef
      .document(widget.currentUser.id)
      .collection('userPosts')
      .document(postId)
      .setData({
        'postId': postId,
        'ownerId': widget.currentUser.id,
        'username': widget.currentUser.username,
        'mediaUrl': mediaUrl,
        'description': description,
        'location': location,
        'createdAt': timestamp,
        'updatedAt': '',
        'likes': {}
      });
  }

  handleSubmit() async {
    setState(() { isUploading = true; });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      description: captionController.text
    );
    captionController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return !showPostStudio ? buildSplashScreen() : PostStudio(
      state: 'upload',
      onExit: goBack,
    );
  }
}