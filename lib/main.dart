import 'package:flutter/material.dart';
import 'package:pathbuilder/path_builder.dart';

void main() {
  runApp(const PathBuilderApp());
}

class PathBuilderApp extends StatelessWidget {
  const PathBuilderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PathBuilder(),
    );
  }
}
