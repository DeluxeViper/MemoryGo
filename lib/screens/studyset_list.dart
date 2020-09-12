import 'package:MemoryGo/constants.dart';
import 'package:MemoryGo/utils/database_helper.dart';
import 'package:MemoryGo/model/StudySet.dart';
import 'package:MemoryGo/screens/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'notes_page.dart';

class StudySetList extends StatefulWidget {
  StudySetList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  StudySetListState createState() => StudySetListState();
}

class StudySetListState extends State<StudySetList> {
  static DatabaseHelper databaseHelper = DatabaseHelper();
  final TextEditingController nameOfSetController = new TextEditingController();
  static List<StudySet> studySets;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(title: Text(widget.title));
    if (studySets == null) {
      studySets = List<StudySet>();
      updateListView();
    }
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
                child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Study Sets',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ))),
            // Cards
            Expanded(child: getStudySetListView())
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addStudySetModalBottomSheet(context),
        tooltip: 'Add Study Set',
        child: Icon(Icons.add),
      ),
    );
  }

  // Displays studyset list
  ListView getStudySetListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: studySets.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              width: double.infinity,
              margin: EdgeInsets.all(20.0),
              child: Card(
                  child: InkWell(
                      splashColor: Colors.blue.withAlpha(20),
                      onTap: () {
                        openNotesPage(studySets[index]);
                      },
                      // Study set
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Title of study set
                          new Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(studySets[index].title,
                                  style: TextStyle(fontSize: 20))),
                          // Date of study set
                          new Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(studySets[index].date)),
                          // Number of cards
                          new Padding(
                              padding: EdgeInsets.all(10.0),
                              child:
                                  Text(studySets[index].numCards.toString())),
                          // Delete and settings page icons
                          new Padding(
                              padding: EdgeInsets.all(10.0),
                              child: new Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  new GestureDetector(
                                      onTap: () =>
                                          openSettingsPage(studySets[index]),
                                      child: Icon(
                                        Icons.settings,
                                        semanticLabel: 'Study set settings',
                                      )),
                                  new SizedBox(height: 10.0, width: 10.0),
                                  new GestureDetector(
                                      onTap: () {
                                        showAlertDialog(context, index);
                                      },
                                      child: Icon(Icons.delete,
                                          semanticLabel: 'Delete Study set'))
                                ],
                              ))
                        ],
                      ))));
        });
  }

  void addStudySetModalBottomSheet(BuildContext context) {
    nameOfSetController.text = '';
    showModalBottomSheet(
        enableDrag: true,
        isScrollControlled: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (BuildContext context) {
          return new Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Title of Study Set
                  new Padding(
                      padding: EdgeInsets.all(10),
                      child: new TextField(
                          autocorrect: false,
                          controller: nameOfSetController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Study Set Name'),
                          onSubmitted: (value) {
                            print("submitted");
                            _addSet();
                            nameOfSetController.text = '';
                          })),
                  new RaisedButton(
                    onPressed: () {
                      _addSet();
                      nameOfSetController.text = '';
                    },
                    color: kPrimaryColor,
                    child: Text("Add Study Set"),
                  ),
                ],
              ));
        });
  }

  void _addSet() async {
    print('Adding set');
    StudySet studySet = new StudySet('', 0);
    int result;
    studySet.title = nameOfSetController.text;
    if (studySet.id != null) {
      // Case 1: Update Operation -> Studyset exists
      result = await databaseHelper.updateStudySet(studySet);
    } else {
      result = await databaseHelper.insertStudySet(studySet);
    }

    if (result != 0) {
      // Success
      print('Studyset saved Successfully.');
      updateListView();
      // _showAlertDialog('Status', 'Studyset saved Successfully.');
    } else {
      // Failure
      print('Problem saving Studyset.');
      // _showAlertDialog('Status', 'Problem saving Studyset.');
    }

    // Update list with studyset and return back to the page
    Navigator.pop(context, true);
  }

  showAlertDialog(BuildContext context, int index) {
    AlertDialog alert = new AlertDialog(
      title: Text("Delete Study Set"),
      content: Text("Are you sure you want to delete this study set?"),
      actions: [
        FlatButton(
            child: Text("Yes"),
            color: Colors.green,
            onPressed: () {
              _delete(context, studySets[index]);
              Navigator.of(context).pop();
            }),
        FlatButton(
            color: Colors.red,
            child: Text("No"),
            onPressed: () => Navigator.of(context).pop())
      ],
      elevation: 20.0,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  // deletes studyset
  void _delete(BuildContext context, StudySet studySet) async {
    int result = await databaseHelper.deleteStudySet(studySet.id);
    if (result != 0) {
      _showSnackbar(context, 'StudySet deleted Successfully.');
      updateListView();
    } else {
      _showSnackbar(context, 'Error deleting Studyset.');
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<StudySet>> studySetListFuture =
          databaseHelper.getStudySetList();
      studySetListFuture.then((studySetList) {
        setState(() {
          studySets = studySetList;
          count = studySetList.length;
        });
      });
    });
  }

  void openSettingsPage(StudySet studySet) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => new SettingsPage(studySet)));
  }

  // void goToAddSetPage() async {
  //   // bool result = await Navigator.of(context).push(MaterialPageRoute(
  //   //   builder: (context) => AddStudySet(),
  //   // ));

  //   bool result = addStudySetModalBottomSheet(context);
  //   print("Add study set or not? $result");

  //   if (result == true) {
  //     updateListView();
  //   }
  // }

  void openNotesPage(StudySet studySet) async {
    int result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => NotesPage(studySet),
    ));

    // Updating number of cards in study set once returning from notes page
    if (result != null) {
      studySet.numCards = result;
      int updateResult = await databaseHelper.updateStudySet(studySet);

      if (updateResult != 0) {
        // Success
        // print('Successfully updated number of cards.');
        updateListView();
      } else {
        // Failure
        // print('Failure to update number of cards');
      }
    }
  }
}
