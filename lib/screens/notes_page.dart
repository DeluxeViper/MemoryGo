import 'package:first_app/constants.dart';
import 'package:first_app/database_helper.dart';
import 'package:first_app/model/Note.dart';
import 'package:first_app/model/StudySet.dart';
import 'package:first_app/screens/add_note_page.dart';
import 'package:first_app/screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'add_note_page.dart';

class NotesPage extends StatefulWidget {
  final StudySet studySet;

  NotesPage(this.studySet);

  @override
  State<StatefulWidget> createState() {
    return NotesPageState(this.studySet);
  }
}

// Note: might want to add notes array to note page?
class NotesPageState extends State<NotesPage> {
  int count = 0;
  List<Note> notesList;
  DatabaseHelper helper = DatabaseHelper();
  StudySet studySet;

  NotesPageState(this.studySet);

  @override
  Widget build(BuildContext context) {
    if (notesList == null) {
      notesList = new List<Note>();
      updateNoteListView();
    }

    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
            title: Text('Notes of ${widget.studySet.title}'),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, notesList.length),
            ),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: GestureDetector(
                      child: Icon(Icons.settings),
                      onTap: () => openSettingsPage(this.studySet)))
            ]),
        body: new Container(
            child: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        // TODO: Implement Go button
                      },
                      color: kPrimaryColor,
                      textColor: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text('Go')),
                    )
                  ],
                )),
            Expanded(child: getNoteListView())
          ],
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () => openAddNotePage(context: context),
          tooltip: 'Add Note',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
        itemCount: this.count,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              width: double.infinity - 20,
              margin: EdgeInsets.all(20.0),
              child: new Card(
                  child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(notesList[index].title,
                          style: TextStyle(fontSize: 20))),
                  new Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(notesList[index].body)),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            'Created ${notesList[index].date}',
                            style: TextStyle(fontSize: 10),
                          )),
                      new Container(
                          padding: EdgeInsets.only(bottom: 10.0, right: 10.0),
                          child: new Row(
                            children: [
                              new GestureDetector(
                                  onTap: () {
                                    openAddNotePage(
                                        context: context,
                                        note: notesList[index]);
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    semanticLabel: 'Edit Note',
                                  )),
                              new SizedBox(height: 10.0, width: 10.0),
                              new GestureDetector(
                                  onTap: () {
                                    _delete(context, notesList[index]);
                                  },
                                  child: Icon(Icons.delete,
                                      semanticLabel: 'Delete Note'))
                            ],
                          ))
                    ],
                  ),
                ],
              )));
        });
  }

  void _delete(BuildContext context, Note note) async {
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      // Success
      _showSnackBar(context, 'Note deleted Successfully');
      updateNoteListView();
    } else {
      // Failure
      _showSnackBar(context, 'Error deleting Note');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final SnackBar snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateNoteListView() {
    final Future<Database> dbFuture = helper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = helper.getNoteList(this.studySet.id);
      noteListFuture.then((noteList) {
        setState(() {
          this.notesList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  void openAddNotePage({@required BuildContext context, Note note}) async {
    bool result;
    if (note != null) {
      // Case 1: Update Operation
      result = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => new AddNotePage(note)));
    } else {
      // Case 2: Insert Operation
      result = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              new AddNotePage(new Note(this.studySet.id, '', ''))));
    }

    if (result == true) {
      // Successfully added/updated Note
      updateNoteListView();
      if (note == null) {
        _showSnackBar(context, 'Successfully added Note');
      } else {
        _showSnackBar(context, 'Successfully updated Note');
      }
    } else {
      // Failure to add/update Note
      // if (note == null) {
      //   _showSnackBar(context, 'Failed to add Note');
      // } else {
      //   _showSnackBar(context, 'Failed to update Note');
      // }
    }
  }

  void openSettingsPage(StudySet studySet) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => new SettingsPage(studySet)));
  }
}
