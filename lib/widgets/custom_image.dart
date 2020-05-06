import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(context, mediaUrl, {double height}) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    width: MediaQuery.of(context).size.width,
    height: height,
    placeholder: (context, url) => Padding(
      child: SizedBox(
        height: 50.0,
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).accentColor
        )
      ),
      padding: EdgeInsets.all(20.0)
    ),
    errorWidget: (context, url, error) => Icon(Icons.error)
  );
}