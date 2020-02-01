import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:isocial/pages/splash_screen.dart';

void main() {
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then(
    (_) {
      print('Timestamps enabled in snapshots\n');
    }, onError: (_) {
      print('Error enablings timestamps in snapshots\n');
    }
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iSocial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.orange
      ),
      home: SplashScreen(),
    );
  }
}