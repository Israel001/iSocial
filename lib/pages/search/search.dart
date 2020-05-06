// External Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Models
import 'package:isocial/models/user.dart';

// Pages
import 'package:isocial/pages/home/home.dart';
import 'package:isocial/pages/post/post_studio.dart';
import 'package:isocial/pages/activity_feed/activity_feed.dart';

// Widgets
import 'package:isocial/widgets/post.dart';
import 'package:isocial/widgets/progress.dart';

class Search extends StatefulWidget {
  final String query;

  Search({ this.query });

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with
  AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> userQueryResultSet = [];
  List<DocumentSnapshot> postQueryResultSet = [];
  List<Widget> userSearchResults = [];
  List<Widget> postSearchResults = [];
  Map<String, List<Widget>> searchResults = {};
  List<Widget> finalSearchResults = [];
  List<String> tempStore = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.query != null) {
      searchController.text = widget.query;
      handleSearch(widget.query);
    }
  }

  void handleSearch(String query) async {
    if (query.trim().isNotEmpty) {
      setState(() { _isLoading = true; });
      query = query.toLowerCase();
      if (userQueryResultSet.length == 0 && query.length == 1) {
        QuerySnapshot users = await usersRef
          .where('searchKeys', arrayContains: query)
          .getDocuments();
        for (int i = 0; i < users.documents.length; i++) {
          userQueryResultSet.add(users.documents[i]);
        }
        QuerySnapshot posts = await allPostsRef
          .where('searchKeys', arrayContains: query)
          .getDocuments();
        for (int i = 0; i < posts.documents.length; i++) {
          postQueryResultSet.add(posts.documents[i]);
        }
      }
      searchResults = {};
      tempStore = [];
      finalSearchResults = [];
      userSearchResults = [];
      postSearchResults = [];
      userQueryResultSet.forEach((user) {
        if (user.data['displayName'].toLowerCase().startsWith(query)
            || user.data['username'].toLowerCase().startsWith(query)) {
          User deSerializedUser = User.fromDocument(user);
          UserResult searchResult = UserResult(deSerializedUser, query: query);
          userSearchResults.add(searchResult);
          tempStore.add(user.data['displayName']);
        }
        if ((user.data['displayName'].toLowerCase().contains(query)
            || user.data['username'].toLowerCase().contains(query))
            && !tempStore.contains(user.data['displayName'])) {
          User deSerializedUser = User.fromDocument(user);
          UserResult searchResult = UserResult(deSerializedUser, query: query);
          userSearchResults.add(searchResult);
        }
      });
      postQueryResultSet.forEach((post) {
        if (post.data['caption'].toLowerCase().startsWith(query)) {
          Post deSerializedPost = Post.fromDocument(post);
          PostResult searchResult = PostResult(deSerializedPost, query);
          postSearchResults.add(searchResult);
          tempStore.add(post.data['postId']);
        }
        if (post.data['caption'].toLowerCase().contains(query)
            && !tempStore.contains(post.data['postId'])) {
          Post deSerializedPost = Post.fromDocument(post);
          PostResult searchResult = PostResult(deSerializedPost, query);
          postSearchResults.add(searchResult);
        }
      });
      setState(() {
        searchResults.addAll({'people': userSearchResults});
        if (searchResults['people'].isNotEmpty) {
          finalSearchResults.add(searchTitle('People'));
        }
        searchResults['people'].forEach((res) => finalSearchResults.add(res));
        searchResults.addAll({'posts': postSearchResults});
        if (searchResults['posts'].isNotEmpty) {
          finalSearchResults.add(searchTitle('Posts'));
        }
        searchResults['posts'].forEach((res) => finalSearchResults.add(res));
        _isLoading = false;
      });

    } else { clearSearch(); }
  }

  clearSearch() {
    setState(() {
      searchController.clear();
      userQueryResultSet.clear();
      postQueryResultSet.clear();
      searchResults.clear();
      finalSearchResults.clear();
      userSearchResults.clear();
      postSearchResults.clear();
    });
  }

  Widget searchTitle(String title) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0
        )
      )
    );
  }

  AppBar buildSearchField() {
    return AppBar(
     backgroundColor: Colors.white,
     title: TextField(
       controller: searchController,
       decoration: InputDecoration(
         hintText: 'Search for a user...',
         filled: true,
         prefixIcon: Icon(
           Icons.account_box,
           size: 28.0
         ),
         suffixIcon: IconButton(
           icon: Icon(Icons.clear),
           onPressed: clearSearch,
         )
       ),
       maxLines: null,
       onChanged: handleSearch,
     )
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0
            ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0
              )
            )
          ]
        )
      )
    );
  }

  buildSearchResults() {
    return _isLoading ? circularProgress(context) : ListView(
      children: finalSearchResults
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResults.isEmpty ? buildNoContent() : buildSearchResults()
    );
  }
}

class UserResult extends StatelessWidget {
  final String query;
  final User user;

  UserResult(this.user, {this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl)
              ),
              title: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                  children: highlightChars(context, user.displayName, query)
                )
              ),
              subtitle: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                  children: highlightChars(context, user.username, query),
                )
              )
            )
          ),
          Divider(
            height: 2.0,
            color: Colors.white54
          )
        ],
      )
    );
  }
}

class PostResult extends StatelessWidget {
  final Post post;
  final String query;

  PostResult(this.post, this.query);

  Widget buildPostTitle() {
    return FutureBuilder(
      future: usersRef.document(post.ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress(context);
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: configurePostTitle(
            context,
            post.displayName,
            post.ownerId,
            post.feelingOrActivity,
            post.taggedPeople
          ),
          subtitle: Text(post.location),
        );
      }
    );
  }

  Widget buildMedia(context) {
    return GestureDetector(
      onTap: () => showPost(context, post.postId, post.ownerId),
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        width: 50.0,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(post.mediaUrl[0])
              )
            )
          ),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {},
      color: Colors.white,
      elevation: 5.0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        buildPostTitle(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.0),
                          child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              style: TextStyle(fontSize: 14.0, color: Colors.black),
                              children: buildCaption(context, post.caption)
                            )
                          )
                        )
                      ],
                    )
                  )
                ),
                post.mediaUrl.isNotEmpty ? buildMedia(context) : Text(''),
              ],
            )
          )
        ],
      )
    );
  }
}

List<TextSpan> highlightChars(BuildContext context, String str, String query) {
  List<TextSpan> formattedString = List<TextSpan>();
  for (int i = 0; i < str.length; i++) {
    if (query.contains(str[i])) {
      formattedString.add(
        TextSpan(
          text: str[i],
          style: TextStyle(backgroundColor: Theme.of(context).primaryColor)
        )
      );
    } else {
      formattedString.add(TextSpan(text: str[i]));
    }
  }
  return formattedString;
}
