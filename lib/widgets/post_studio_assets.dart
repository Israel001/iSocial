import 'package:flutter/material.dart';
import 'package:flutter_facebook_image_picker/model/photo.dart';
import 'package:isocial/widgets/video_player_widget.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'custom_image.dart';

class PostStudioAssets extends StatefulWidget {
  final List<dynamic> assets;

  PostStudioAssets({this.assets});

  @override
  State<StatefulWidget> createState() {
    return PostStudioAssetsState(assets: this.assets);
  }
}

class PostStudioAssetsState extends State<PostStudioAssets> {
  List<dynamic> assets;

  PostStudioAssetsState({this.assets});

  removeAsset(index) {
    List<dynamic> clonedAssets = List<dynamic>.from(assets);
    clonedAssets.removeAt(index);
    setState(() { assets = clonedAssets; });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, assets);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'Uploaded Assets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0
            )
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context, assets),
              icon: Icon(
                Icons.done,
                size: 30.0,
                color: Colors.white
              )
            )
          ],
        ),
        body: ListView(
          children: List.generate(assets.length, (index) {
            dynamic asset = assets[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () { removeAsset(index); },
                  )
                ),
                Container(
                  child: asset.runtimeType == Asset ? AssetThumb(
                      asset: asset,
                      width: MediaQuery.of(context).size.width.toInt(),
                      height: MediaQuery.of(context).size.width.toInt()
                  ) : asset.runtimeType == Photo ? Image.network(
                      asset.source
                  ) : asset.runtimeType == String && !asset.contains('mp4')
                      ? cachedNetworkImage(context, asset)
                    : asset.runtimeType == String && asset.contains('mp4')
                      ? VideoPlayerWidget(videoType: 'network', video: asset)
                    : VideoPlayerWidget(
                      videoType: 'file',
                      video: asset
                  )
                )
              ]
            );
          })
        )
      )
    );
  }
}