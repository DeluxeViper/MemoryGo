import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  int currentPageNumber;
  final List<PageModel> pageList = [
    // Study Set List introduction
    PageModel(
        color: Colors.lightBlue,
        title: Text('Study Sets'),
        body: Text('Description of study sets'),
        heroAssetPath: 'assets/icons/notebook_icon.png',
        iconAssetPath: 'assets/icons/notebook_icon.png'),
    // Notes list introduction
    PageModel(
        color: Colors.lightBlue,
        heroAssetPath: 'assets/icons/note-icon.png',
        iconAssetPath: 'assets/icons/note-icon.png',
        title: Text('Notes'),
        body: Text('Description of notes')),
    // Settings of study set
    PageModel(
      color: Colors.lightBlue,
      heroAssetPath: 'assets/icons/app_icon.png',
      iconAssetPath: 'assets/icons/app_icon.png',
      title: Text('Settings'),
      body: Text('Description of Settings'),
    ),
    // Popup introduction
    PageModel(
        color: Colors.lightBlue,
        heroAssetPath: 'assets/icons/app_icon.png',
        iconAssetPath: 'assets/icons/app_icon.png',
        title: Text('Pop up Introduction'),
        body: Text('Description of Popup')),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onHorizontalDragEnd: (details) => print(details),
      child: FancyOnBoarding(
        doneButtonText: "Done",
        skipButtonText: "Skip",
        onDoneButtonPressed: () =>
            Navigator.of(context).pushReplacementNamed('homepage'),
        onSkipButtonPressed: () =>
            Navigator.of(context).pushReplacementNamed('homepage'),
        pageList: pageList,
      ),
    ));
  }
}
