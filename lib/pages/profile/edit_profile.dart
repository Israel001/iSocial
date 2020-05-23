import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isocial/widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:isocial/models/user.dart';

import 'package:isocial/pages/home/home.dart';

import 'package:isocial/widgets/progress.dart';
import 'package:native_state/native_state.dart';

import 'package:isocial/pages/auth/auth.dart';

class EditProfile extends StatefulWidget {
  static const String route = '/edit_profile';

  final SavedStateData savedState;
  final String currentUserId;

  EditProfile({ this.currentUserId, this.savedState });

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController smsCodeController = TextEditingController();
  bool isLoading = false;
  bool isUpdating = false;
  bool _obscureText = true;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;
  bool _emailValid = true;
  bool _usernameValid = true;
  bool _mobileValid = true;
  bool _passwordValid = true;
  String _displayNameErrorMsg = '';
  String _bioErrorMsg = '';
  String _emailErrorMsg = '';
  String _usernameErrorMsg = '';
  String _mobileErrorMsg = '';
  String _passwordErrorMsg = '';

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() { isLoading = true; });
    prefs = await SharedPreferences.getInstance();
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    usernameController.text = user.username;
    mobileController.text = user.mobile;
    emailController.text = user.email;
    passwordController.text = prefs.getString('password') ?? '';
    bioController.text = user.bio;
    setState(() { isLoading = false; });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Display Name',
            style: TextStyle(color: Colors.grey)
          )
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: 'Update Display Name',
            errorText: _displayNameValid ? null : _displayNameErrorMsg
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Bio',
            style: TextStyle(color: Colors.grey)
          )
        ),
        TextField(
          controller: bioController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Update Bio',
            errorText: _bioValid ? null : _bioErrorMsg
          ),
        )
      ],
    );
  }

  Column buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Email Address',
            style: TextStyle(color: Colors.grey)
          )
        ),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'Update Email Address',
            errorText: _emailValid ? null : _emailErrorMsg
          ),
        )
      ],
    );
  }

  Column buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
           'Username',
            style: TextStyle(color: Colors.grey)
          )
        ),
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: 'Update Username',
            errorText: _usernameValid ? null : _usernameErrorMsg
          ),
        )
      ],
    );
  }

  Column buildMobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
           'Phone Number',
            style: TextStyle(color: Colors.grey)
          )
        ),
        TextField(
          controller: mobileController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Update Phone Number',
            errorText: _mobileValid ? null : _mobileErrorMsg
          ),
        )
      ],
    );
  }

  Column buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
           'Password',
            style: TextStyle(color: Colors.grey)
          )
        ),
        TextField(
          controller: passwordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: 'Update Password',
            errorText: _passwordValid ? null : _passwordErrorMsg,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => this._obscureText = !_obscureText ),
              child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility)
            )
          ),
        )
      ],
    );
  }

  validateDisplayName() {
    setState(() {
      if (displayNameController.text.isEmpty) {
        _displayNameErrorMsg = 'This field cannot be blank';
      } else if (displayNameController.text.trim().length < 3) {
        _displayNameErrorMsg = 'Display name is too short';
      } else if (displayNameController.text.trim().length > 30) {
        _displayNameErrorMsg = 'Display name is too long';
      } else if (!RegExp(r'^[a-zA-Z\s]{0,255}$')
          .hasMatch(displayNameController.text)) {
        _displayNameErrorMsg = 'Name must contain alphabets ONLY';
      } else { _displayNameErrorMsg = ''; }
      _displayNameValid = _displayNameErrorMsg.isEmpty ? true : false;
    });
  }

  validateUsername() {
    setState(() {
      if (usernameController.text.isEmpty) {
        _usernameErrorMsg = 'This field cannot be blank';
      } else if (usernameController.text.trim().length < 4) {
        _usernameErrorMsg = 'Username is too short';
      } else if (usernameController.text.trim().length > 12) {
        _usernameErrorMsg = 'Username is too long';
      } else if (!RegExp(r'[a-zA-Z0-9]').hasMatch(usernameController.text)) {
        _usernameErrorMsg = 'Username must contain alphanumerics ONLY';
      } else { _usernameErrorMsg = ''; }
      _usernameValid = _usernameErrorMsg.isEmpty ? true : false;
    });
  }

  validateMobile() {
    setState(() {
      if (mobileController.text.isNotEmpty
          && !RegExp(r'[+0-9]').hasMatch(mobileController.text)) {
        _mobileErrorMsg = 'Invalid phone number';
      } else { _mobileErrorMsg = ''; }
      _mobileValid = _mobileErrorMsg.isEmpty ? true : false;
    });
  }

  validateEmail() {
    setState(() {
      if (emailController.text.isEmpty) {
        _emailErrorMsg = 'This field cannot be blank';
      } else if (!RegExp(
          r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
          r"*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*["
          r"a-z0-9])?"
      ).hasMatch(emailController.text)) {
        _emailErrorMsg = 'Invalid email';
      } else { _emailErrorMsg = ''; }
      _emailValid = _emailErrorMsg.isEmpty ? true : false;
    });
  }

  validatePassword() {
    setState(() {
      if (prefs.getString('signInMethod') != 'password') {
        _passwordErrorMsg = '';
      } else if (passwordController.text.isEmpty) {
        _passwordErrorMsg = 'This field cannot be blank';
      } else if (passwordController.text.trim().length < 8) {
        _passwordErrorMsg = 'Password is too short';
      } else if (passwordController.text.trim().length > 30) {
        _passwordErrorMsg = 'Password is too long';
      } else if (!RegExp(
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$'
      ).hasMatch(passwordController.text)) {
        _passwordErrorMsg = 'Password is too weak';
      } else { _passwordErrorMsg = ''; }
      _passwordValid = _passwordErrorMsg.isEmpty ? true : false;
    });
  }

  validateBio() {
    setState(() {
      if (bioController.text.trim().length > 100) {
        _bioErrorMsg = 'Bio is too long';
      } else { _bioErrorMsg = ''; }
      _bioValid = _bioErrorMsg.isEmpty ? true : false;
    });
  }

  Future<bool> checkForDuplicate() async {
    bool duplicate = true;
    QuerySnapshot usernameQuerySnapshot = await usersRef
      .where('username', isEqualTo: usernameController.text)
      .getDocuments();
    QuerySnapshot mobileQuerySnapshot = await usersRef
      .where('mobile', isEqualTo: mobileController.text)
      .getDocuments();
    QuerySnapshot emailQuerySnapshot = await usersRef
      .where('email', isEqualTo: emailController.text)
      .getDocuments();
    if (currentUser.username.trim() != usernameController.text.trim()
        && usernameQuerySnapshot.documents.length > 0
        && usernameController.text.trim().length > 0) {
      SnackBar snackBar = snackbar(
        msg: 'The username provided already exists',
        bgColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 5000)
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return duplicate;
    } else if (currentUser.mobile != mobileController.text.trim()
        && mobileQuerySnapshot.documents.length > 0
        && mobileController.text.trim().length > 0) {
      SnackBar snackBar = snackbar(
        msg: 'The phone number provided already exists',
        bgColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 5000)
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return duplicate;
    } else if (currentUser.email.trim() != emailController.text.trim()
        && emailQuerySnapshot.documents.length > 0
        && emailController.text.trim().length > 0) {
      SnackBar snackBar = snackbar(
        msg: 'The email provided already exists',
        bgColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 5000)
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return duplicate;
    } else { return !duplicate; }
  }

  updateProfileData() async {
    setState(() { isUpdating = true; });

    validateDisplayName();
    validateUsername();
    validateMobile();
    validateEmail();
    validatePassword();
    validateBio();

    bool isDuplicate;
    isDuplicate = await checkForDuplicate();

    if (_displayNameValid && _usernameValid && _mobileValid && _emailValid
        && _passwordValid && _bioValid) {
      if (!isDuplicate) {
        String combinedStr = displayNameController.text + usernameController.text;
        List<String> searchKeys = extractUniqueChars(combinedStr);
        usersRef.document(widget.currentUserId).updateData({
          'displayName': displayNameController.text,
          'username': usernameController.text,
          'mobile': mobileController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'bio': bioController.text,
          'searchKeys': searchKeys
        });
        currentUser = User.fromDocument(
          await usersRef.document(widget.currentUserId).get()
        );
        SnackBar snackBar = SnackBar(content: Text('Profile Updated!'));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }

    setState(() { isUpdating = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black)
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.green
            )
          )
        ],
      ),
      body: isLoading ? circularProgress(context) : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: 8.0
                  ),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl)
                  )
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      buildDisplayNameField(),
                      buildUsernameField(),
                      buildMobileField(),
                      buildEmailField(),
                      buildPasswordField(),
                      buildBioField()
                    ],
                  )
                ),
                isUpdating ? circularProgress(context) : RaisedButton(
                  onPressed: updateProfileData,
                  child: Text(
                    'Update Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  color: Theme.of(context).cardColor,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FlatButton.icon(
                    onPressed: () => logout(
                      context,
                      savedState: widget.savedState,
                      prefs: prefs
                    ),
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.red
                    ),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0
                      )
                    )
                  )
                )
              ],
            )
          )
        ],
      )
    );
  }
}

List<String> extractUniqueChars(String str) {
  str = str.toLowerCase();
  Map temp = {};
  for (int index = 0; index < str.length; index++) {
    temp[str[index]] = 0;
  }
  String uniqChars = temp.keys.join('').replaceAll(' ', '');
  List<String> keys = [];
  for (int i = 0; i < uniqChars.length; i++) {
    if(RegExp(r'[#a-z]').hasMatch(uniqChars[i])) keys.add(uniqChars[i]);
  }
  return keys;
}

logout(context, {SavedStateData savedState, SharedPreferences prefs}) async {
  if (prefs.getString('signInMethod') == 'password') {
    await firebaseAuth.signOut();
    prefs.setString('userId', null);
    prefs.setString('password', null);
  } else { await googleSignIn.signOut(); }
  pageController.jumpToPage(0);
  Navigator.pop(context);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      settings: RouteSettings(name: Auth.route),
      builder: (context) => Auth(savedState: savedState)
    )
  );
}
