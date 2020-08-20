import 'dart:ui';
import 'package:first_app/pages/add_study_set_page.dart';
import 'package:flutter/material.dart';
import './study_set.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoryGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'MemoryGo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  static List<StudySet> studySets = [];

  void goToAddSetPage() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddSet(this),
    ));
  }

  void addToStudySet(StudySet studySet) {
    setState(() {
      studySets.add(studySet);
    });
  }

  void deleteStudySet(StudySet studySet) {
    setState(() {
      studySets.remove(studySet);
    });
    print(studySets);
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(title: Text(widget.title));

    return Scaffold(
      appBar: appBar,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Title
            new Container(
                margin: new EdgeInsets.only(top: 30.0, left: 10.0),
                child: Text(
                  'Study Sets',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                )),
            // Cards
            Expanded(
                child: ListView.builder(
                    itemCount: studySets.length,
                    itemBuilder: (BuildContext context, int index) {
                      return studySets.elementAt(index);
                    }))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToAddSetPage(),
        tooltip: 'Add Study Set',
        child: Icon(Icons.add),
      ),
    );
  }
}
