import 'package:flutter/material.dart';
import 'camera_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hand Gesture Recognition'),
        ),
        body: CameraView(),
      ),
    );
  }
}
