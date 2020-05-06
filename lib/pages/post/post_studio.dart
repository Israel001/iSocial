import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isocial/widgets/custom_image.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:native_state/native_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_facebook_image_picker/flutter_facebook_image_picker.dart';
import 'package:emoji_picker/emoji_picker.dart';

import 'package:isocial/pages/activity_feed/activity_feed.dart';
import 'package:isocial/pages/home/home.dart';

import 'package:isocial/widgets/progress.dart';
import 'package:isocial/widgets/post_button.dart';
import 'package:isocial/widgets/feelings_or_activities.dart';
import 'package:isocial/widgets/post_studio_assets.dart';
import 'package:isocial/widgets/tag_people.dart';

import 'package:isocial/pages/profile/edit_profile.dart';

class PostStudio extends StatefulWidget {
  final SavedStateData savedState;
  final String state;
  final Function onExit;
  final String postToBeEditedId;
  final Widget postTitle;
  final String manualLocation;
  final bool lockPost;
  final String caption;
  final dynamic assets;
  final dynamic selectedFeelingOrActivity;
  final dynamic taggedPeople;
  final String backgroundColor;

  PostStudio({
    this.savedState,
    this.state,
    this.onExit,
    this.postToBeEditedId,
    this.postTitle,
    this.manualLocation,
    this.lockPost,
    this.caption,
    this.assets,
    this.selectedFeelingOrActivity,
    this.taggedPeople,
    this.backgroundColor
  });

  @override
  State<StatefulWidget> createState() {
    return PostStudioState();
  }
}

class PostStudioState extends State<PostStudio> {
  TextEditingController captionController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();
  VideoPlayerController videoPlayerController;
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool textOnly = false;
  bool showColor = false;
  bool useLocation = false;
  bool lockPost = false;
  bool showSticker = false;
  bool isUploading = false;
  String colorText = 'Add Background Colour';
  Map<int, Color> colorMap = {
    0: Colors.red, 1: Colors.green, 2: Colors.blue,
    3: Colors.yellow, 4: Colors.black, 5: Colors.purple
  };
  Map<int, bool> colorSelected = {
    0: true, 1: false, 2: false,
    3: false, 4: false, 5: false
  };
  Map<int, String> colorMapForSubmission = {
    0: 'red', 1: 'green', 2: 'blue',
    3: 'yellow', 4: 'black', 5: 'purple'
  };
  int colorSelectedId = 0;
  String userLocation = '';
  String manualLocation = '';
  String postId = Uuid().v4();
  List<dynamic> assets = List<dynamic>();
  List<String> recommendedEmotes = List<String>();
  String fbAccessToken;
  bool showSnackBar = true;
  String feelingOrActivity;
  String feelingOrActivityType;
  Map<String, String> selectedFeelingOrActivity;
  Map<String, String> taggedPeople;
  Widget postTitle = Text(
    currentUser.displayName,
    style: TextStyle(fontWeight: FontWeight.bold)
  );

  @override
  void initState() {
    super.initState();
      userLocation = currentUserLocation;
      if (widget.state == 'edit') {
      postTitle = widget.postTitle;
      manualLocation = widget.manualLocation;
      lockPost = widget.lockPost;
      captionController.text = widget.caption;
      assets = widget.assets;
      selectedFeelingOrActivity = widget.selectedFeelingOrActivity;
      taggedPeople = widget.taggedPeople;
      if (widget.backgroundColor.isNotEmpty) {
        colorSelected.updateAll((colorId, isSelected) => false);
        textOnly = true;
        showColor = true;
        switch(widget.backgroundColor) {
          case 'red':
            colorSelected[0] = true; colorSelectedId = 0;
          break;
          case 'green':
            colorSelected[1] = true; colorSelectedId = 1;
          break;
          case 'blue':
            colorSelected[2] = true; colorSelectedId = 2;
          break;
          case 'yellow':
            colorSelected[3] = true; colorSelectedId = 3;
          break;
          case 'black':
            colorSelected[4] = true; colorSelectedId = 4;
          break;
          case 'purple':
            colorSelected[5] = true; colorSelectedId = 5;
          break;
        }
      }
    }
  }

