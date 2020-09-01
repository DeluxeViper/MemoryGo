import 'package:MemoryGo/model/StudySet.dart';
import 'package:flutter/material.dart';

import '../utils/database_helper.dart';

class AddStudySet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddStudySetState();
}

class AddStudySetState extends State<AddStudySet> {
  TextEditingController nameOfSetController = new TextEditingController();
  DatabaseHelper helper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Create New Study Set"),
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () => _addSet(),
                  child: Icon(Icons.keyboard_arrow_right)))
        ],
      ),
      body: new Column(
        children: <Widget>[
          // Title of Study Set
          new Padding(
              padding: EdgeInsets.all(10),
              child: new TextField(
                autocorrect: false,
                controller: nameOfSetController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Study Set Name'),
                onSubmitted: (value) => _addSet(),
              )),
        ],
      ),
    );
  }

  void _addSet() async {
    print('Adding set');
    StudySet studySet = new StudySet('', 0);
    int result;
    studySet.title = nameOfSetController.text;
    if (studySet.id != null) {
      // Case 1: Update Operation -> Studyset exists
      result = await helper.updateStudySet(studySet);
    } else {
      result = await helper.insertStudySet(studySet);
    }

    if (result != 0) {
      // Success
      print('Studyset saved Successfully.');
      // _showAlertDialog('Status', 'Studyset saved Successfully.');
    } else {
      // Failure
      print('Problem saving Studyset.');
      // _showAlertDialog('Status', 'Problem saving Studyset.');
    }

    // Update list with studyset and return back to the page
    Navigator.pop(context, true);
  }
}
