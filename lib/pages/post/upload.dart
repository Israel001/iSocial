import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:native_state/native_state.dart';
import 'package:uuid/uuid.dart';

import 'package:isocial/models/user.dart';
import 'package:isocial/pages/post/post_studio.dart';

class Upload extends StatefulWidget {
  final SavedStateData savedState;
  final User currentUser;

  Upload({ this.currentUser, this.savedState });

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

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return !showPostStudio ? buildSplashScreen() : PostStudio(
      savedState: widget.savedState,
      state: 'upload',
      onExit: goBack,
    );
  }
}