  initRecommendedEmotes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recommendedEmotes = prefs.getStringList('recommendedEmotes') ?? List<String>();
    });
  }

  Future<List<dynamic>> uploadAssets() async {
    List<dynamic> downloadUrls = List<dynamic>();
    if (widget.state == 'edit') downloadUrls = assets;
    if (assets.isNotEmpty && !textOnly) {
      await Future.wait(assets.map((asset) async {
        StorageUploadTask uploadTask;
        if (asset.runtimeType != String) {
          if (asset.runtimeType == Asset) {
            ByteData byteData = await asset.requestOriginal(quality: 85);
            List<int> assetData = byteData.buffer.asUint8List();
            uploadTask = storageRef
              .child('post_${Uuid().v4()}.jpg')
              .putData(assetData);
          } else if (asset.runtimeType == Photo) {
            downloadUrls.add(asset.source);
          } else {
            uploadTask = storageRef
              .child('post_${Uuid().v4()}.mp4')
              .putFile(asset);
          }
        }
        if (uploadTask != null) {
          StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
          String downloadUrl = await storageSnap.ref.getDownloadURL();
          downloadUrls.add(downloadUrl);
        }
      }));
    }
    return downloadUrls;
  }

  updatePost() async {
    setState(() { isUploading = true; });
    List<dynamic> mediaUrl = await uploadAssets();
    List<String> searchKeys = extractUniqueChars(captionController.text);
    postsRef
      .document(currentUser.id)
      .collection('userPosts')
      .document(widget.postToBeEditedId)
      .updateData({
        'feelingOrActivity': selectedFeelingOrActivity,
        'taggedPeople': taggedPeople,
        'postAudience': lockPost ? 'Only Me' : 'Followers',
        'caption': captionController.text,
        'location': useLocation ? userLocation : manualLocation,
        'backgroundColor': showColor
          ? colorMapForSubmission[colorSelectedId] : '',
        'mediaUrl': mediaUrl.isNotEmpty ? mediaUrl : '',
        'updatedAt': DateTime.now(),
        'searchKeys': searchKeys
      });
    captionController.clear();
    setState(() {
      assets = List<dynamic>();
      isUploading = false;
    });
    widget.onExit();
  }

  uploadPost() async {
    setState(() { isUploading = true; });
    List<dynamic> mediaUrl = await uploadAssets();
    List<String> searchKeys = extractUniqueChars(captionController.text);
    postsRef
      .document(currentUser.id)
      .collection('userPosts')
      .document(postId)
      .setData({
        'postId': postId,
        'ownerId': currentUser.id,
        'username': currentUser.username,
        'displayName': currentUser.displayName,
        'feelingOrActivity': selectedFeelingOrActivity,
        'taggedPeople': taggedPeople,
        'postAudience': lockPost ? 'Only Me' : 'Followers',
        'caption': captionController.text,
        'location': useLocation ? userLocation : manualLocation,
        'backgroundColor': showColor
            ? colorMapForSubmission[colorSelectedId] : '',
        'mediaUrl': mediaUrl.isNotEmpty ? mediaUrl : '',
        'createdAt': DateTime.now(),
        'updatedAt': '',
        'likes': {},
        'saves': {},
        'isDeleted': false,
        'searchKeys': searchKeys
      });
    captionController.clear();
    setState(() {
      assets = List<dynamic>();
      postId = Uuid().v4();
      isUploading = false;
    });
    widget.onExit();
  }

  processSubmission() {
    if ((captionController.text.isNotEmpty || assets.isNotEmpty)
        && isUploading != null && widget.state == 'upload') {
      uploadPost();
    } else if ((captionController.text.isNotEmpty || assets.isNotEmpty)
        && isUploading != null && widget.state == 'edit') {
      updatePost();
    } else {
      return null;
    }
  }

  showColorPalette() {
    if (showColor) {
      setState(() {
        showColor = false;
        colorText = 'Add Background Colour';
      });
    } else {
      setState(() {
        showColor = true;
        colorText = 'Remove Background Colour';
      });
    }
  }

  switchColorBox(id) {
    colorSelected.updateAll((colorId, isSelected) => false);
    setState(() {
      colorSelected[id] = true;
      colorSelectedId = id;
    });
  }

  colorBox({int id}) {
    return Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: GestureDetector(
        onTap: () => switchColorBox(id),
        child: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: colorMap[id],
            borderRadius: BorderRadius.circular(5.0)
          ),
          child: colorSelected[id] ? Icon(Icons.check) : Text('')
        )
      )
    );
  }

  loadImages() async {
    List<Asset> resultList = new List<Asset>();
    resultList = await imagePicker(mounted, 1000);
    if (resultList.isNotEmpty) {
      setState(() { assets += resultList; });
    } else { return; }
  }

  buildVideo(asset) {
    VideoPlayerController videoPlayer = VideoPlayerController.network(asset);
    return FutureBuilder(
      future: videoPlayer.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VideoPlayer(videoPlayer);
        }
        return Center(child: circularProgress(context));
      }
    );
  }

  loadAssetBasedOnType(asset) {
    return asset.runtimeType == Asset ? AssetThumb(
        asset: asset,
        width: 300,
        height: 300
    ) : asset.runtimeType == Photo ? Image.network(
        asset.source,
        width: 300,
        height: 300
    ) : asset.runtimeType == String && !asset.contains('mp4') ? cachedNetworkImage(
        context,
        asset
    ) : asset.runtimeType == String && asset.contains('mp4') ? AspectRatio(
        aspectRatio: 300 / 300,
        child: buildVideo(asset)
    ) : AspectRatio(
        aspectRatio: 300 / 300,
        child: VideoPlayer(videoPlayerController)
    );
  }

  displayAllAssets() {
    int length = assets.length > 4 ? 4 : assets.length;
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 10.0,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(length, (index) {
        dynamic asset = assets[index];
        if (index == length - 1 && assets.length > length) {
          return Container(
            child: Stack(
              children: <Widget>[
                loadAssetBasedOnType(asset),
                GestureDetector(
                  onTap: () async {
                    final modifiedAssets = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostStudioAssets(assets: assets)
                      )
                    );
                    setState(() { assets = modifiedAssets; });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Text(
                        '+ ${assets.length - length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ),
                    width: 300,
                    height: 300
                  )
                )
              ],
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black)
            ),
            margin: EdgeInsets.all(5.0)
          );
        }
        return GestureDetector(
          onTap: () async {
            final modifiedAssets = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostStudioAssets(assets: assets)
              )
            );
            setState(() { this.assets = modifiedAssets; });
          },
          child: Container(
            child: loadAssetBasedOnType(asset),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black)
            ),
            margin: EdgeInsets.all(5.0)
          )
        );
      })
    );
  }

  loadVideo(source) async {
    File video = await ImagePicker.pickVideo(source: source);
    assets.add(video);
    videoPlayerController = VideoPlayerController.file(video)..initialize()
      .then((_) => setState(() {}));
  }

  loadImagesFromFacebook() async {
    final FacebookLoginResult result =
      await facebookSignIn.logIn(['user_photos']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        setState(() { fbAccessToken = accessToken.token; });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FacebookImagePicker(
              fbAccessToken,
              onDone: (items) {
                Navigator.pop(context);
                setState(() { assets += items; });
              },
              onCancel: () => Navigator.pop(context),
            )
          )
        );
      break;
      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user');
      break;
      case FacebookLoginStatus.error:
        print('Error: ${result.errorMessage}');
      break;
    }
  }

  displayMediaOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250.0,
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                'Choose an option',
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 10.0),
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Add Video from Gallery'),
                onPressed: () => loadVideo(ImageSource.gallery),
              ),
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Add Video from Camera'),
                onPressed: () => loadVideo(ImageSource.camera),
              ),
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Add Photos from Facebook'),
                onPressed: loadImagesFromFacebook,
              ),
              FlatButton(
                textColor: Theme.of(context).accentColor,
                child: Text('Add Photos from Gallery / Camera'),
                onPressed: loadImages
              )
            ]
          )
        );
      }
    );
  }

  showErrorMessage(msg) {
    SnackBar snackbar = SnackBar(
      content: Text(
        msg,
        overflow: TextOverflow.ellipsis
      ),
      backgroundColor: Colors.red,
      duration: Duration(milliseconds: 5000),
    );
    if (showSnackBar) {
      _scaffoldKey.currentState.showSnackBar(snackbar);
      setState(() { this.showSnackBar = !showSnackBar; });
      Timer(
        Duration(milliseconds: 5000),
        () => setState(() { this.showSnackBar = !showSnackBar; })
      );
    }
  }

  Future<bool> handleBackPressed() {
    if (showSticker) {
      setState(() { showSticker = false; });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  Widget buildSticker() {
    return EmojiPicker(
      rows: 5,
      columns: 8,
      buttonMode: ButtonMode.CUPERTINO,
      recommendKeywords: recommendedEmotes,
      numRecommended: 40,
      indicatorColor: Colors.purpleAccent,
      onEmojiSelected: (emoji, category) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          if (!recommendedEmotes.contains(emoji.name)) {
            recommendedEmotes.add(emoji.name);
            prefs.setStringList('recommendedEmotes', recommendedEmotes);
          }
        });
        captionController..text += emoji.emoji.toString()
          ..selection = TextSelection.collapsed(
            offset: captionController.text.length
          );
      }
    );
  }

  addLocation() async {
    final String enteredLocation = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter the Location'),
          content: TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter the Location',
              filled: true
            ),
            controller: locationController
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Done',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold
                ),
              ),
              onPressed: () => Navigator.pop(context, locationController.text),
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context, ''),
            )
          ],
        );
      }
    );
    if (enteredLocation.isNotEmpty) {
      setState(() { manualLocation = enteredLocation; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white70,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: widget.onExit,
          ),
          title: Text(
            widget.state == 'upload' ? 'Create Post' : 'Edit Post',
            style: TextStyle(color: Colors.black)
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: processSubmission,
              child: Text(
                widget.state == 'upload' ? 'Post' : 'Save',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0
                )
              )
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            isUploading ? linearProgress() : Text(''),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl)
              ),
              title: postTitle,
              subtitle: useLocation
                  ? Text(userLocation)
                  : manualLocation.isNotEmpty ? Text(manualLocation) : Text('')
            ),
            Row(
              children: <Widget> [
                FlatButton(
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(7.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            lockPost ? Icons.lock : Icons.people,
                            color: Colors.grey
                          ),
                          Text(
                            lockPost ? '  Only Me' : '  Followers',
                            style: TextStyle(color: Colors.grey)
                          ),
                        ],
                      )
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.5
                      ),
                      borderRadius: BorderRadius.circular(3.0)
                    ),
                    alignment: Alignment.center
                  ),
                  onPressed: () => print(''),
                ),
                Material(
                  child: Container(
                    margin: new EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(Icons.face),
                      onPressed: () {
                        setState(() { showSticker = !showSticker; });
                      },
                      color: Colors.grey
                    )
                  ),
                  color: Colors.white
                )
              ]
            ),
            Padding(padding: EdgeInsets.only(left: 10.0)),
            Container(
              margin: showColor
                  ? EdgeInsets.all(2.0)
                  : EdgeInsets.only(left: 10.0, right: 10.0),
              color: showColor ? colorMap[colorSelectedId] : Colors.white,
              child: TextFormField(
                textAlign: showColor ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontSize: showColor ? 40.0 : 20.0,
                  color: showColor
                    ? colorSelectedId == 3 ? Colors.black : Colors.white
                    : Colors.black,
                  fontWeight: showColor ? FontWeight.bold : FontWeight.normal
                ),
                cursorColor: showColor
                  ? colorSelectedId == 3 ? Colors.black : Colors.white
                  : Colors.black,
                maxLines: null,
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'Write something...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: showColor ? 30.0 : 20.0,
                    fontWeight: showColor ? FontWeight.bold : FontWeight.normal,
                    color: showColor
                      ? colorSelectedId == 3 ? Colors.black : Colors.white
                      : Colors.black
                  ),
                  fillColor: showColor ? colorMap[colorSelectedId] : Colors.black
                )
              )
            ),
            showSticker ? buildSticker() : Text(''),
            Padding(padding: EdgeInsets.only(top: 5.0)),
            showColor ? Row(
              children: <Widget>[
                colorBox(id: 0), colorBox(id: 1), colorBox(id: 2),
                colorBox(id: 3), colorBox(id: 4), colorBox(id: 5),
              ],
            ) : assets.isNotEmpty && !textOnly ? displayAllAssets() : Text(''),
            Divider(),
            SwitchListTile(
              value: textOnly,
              onChanged: (bool value) => setState(() {
                textOnly = value;
                value == false ? showColor = value : this.showColor = showColor;
                value == false ? colorText = 'Add Background Colour' :
                  this.colorText = colorText;
              }),
              title: Text('Text Only'),
              activeColor: Colors.purpleAccent,
            ),
            Divider(),
            SwitchListTile(
              value: useLocation,
              onChanged: (bool value) => setState(() { useLocation = value; }),
              title: Text('Use Your Location'),
              activeColor: Colors.purpleAccent,
            ),
            Divider(),
            SwitchListTile(
              value: lockPost,
              onChanged: (bool value) => setState(() { lockPost = value; }),
              title: Text('Private Post'),
              activeColor: Colors.purpleAccent,
            ),
            Divider(),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            postButton(
              handlePressed: !textOnly
                  ? () => showErrorMessage(
                      "Activate 'Text Only' Mode to add background color"
                    )
                  : showColorPalette,
              context: context,
              text: colorText
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Divider(),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            postButton(
              handlePressed: textOnly
                  ? () => showErrorMessage(
                      "Deactivate 'Text Only' Mode to add photos"
                    )
                  : displayMediaOption,
              context: context,
              text: 'Add Photos / Videos'
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Divider(),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            postButton(
              handlePressed: () async {
                final returnedValue = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeelingsOrActivities(
                      selectedFeelingOrActivity: selectedFeelingOrActivity
                    )
                  )
                );
                setState(() { selectedFeelingOrActivity = returnedValue; });
                Widget postTitle = configurePostTitle(
                  context,
                  currentUser.displayName,
                  currentUser.id,
                  selectedFeelingOrActivity,
                  taggedPeople,
                  savedState: widget.savedState
                );
                setState(() { this.postTitle = postTitle; });
              },
              context: context,
              text: 'Feeling / Activity'
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Divider(),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            postButton(
              handlePressed: addLocation,
              context: context,
              text: 'Add Location'
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Divider(),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            postButton(
              handlePressed: () async {
                final Map<String, String> taggedPeople = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TagPeople(
                    taggedPeople: this.taggedPeople
                  ))
                );
                if (taggedPeople != null) {
                  setState(() { this.taggedPeople = taggedPeople; });
                  Widget postTitle = configurePostTitle(
                    context,
                    currentUser.displayName,
                    currentUser.id,
                    selectedFeelingOrActivity,
                    taggedPeople,
                    savedState: widget.savedState
                  );
                  setState(() { this.postTitle = postTitle; });
                }
              },
              context: context,
              text: 'Tag People'
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0))
          ],
        )
      )
    );
  }
}

