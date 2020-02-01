import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class Zoomable extends StatefulWidget {
  final Widget child;

  Zoomable({Key key, this.child}) : super(key: key);

  @override
  _ZoomableState createState() => _ZoomableState();
}

class _ZoomableState extends State<Zoomable> {
  Matrix4 matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return MatrixGestureDetector(
      onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
        setState(() {
          matrix = m;
        });
      },
      child: Transform(
        transform: matrix,
        child: widget.child
      )
    );
  }
}