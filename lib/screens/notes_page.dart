import 'package:first_app/database_helper.dart';
import 'package:first_app/model/Note.dart';
import 'package:first_app/screens/add_note_page.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../Note.dart';
import 'add_note_page.dart';

class NotesPage extends StatefulWidget {
  final String title;
  final int studySetId;

  NotesPage({this.title, this.studySetId});

  @override
  State<StatefulWidget> createState() {
    return NotesPageState(studySetId: this.studySetId);
  }
}

// Note: might want to add notes array to note page?
class NotesPageState extends State<NotesPage> {
  int studySetId, count = 0;
  List<Note> notesList;
  DatabaseHelper helper = DatabaseHelper();

  NotesPageState({this.studySetId});

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
          title: Text('Notes of ${widget.title}'),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, notesList.length),
          ),
        ),
        body: new Container(
            child: Column(
          children: [Expanded(child: getNoteListView())],
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () => openAddNotePage(),
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
          // TODO: Implement notes list
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
                                  onTap: () => {}, // TODO: Implement edit note
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
      Future<List<Note>> noteListFuture = helper.getNoteList(this.studySetId);
      noteListFuture.then((noteList) {
        setState(() {
          this.notesList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  void openAddNotePage({Note note}) async {
    bool result;
    if (note != null) {
    } else {
      result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => new AddNotePage(studySetId)));
    }

    if (result == true) {
      // Successfully added Note
      updateNoteListView();
      _showSnackBar(context, 'Successfully added Note');
    } else {
      // Failure to add Note
      _showSnackBar(context, 'Failed to add Note');
    }
  }
}
