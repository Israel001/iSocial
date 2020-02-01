import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:isocial/models/user.dart';

import 'package:isocial/pages/edit_profile.dart';
import 'package:isocial/pages/home.dart';

import 'package:isocial/widgets/header.dart';
import 'package:isocial/widgets/post.dart';
import 'package:isocial/widgets/post_tile.dart';
import 'package:isocial/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({ this.profileId });

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with
  AutomaticKeepAliveClientMixin<Profile> {
  final String currentUserId = currentUser?.id;
  String postOrientation = 'grid';
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
      .document(widget.profileId)
      .collection('userFollowers')
      .document(currentUserId)
      .get();
    setState(() { isFollowing = doc.exists; });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
      .document(widget.profileId)
      .collection('userFollowers')
      .getDocuments();
    int count = 0;
    snapshot.documents.forEach((doc) {
      if (doc.documentID != currentUser.id) count++;
    });
    setState(() { followerCount = count; });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
      .document(widget.profileId)
      .collection('userFollowing')
      .getDocuments();
    setState(() { followingCount = snapshot.documents.length; });
  }

  getProfilePosts() async {
    setState(() { isLoading = true; });
    QuerySnapshot snapshot = await postsRef
      .document(widget.profileId)
      .collection('userPosts')
      .where('isDeleted', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold
          )
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400
            )
          )
        )
      ]
    );
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(currentUserId: currentUserId)
      )
    );
  }

  Container buildButton({ String text, Function function }) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 216.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold
            )
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue
            ),
            borderRadius: BorderRadius.circular(5.0)
          )
        )
      )
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOnwer = currentUserId == widget.profileId;
    if (isProfileOnwer) {
      return buildButton(
        text: 'Edit Profile',
        function: editProfile
      );
    } else if (isFollowing) {
      return buildButton(
        text: 'Unfollow',
        function: handleUnfollowUser
      );
    } else if (!isFollowing) {
      return buildButton(
        text: 'Follow',
        function: handleFollowUser
      );
    }
  }

  handleUnfollowUser() {
    setState(() { isFollowing = false; });
    unfollowUser(widget.profileId);
    getFollowers();
  }

  handleFollowUser() {
    setState(() { isFollowing = true; });
    // Make auth user follower of ANOTHER user (update THEIR followers
    // collection)
    followersRef
      .document(widget.profileId)
      .collection('userFollowers')
      .document(currentUserId)
      .setData({});
    getFollowers();
    // Put THAT user on YOUR following collection (update your
    // following collection)
    followingRef
      .document(currentUserId)
      .collection('userFollowing')
      .document(widget.profileId)
      .setData({});
    // add activity feed item for that user to notify about the
    // follower (us)
    activityFeedRef
      .document(widget.profileId)
      .collection('feedItems')
      .document(currentUserId)
      .setData({
        'type': 'follow',
        'ownerId': widget.profileId,
        'username': currentUser.username,
        'userId': currentUserId,
        'userProfileImg': currentUser.photoUrl,
        'timestamp': timestamp
      });
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl)
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn('posts', postCount),
                            buildCountColumn('followers', followerCount),
                            buildCountColumn('following', followingCount)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton()
                          ],
                        )
                      ],
                    )
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0
                  )
                )
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold)
                )
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(user.bio)
              )
            ],
          )
        );
      }
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'No Posts',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold
                )
              )
            )
          ],
        )
      );
    } else if (postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        if (post.mediaUrl.length > 0) {
          gridTiles.add(GridTile(child: PostTile(post)));
        }
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles
      );
    } else if (postOrientation == 'list') {
      return Column(children: posts);
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() { this.postOrientation = postOrientation; });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation('grid'),
          icon: Icon(Icons.grid_on),
          color: postOrientation == 'grid' ? Theme.of(context).primaryColor
              : Colors.grey
        ),
        IconButton(
          onPressed: () => setPostOrientation('list'),
          icon: Icon(Icons.list),
          color: postOrientation == 'list' ? Theme.of(context).primaryColor
              : Colors.grey
        )
      ],
    );
  }

  handleRefresh() {
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () {
        atOtherProfile = false;
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: header(context, titleText: 'Profile'),
        body: RefreshIndicator(
          onRefresh: () async => handleRefresh(),
          child: ListView(
            children: <Widget>[
              buildProfileHeader(),
              Divider(),
              buildTogglePostOrientation(),
              Divider(height: 0.0),
              buildProfilePosts()
            ],
          )
        )
      )
    );
  }
}

unfollowUser(postOwner) {
  // remove follower
  followersRef
    .document(postOwner)
    .collection('userFollowers')
    .document(currentUser.id)
    .get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  // remove following
  followingRef
    .document(currentUser.id)
    .collection('userFollowing')
    .document(postOwner)
    .get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  // delete activity feed item for them
  activityFeedRef
    .document(postOwner)
    .collection('feedItems')
    .document(currentUser.id)
    .get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
}