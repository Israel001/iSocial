import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isocial/helpers/quotes.dart';
import 'package:isocial/widgets/accordion.dart';
import 'package:isocial/widgets/header.dart';

import '../../main.dart';

class Quotes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuotesState();
  }
}

class _QuotesState extends State<Quotes> {
  final MethodChannel platform = MethodChannel(
    'crossingthestreams.io/resourceResolver'
  );

  @override
  void initState() {
    super.initState();
    _configureSelectNotificationSubject();
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((payload) async {
      print(payload);
    });
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Welcome To Quotes Center'),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) => Accordion(quotes[index]),
        itemCount: quotes.length
      )
    );
  }
}
