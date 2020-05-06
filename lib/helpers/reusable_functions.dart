import 'package:flutter/material.dart';

groupVisibilityBottomSheet({
  BuildContext context,
  double contentHeight,
  bool invisibility,
  Function callback1,
  Function callback2
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: contentHeight,
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 10.0)),
                Icon(Icons.close),
                Padding(padding: EdgeInsets.only(left: 120.0)),
                Text(
                  'Hide group',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  )
                )
              ]
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 0.0
              ),
              child: Divider()
            ),
            ListTile(
              onTap: () {
                callback1();
                Navigator.pop(context);
              },
              leading: Icon(
                Icons.visibility,
                color: Colors.black,
                size: 30.0
              ),
              title: Text(
                'Visible',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0
                )
              ),
              subtitle: Text('Anyone can find this group'),
              trailing: Icon(
                invisibility
                  ? Icons.radio_button_unchecked : Icons.radio_button_checked,
                color: Theme.of(context).accentColor,
              ),
            ),
            ListTile(
              onTap: () {
                callback2();
                Navigator.pop(context);
              },
              leading: Icon(
                Icons.visibility_off,
                color: Colors.black,
                size: 30.0
              ),
              title: Text(
                'Hidden',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0
                )
              ),
              subtitle: Text('Only members can find this group'),
              trailing: Icon(
                invisibility
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
                color: Theme.of(context).accentColor
              )
            )
          ]
        )
      );
    }
  );
}

bottomSheetWithTwoOptions({
  BuildContext context,
  double contentHeight,
  String titleText,
  IconData icon1,
  IconData icon2,
  String optionText1,
  String optionText2,
  bool option1Selected,
  Function callback1,
  Function callback2
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: contentHeight,
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              titleText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              )
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            ListTile(
              onTap: () {
                callback1();
                Navigator.pop(context);
              },
              leading: Icon(
                icon1,
                color: Colors.black,
                size: 30.0
              ),
              title: Text(
                optionText1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0
                )
              ),
              trailing: Icon(
                option1Selected
                  ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: Theme.of(context).accentColor,
              ),
            ),
            ListTile(
              onTap: () {
                callback2();
                Navigator.pop(context);
              },
              leading: Icon(
                icon2,
                color: Colors.black,
                size: 30.0
              ),
              title: Text(
                optionText2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0
                )
              ),
              trailing: Icon(
                option1Selected
                  ? Icons.radio_button_unchecked
                  : Icons.radio_button_checked,
                color: Theme.of(context).accentColor
              )
            )
          ]
        )
      );
    }
  );
}

bottomSheetWithTwoOptionsAndTitleDesc({
  BuildContext context,
  double contentHeight,
  String titleText,
  String titleDesc,
  IconData icon1,
  IconData icon2,
  String optionText1,
  String optionText2,
  bool option1Selected,
  Function callback1,
  Function callback2
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: contentHeight,
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              titleText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              )
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            Expanded(
              child: Text(
                titleDesc,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 17.0
                )
              )
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            ListTile(
              onTap: () {
                callback1();
                Navigator.pop(context);
              },
              leading: Icon(
                icon1,
                color: Colors.black,
                size: 30.0
              ),
              title: Text(
                optionText1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0
                )
              ),
              trailing: Icon(
                option1Selected
                  ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: Theme.of(context).accentColor,
              ),
            ),
            ListTile(
              onTap: () {
                callback2();
                Navigator.pop(context);
              },
              leading: Icon(
                icon2,
                color: Colors.black,
                size: 30.0
              ),
              title: Text(
                optionText2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0
                )
              ),
              trailing: Icon(
                option1Selected
                  ? Icons.radio_button_unchecked
                  : Icons.radio_button_checked,
                color: Theme.of(context).accentColor
              )
            )
          ]
        )
      );
    }
  );
}

bottomSheetWithTwoOptionsTitleDescAndOptionDesc({
  BuildContext context,
  double contentHeight,
  String titleText,
  String titleDesc,
  IconData icon1,
  IconData icon2,
  String optionText1,
  String optionText2,
  String optionDesc1,
  String optionDesc2,
  bool option1Selected,
  Function callback1,
  Function callback2
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: contentHeight,
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              titleText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              )
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            Expanded(
              child: Text(
                titleDesc,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 17.0
                )
              )
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            ListTile(
              onTap: () {
                callback1();
                Navigator.pop(context);
              },
              leading: Icon(
                icon1,
                color: Colors.black,
                size: 30.0
              ),
              title: Text(
                optionText1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0
                )
              ),
              subtitle: Text(
                optionDesc1,
                style: TextStyle(color: Colors.grey)
              ),
              trailing: Icon(
                option1Selected
                  ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: Theme.of(context).accentColor,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            ListTile(
              onTap: () {
                callback2();
                Navigator.pop(context);
              },
              leading: Icon(
                icon2,
                color: Colors.black,
                size: 30.0
              ),
              title: Text(
                optionText2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0
                )
              ),
              subtitle: Text(
                optionDesc2,
                style: TextStyle(color: Colors.grey)
              ),
              trailing: Icon(
                option1Selected
                  ? Icons.radio_button_unchecked
                  : Icons.radio_button_checked,
                color: Theme.of(context).accentColor
              )
            )
          ]
        )
      );
    }
  );
}

List<Widget> displayExampleRules(Function callback) {
  Map<String, String> rules = {
    'title0': 'Be kind and courteous',
    'title1': 'No hate speech and bullying',
    'title2': 'No promotions or spam',
    'title3': "Respect everyone's privacy",
    'details0': "We're all in this together to create a welcoming environment. "
        "Let's treat everyone with respect. Healthy debates are natural, but "
        "kindness is required.",
    'details1': "Make sure that everyone feels safe. Bullying of any kind isn't"
        "allowed, and degrading comments about things such as race, religion, "
        "culture, sexual orientation, gender or identity will not be tolerated.",
    'details2': "Give more to this group than you take. Self-promotion, spam "
        "and irrelevant links aren't allowed.",
    'details3': "Being part of this group requires mutual trust. Authentic, "
        "expressive discussions make groups great, but may also be sensitive "
        "and private. What's shared in the group should stay in the group."
  };
  List<Widget> widgetsList = [];
  for (int i = 0; i < rules.length / 2; i++) {
    widgetsList.add(Column(
      children: <Widget>[
        ListTile(
          title: Text(
            rules['title$i'],
            style: TextStyle(fontWeight: FontWeight.bold)
          ),
          subtitle: Text(rules['details$i']),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => callback(rules['title$i'], rules['details$i']),
        ),
        Divider()
      ]
    ));
  }
  return widgetsList;
}

convertFirstLetterToUppercase(String text) => text[0].toUpperCase() + text.substring(1);
