import 'dart:ui';

import 'package:first_app/pages/notes_page.dart';
import 'package:flutter/material.dart';
import 'add_study_set_page.dart';
import '../note.dart';
import '../studyset_card.dart';

class AddNotePage extends StatefulWidget {
  final NotesPageState notesPageState;

  AddNotePage(this.notesPageState);

  @override
  State<StatefulWidget> createState() {
    return AddNotePageState(this.notesPageState);
  }
}

class AddNotePageState extends State<AddNotePage> {
  final TextEditingController noteNameController = new TextEditingController();
  final TextEditingController noteBodyController = new TextEditingController();
  final NotesPageState notesPageState;
  FocusNode focusNode;

  AddNotePageState(this.notesPageState);

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

  // Creating new note and adding it to the list of notes of study set
  void addNote() {
    String noteTitle = noteNameController.text;
    String noteBody = noteBodyController.text;
    // String dateCreated = AddStudySetState.getCurrentDate();

    notesPageState.addNoteToStudySet(new Note(
      noteBody: noteBody,
      noteTitle: noteTitle,
      // dateCreated: dateCreated,
    ));

    Navigator.pop(context);
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
                  onTap: () => addNote(),
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
                onSubmitted: (value) => addNote(),
              )),
        ],
      ),
    );
  }
}
