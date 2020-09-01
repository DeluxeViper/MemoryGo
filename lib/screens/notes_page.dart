import 'package:MemoryGo/constants.dart';
import 'package:MemoryGo/utils/database_helper.dart';
import 'package:MemoryGo/model/Note.dart';
import 'package:MemoryGo/model/StudySet.dart';
import 'package:MemoryGo/screens/add_note_page.dart';
import 'package:MemoryGo/screens/settings_page.dart';
import 'package:MemoryGo/utils/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:MemoryGo/main.dart';
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
  // static const MethodChannel androidPlat = MethodChannel('memorygo/service');
  static const MethodChannel androidPlatform =
      MethodChannel('com.example.MemoryGo/notebubble');
  NotesPageState(this.studySet);

  static final String androidChannel = "com.flutter.io/snackbar";

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
                        // TODO: Implement GO button in iOS
                        openNoteBubble(notesList);
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

  void openNoteBubble(List<Note> notesList) async {
    List<Map<String, dynamic>> notesListMap = List<Map<String, dynamic>>();
    notesList.forEach((note) {
      notesListMap.add(note.noteToMap());
    });

    // Starting note bubble service in Android
    try {
      await androidPlatform.invokeMethod('openNoteBubble', {
        "notesListMap": notesListMap,
        "duration": studySet.duration,
        "studySetTitle": studySet.title,
        "frequency": studySet.frequency
      });
    } catch (e) {
      print(e);
    }

    var now = new DateTime.now();
    var notificationTime = new DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second + 2);

    // configureNotifications(notesList);
    scheduleNotification(
        flutterLocalNotificationsPlugin,
        notesList[0].id.toString(),
        notesList[0].title,
        notesList[0].body,
        notificationTime);
  }

  void configureNotifications(List<Note> notesList) {
    // TODO: configure notifications based on settings set

    var now = new DateTime.now();
    var notificationTime = new DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second + 2);
    notesList.forEach((note) {
      notificationTime.add(Duration(minutes: 1));
      scheduleNotification(flutterLocalNotificationsPlugin, note.id.toString(),
          note.title, note.body, notificationTime);
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

  void androidShowSnackBar(String message) {
    _showSnackBar(context, message);
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
