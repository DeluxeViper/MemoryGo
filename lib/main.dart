import 'package:MemoryGo/constants.dart';
import 'package:MemoryGo/screens/home/studyset_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MemoryGoApp());
}

class MemoryGoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoryGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StudySetList(title: 'MemoryGo'),
    );
  }
}
