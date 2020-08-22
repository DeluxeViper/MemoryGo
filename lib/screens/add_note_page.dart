import 'package:first_app/database_helper.dart';
import 'package:first_app/model/Note.dart';
import 'package:flutter/material.dart';

class AddNotePage extends StatefulWidget {
  final Note note;

  AddNotePage(this.note);

  @override
  State<StatefulWidget> createState() => AddNotePageState(this.note);
}

class AddNotePageState extends State<AddNotePage> {
  DatabaseHelper helper = DatabaseHelper();
  Note note;
  FocusNode focusNode;
  TextEditingController noteNameController;
  TextEditingController noteBodyController;

  AddNotePageState(this.note) {
    noteNameController =
        new TextEditingController(text: this.note.title.toString());
    noteBodyController =
        new TextEditingController(text: this.note.body.toString());
  }

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
    Note note;

    // If a note instance was passed into this class, then
    // make sure the id gets passed into the note
    if (this.note.id == null) {
      note = Note(this.note.studySetId, noteTitle, noteBody);
    } else {
      note =
          Note.withId(this.note.id, this.note.studySetId, noteTitle, noteBody);
    }

    int result;
    print('Note: $note');

    if (note.id != null) {
      // Case 1: Update Operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      print('Successfully added/updated Note.');
    } else {
      // Failure
      print('Failed to add/update Note.');
    }

    Navigator.pop(context, true);
  }
}
