import 'dart:ui';

import 'package:first_app/database_helper.dart';
import 'package:first_app/model/Note.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'add_study_set_page.dart';
import '../note.dart';
import '../studyset_card.dart';

class AddNotePage extends StatefulWidget {
  final int studySetId;

  AddNotePage(this.studySetId);

  @override
  State<StatefulWidget> createState() => AddNotePageState(this.studySetId);
}

class AddNotePageState extends State<AddNotePage> {
  final TextEditingController noteNameController = new TextEditingController();
  final TextEditingController noteBodyController = new TextEditingController();
  DatabaseHelper helper = DatabaseHelper();
  int studySetId;
  FocusNode focusNode;

  AddNotePageState(this.studySetId);

  @override
  void initState() {
    super.initState();
    focusNode = new FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Create New Note'),
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () => _addNote(),
                  child: Icon(Icons.keyboard_arrow_right)))
        ],
      ),
      body: new Column(
        children: <Widget>[
          new Padding(
              padding: EdgeInsets.all(10),
              child: new TextField(
                autofocus: true,
                autocorrect: false,
                controller: noteNameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Note Title'),
                onSubmitted: (value) => {focusNode.requestFocus()},
              )),
          new Padding(
              padding: EdgeInsets.all(10),
              child: new TextField(
                focusNode: this.focusNode,
                autocorrect: false,
                controller: noteBodyController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Note Body'),
                onSubmitted: (value) => _addNote(),
              )),
        ],
      ),
    );
  }

  void _addNote() async {
    String noteTitle = noteNameController.text;
    String noteBody = noteBodyController.text;

    Note note = Note(this.studySetId, noteTitle, noteBody);
    int result;
    if (note.id != null) {
      // Case 1: Update Operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      print('Successfully added Note.');
    } else {
      // Failure
      print('Failed to add Note.');
    }

    Navigator.pop(context, true);
  }
}
