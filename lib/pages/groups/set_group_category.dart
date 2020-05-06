import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:isocial/helpers/categories.dart';

class SetGroupCategory extends StatefulWidget {
  final String selectedGroupCategory;

  SetGroupCategory({ this.selectedGroupCategory });

  @override
  State<StatefulWidget> createState() {
    return SetGroupCategoryState(isSelected: selectedGroupCategory);
  }
}

class SetGroupCategoryState extends State<SetGroupCategory> with
  AutomaticKeepAliveClientMixin<SetGroupCategory> {
  String isSelected;

  SetGroupCategoryState({ this.isSelected });

  toggleSelected(String category) {
    if (isSelected == category) {
      isSelected = '';
    } else {
      isSelected = category;
    }
    setState(() {});
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, isSelected);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Group Categories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0
            )
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context, isSelected),
              icon: Icon(
                Icons.done,
                size: 30.0,
                color: Colors.white
              )
            )
          ],
        ),
        body: ListView(
          children: List.generate(categoryTitles.length, (index) {
            return Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 10.0)),
                GestureDetector(
                  onTap: () => toggleSelected(categoryTitles[index]),
                  child: Row(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(left: 10.0)),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected == categoryTitles[index]
                                ? Theme.of(context).cardColor : Colors.white,
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: isSelected == categoryTitles[index]
                              ? Icon(Icons.done, color: Colors.white, size: 15.0)
                              : Text('')
                        )
                      ),
                      Padding(padding: EdgeInsets.only(left: 10.0)),
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          categoryImgUrls[index]
                        )
                      ),
                      Padding(padding: EdgeInsets.only(left: 10.0)),
                      Text(categoryTitles[index])
                    ],
                  )
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),
                Divider()
              ],
            );
          })
        )
      )
    );
  }
}
