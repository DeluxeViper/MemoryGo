import 'dart:io';

import 'package:MemoryGo/values/constants.dart';
import 'package:MemoryGo/utils/database_helper.dart';
import 'package:MemoryGo/model/Note.dart';
import 'package:MemoryGo/model/StudySet.dart';
import 'package:MemoryGo/screens/add_note_page.dart';
import 'package:MemoryGo/screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int notesListCount = 0;
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

    return new Scaffold(
      appBar: buildAppBar(context),
      body: Builder(
        builder: (context) => new Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 5,
            ),
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Go Button
                    ElevatedButton(
                      onPressed: () {
                        if (Platform.isAndroid) {
                          if (notesList.isEmpty) {
                            _showSnackBar(
                                context, "Error. ${studySet.title} is Empty.");
                          } else {
                            openNoteBubble(notesList);
                          }
                        } else {
                          _showSnackBar(context, "Platform unrecognized.");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.green,
                          backgroundColor: Colors.white),
                      // color: Colors.green,
                      // textColor: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Icon(Icons.play_arrow)),
                    ),
                  ],
                )),
            Expanded(child: getNoteListView())
          ],
        )),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () => openAddNotePage(context: context),
          tooltip: 'Add Note',
          child: Icon(Icons.add),
          backgroundColor: kPrimaryColor,
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: Text(
          'Notes of ${widget.studySet.title}',
          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: kPrimaryColor,
          onPressed: () => Navigator.pop(context, notesList.length),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                  child: Icon(
                    Icons.settings,
                    color: kPrimaryColor,
                    semanticLabel: 'Study Set Settings',
                  ),
                  onTap: () => openSettingsPage(this.studySet)))
        ]);
  }

  ListView getNoteListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: this.notesListCount,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              width: double.infinity - 20,
              margin: EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () {
                  openAddNotePage(context: context, note: notesList[index]);
                },
                child: new Card(
                    elevation: 10,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Image(
                                height: 40,
                                width: 40,
                                image: AssetImage('assets/icons/note-icon.png'),
                              ),
                            ),
                            Expanded(
                              child: new Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text((notesList[index].title),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 20))),
                            ),
                          ],
                        ),
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
                                padding:
                                    EdgeInsets.only(bottom: 10.0, right: 10.0),
                                child: new Row(
                                  children: [
                                    // new GestureDetector(
                                    //     onTap: () {
                                    //       openAddNotePage(
                                    //           context: context,
                                    //           note: notesList[index]);
                                    //     },
                                    //     child: Icon(
                                    //       Icons.edit,
                                    //       semanticLabel: 'Edit Note',
                                    //     )),
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
                    )),
              ));
        });
  }

  void updateNoteListView() {
    final Future<Database> dbFuture = helper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = helper.getNoteList(this.studySet.id);
      noteListFuture.then((noteList) {
        setState(() {
          this.notesList = noteList;
          this.notesListCount = noteList.length;
          this.studySet.numCards = notesList.length;
        });

        // Update study set
        Future<int> result = helper.updateStudySet(this.studySet);
        result.then((value) {
          if (value != 0) {
            // print("successfully updated study set number of cards.");
          } else {
            _showSnackBar(
                context, 'Failed to update number of cards for Study Set.');
            // print("failed ot update study set number of cards.");
          }
        });
      });
    });
  }

  void openNoteBubble(List<Note> notesList) async {
    List<Map<String, dynamic>> notesListMap = List<Map<String, dynamic>>();
    notesList.forEach((note) {
      notesListMap.add(note.noteToMap());
    });
    isSessionEnded = false;
    // Starting note bubble service in Android
    try {
      await androidPlatform.invokeMethod('openNoteBubble', {
        "notesListMap": notesListMap,
        "duration": studySet.duration,
        "studySetTitle": studySet.title,
        "frequency": studySet.frequency,
        "repeat": studySet.repeat.toString(),
        "overwrite": studySet.overwrite.toString(),
        "shuffle": studySet.shuffle.toString()
      }).whenComplete(() {
        isSessionEnded = true;
        // print("Note bubble completed.");
      });
    } catch (e) {
      // print(e);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      // Success
      // _showSnackBar(context, 'Note deleted Successfully');
      studySet.numCards--;
      updateNoteListView();
    } else {
      // Failure
      _showSnackBar(context, 'Error deleting Note');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        // _showSnackBar(context, 'Successfully added Note');
      } else {
        // _showSnackBar(context, 'Successfully updated Note');
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
