import 'package:first_app/utils/database_helper.dart';
import 'package:first_app/model/StudySet.dart';
import 'package:first_app/screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'add_study_set_page.dart';
import 'notes_page.dart';

class StudySetList extends StatefulWidget {
  StudySetList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  StudySetListState createState() => StudySetListState();
}

class StudySetListState extends State<StudySetList> {
  static DatabaseHelper databaseHelper = DatabaseHelper();
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
                child: Text(
                  'Study Sets',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                )),
            // Cards
            Expanded(child: getStudySetListView())
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

  // Displays studyset list
  ListView getStudySetListView() {
    return ListView.builder(
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
                                        _delete(context, studySets[index]);
                                      },
                                      child: Icon(Icons.delete,
                                          semanticLabel: 'Delete Study set'))
                                ],
                              ))
                        ],
                      ))));
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

  void goToAddSetPage() async {
    bool result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddStudySet(),
    ));

    if (result == true) {
      updateListView();
    }
  }

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
