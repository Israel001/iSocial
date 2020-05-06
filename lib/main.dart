import 'package:flutter/material.dart';

import 'package:native_state/native_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

import 'package:isocial/helpers/adaptive_theme.dart';

import 'package:isocial/pages/auth/create_account.dart';
import 'package:isocial/pages/profile/edit_profile.dart';
import 'package:isocial/pages/auth/auth.dart';
import 'package:isocial/pages/auth/login.dart';
import 'package:isocial/pages/profile/profile.dart';
import 'package:isocial/pages/auth/sign_up.dart';
import 'package:isocial/pages/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('launcher_icon');

  var initializationSettingsIOS = IOSInitializationSettings();

  var initializationSettings = InitializationSettings(
    initializationSettingsAndroid, initializationSettingsIOS
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (payload) async {
      selectNotificationSubject.add(payload);
    }
  );

  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);

  runApp(SavedState(child: iSocial()));
}

// ignore: camel_case_types
class iSocial extends StatelessWidget {
  static var brightness = 'light';

  @override
  Widget build(BuildContext context) {
    var savedState = SavedState.of(context);
    return MaterialApp(
      title: 'iSocial',
      debugShowCheckedModeBanner: false,
      theme: getAdaptiveThemeData(brightness),
      navigatorKey: GlobalKey(),
      navigatorObservers: [ SavedStateRouteObserver(savedState: savedState) ],
      routes: {
        Auth.route: (context) => SavedState.builder(
          builder: (context, savedState) => Auth(savedState: savedState)
        ),
        SignUp.route: (context) => SavedState.builder(
          builder: (context, savedState) => SignUp(savedState: savedState)
        ),
        Login.route: (context) => SavedState.builder(
          builder: (context, savedState) => Login(savedState: savedState)
        ),
        CreateAccount.route: (context) => SavedState.builder(
          builder: (context, savedState) => CreateAccount(savedState: savedState)
        ),
        Profile.route: (context) => SavedState.builder(
          builder: (context, savedState) => Profile(savedState: savedState)
        ),
        EditProfile.route: (context) => SavedState.builder(
          builder: (context, savedState) => EditProfile(savedState: savedState)
        ),
      },
      initialRoute: SavedStateRouteObserver.restoreRoute(savedState) ?? '/',
      home: SavedState.builder(
        builder: (context, savedState) => SplashScreen(
          context,
          savedState: savedState
        )
      ),
    );
  }
}