configurePostTitle(context, displayName, ownerId, selectedFeelingOrActivity,
  taggedPeople, {savedState}) {
  List taggedDisplayNames = [];
  List taggedDisplayIds = [];
  String feelingOrActivity;
  if (selectedFeelingOrActivity != null) {
    feelingOrActivity = selectedFeelingOrActivity['feelings'] != null
        ? 'Feeling ${selectedFeelingOrActivity['feelings']}'
        : selectedFeelingOrActivity['activities'] != null
        ? selectedFeelingOrActivity['activities']
        : '';
  }
  if (taggedPeople != null) {
    taggedPeople.forEach((id, displayName) {
      taggedDisplayNames.add(displayName);
      taggedDisplayIds.add(id);
    });
  }
  return RichText(
      text: TextSpan(
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(
                text: displayName,
                style: TextStyle(fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () =>
                      showProfile(
                          context,
                          profileId: ownerId,
                          savedState: savedState
                      )
            ),
            feelingOrActivity != null || taggedPeople != null
                ? TextSpan(text: ' is')
                : TextSpan(text: ''),
            feelingOrActivity != null
                ? TextSpan(
                text: ' $feelingOrActivity',
                style: TextStyle(fontWeight: FontWeight.bold)
            ) : TextSpan(text: ''),
            taggedPeople != null
                ? TextSpan(
                text: taggedDisplayNames.length == 1
                    ? ' with ${taggedDisplayNames[0]}'
                    : ' with ${taggedDisplayNames[0]} and '
                    '${taggedDisplayNames.length - 1} other(s)',
                style: TextStyle(fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () =>
                      showProfile(
                          context,
                          profileId: taggedDisplayIds[0]
                      )
            ) : TextSpan(text: '')
          ]
      )
  );
}

imagePicker(mounted, maxImages) async {
  List<Asset> resultList = List<Asset>();

  try {
    resultList = await MultiImagePicker.pickImages(
      maxImages: maxImages,
      enableCamera: true,
      cupertinoOptions: CupertinoOptions(takePhotoIcon: 'chat'),
      materialOptions: MaterialOptions(
        actionBarColor: '#64397e',
        actionBarTitle: 'iSocial',
        allViewTitle: 'All Photos',
        selectCircleStrokeColor: '#64397e'
      ),
    );
  } on Exception catch (_) {}

  if (!mounted) return null;

  return resultList;
}
