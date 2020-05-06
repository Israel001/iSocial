import 'package:flutter/material.dart';

SnackBar snackbar ({ String msg, Color bgColor, Duration duration }) {
  return SnackBar(
    content: Text(msg, overflow: TextOverflow.ellipsis),
    backgroundColor: bgColor,
    duration: duration
  );
}