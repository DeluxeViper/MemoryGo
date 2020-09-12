import 'dart:io';

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
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  bool isSessionEnded;
  int count = 0;
  List<Note> notesList;
  DatabaseHelper helper = DatabaseHelper();
  StudySet studySet;
  // static const MethodChannel androidPlat = MethodChannel('memorygo/service');
  static const MethodChannel androidPlatform =
      MethodChannel('com.example.MemoryGo/notebubble');
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
                    // Go Button
                    RaisedButton(
                      onPressed: () {
                        if (Platform.isAndroid) {
                          if (notesList.isEmpty) {
                            _showSnackBar(context,
                                "Error, Cannot start. ${studySet.title} is Empty.");
                          } else {
                            openNoteBubble(notesList);
                          }
                        } else if (Platform.isIOS) {
                          scheduleIOSNotifications(notesList);
                        } else {
                          _showSnackBar(context, "Platform unrecognized.");
                        }
                      },
                      color: kPrimaryColor,
                      textColor: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text('Go')),
                    ),
                    // Stop Session
                    RaisedButton(
                      onPressed: () {
                        // Stop Session
                        if (isSessionEnded == true) {
                          _showSnackBar(
                              context, "Error. Session is already running.");
                        } else {
                          isSessionEnded = true;
                          stopNotifications();
                        }
                      },
                      color: Color(0xFFFF0000),
                      textColor: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text('Stop Session')),
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
        physics: BouncingScrollPhysics(),
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
        "frequency": studySet.frequency,
        "repeat": studySet.repeat.toString(),
        "overwrite": studySet.overwrite.toString()
      });
    } catch (e) {
      print(e);
    }
  }

  void scheduleIOSNotifications(List<Note> notesList) async {
    print("Scheduling ios notifications.");
    isSessionEnded = false;
    var freqStr = studySet.frequency;
    var durStr = studySet.duration;
    var nowDt = new DateTime.now();
    var nowMilliseconds = nowDt.millisecondsSinceEpoch;
    int duration;
    double frequency;

    if (durStr == '30 Mins') {
      duration = 1000 * 60 * 30;
    } else if (durStr == '1 Hr') {
      duration = 1000 * 60 * 60;
    } else if (durStr == '2 Hrs') {
      duration = 1000 * 60 * 120;
    }

    if (freqStr == 'Very low') {
      frequency = duration / 5;
    } else if (freqStr == 'Low') {
      frequency = duration / 10;
    } else if (freqStr == 'Medium') {
      frequency = duration / 15;
    } else if (freqStr == 'High') {
      frequency = duration / 20;
    }

    // TEST PURPOSES
    duration = 1000 * 20;
    frequency = (1000 * 2).toDouble();
    //

    // scheduleNotification(
    //         flutterLocalNotificationsPlugin,
    //         notesList[0].id.toString(),
    //         notesList[0].title,
    //         notesList[0].body,
    //         notificationsDateTime.add(Duration(seconds: 5)))
    //     .whenComplete(() {
    //   print("Completed");
    // }).catchError((error, stackTrace) {
    //   print('error');
    // });

    DateTime notificationsDateTime = nowDt;
    print(notificationsDateTime);
    int notesListIndex = 0;
    int scheduledNotificationCount = 1;

    print(notesList[0]);
    // scheduleNotification(
    //         flutterLocalNotificationsPlugin,
    //         notesList[0].id.toString(),
    //         notesList[0].title,
    //         notesList[0].body,
    //         notificationsDateTime.add(Duration(milliseconds: 3000)))
    //     .then((value) {
    //   scheduleNotification(
    //       flutterLocalNotificationsPlugin,
    //       notesList[1].id.toString(),
    //       notesList[1].title,
    //       notesList[1].body,
    //       notificationsDateTime.add(Duration(milliseconds: 6000)));
    // });
    print(notesList[1]);

    // print('Notification scheduled.');
    // while (notificationsDateTime
    //             .add(Duration(
    //                 milliseconds:
    //                     frequency.toInt() * scheduledNotificationCount))
    //             .millisecondsSinceEpoch <
    //         nowDt
    //             .add(Duration(milliseconds: duration))
    //             .millisecondsSinceEpoch &&
    //     !isSessionEnded) {
    //   if (notesListIndex == notesList.length) {
    //     // notesListIndex = 0;
    //     break;
    //   }

    //   Note note = notesList[notesListIndex];
    //   scheduleNotification(
    //       flutterLocalNotificationsPlugin,
    //       note.id.toString(),
    //       note.title,
    //       note.body,
    //       notificationsDateTime.add(Duration(
    //           milliseconds: frequency.toInt() * scheduledNotificationCount)));
    //   notesListIndex++;
    //   scheduledNotificationCount++;
    //   print("Scheduled: ${note.title}");
    // }
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
      result = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => new AddNotePage(note, studySet)));
    } else {
      // Case 2: Insert Operation
      result = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              new AddNotePage(new Note(this.studySet.id, '', ''), studySet)));
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

  void stopNotifications() {
    // turnOffNotifications(flutterLocalNotificationsPlugin);
    _showSnackBar(context, "Stopped session and cancelled notifications.");
  }
}
