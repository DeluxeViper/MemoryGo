import 'package:MemoryGo/constants.dart';
import 'package:flutter/material.dart';

class AppSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context, false),
            ),
            backgroundColor: Colors.white,
            title: Text(
              'App Settings',
              style: TextStyle(color: kPrimaryColor),
            )),
        body: Container());
  }
}
