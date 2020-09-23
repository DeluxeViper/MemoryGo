import 'dart:ui';

import 'package:MemoryGo/values/constants.dart';
import 'package:MemoryGo/model/StudySet.dart';
import 'package:MemoryGo/utils/database_helper.dart';
import 'package:MemoryGo/model/Note.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddNotePage extends StatefulWidget {
  final Note note;
  final StudySet studySet;

  AddNotePage(this.note, this.studySet);

  @override
  State<StatefulWidget> createState() => AddNotePageState(this.note);
}

class AddNotePageState extends State<AddNotePage> {
  DatabaseHelper helper = DatabaseHelper();
  Note note;
  FocusNode noteBodyFocusNode;
  TextEditingController noteNameController;
  TextEditingController noteBodyController;
  bool isChanged = false;

  AddNotePageState(this.note) {
    noteNameController =
        new TextEditingController(text: this.note.title.toString());
    noteBodyController =
        new TextEditingController(text: this.note.body.toString());
  }

  @override
  void initState() {
    super.initState();
    noteBodyFocusNode = new FocusNode();
  }

  @override
  void dispose() {
    noteBodyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Scaffold(
        body: new Stack(
          children: <Widget>[
            ListView(
              children: [
                new Container(
                  height: 60,
                ),
                // Note Title
                new Padding(
                    padding: EdgeInsets.all(10),
                    child: new TextField(
                      autofocus: true,
                      autocorrect: false,
                      controller: noteNameController,
                      keyboardType: TextInputType.multiline,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      onChanged: (value) {
                        if (value == note.title) {
                          setState(() {
                            isChanged = false;
                          });
                        } else {
                          setState(() {
                            isChanged = true;
                          });
                        }
                      },
                      decoration: InputDecoration.collapsed(
                        hintText: 'Enter a title',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 32,
                            fontWeight: FontWeight.w700),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        noteBodyFocusNode.requestFocus();
                      },
                    )),
                // Note Body
                new Padding(
                    padding: EdgeInsets.all(10),
                    child: new TextField(
                      maxLines: null,
                      focusNode: noteBodyFocusNode,
                      autocorrect: false,
                      controller: noteBodyController,
                      onChanged: (value) {
                        if (value == note.body) {
                          setState(() {
                            isChanged = false;
                          });
                        } else {
                          setState(() {
                            isChanged = true;
                          });
                        }
                      },
                      decoration: InputDecoration.collapsed(
                        hintText: 'Start typing...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        _addNote();
                      },
                    )),
              ],
            ),
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                    height: 50,
                    color: Theme.of(context).canvasColor.withOpacity(0.3),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => {Navigator.pop(context, false)},
                          ),
                          Text(
                            (widget.studySet.title.length < 15
                                ? widget.studySet.title
                                : widget.studySet.title.substring(0, 15) +
                                    '...'),
                            style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () {
                              _delete(context, this.note);
                            },
                          ),
                          AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: isChanged ? 100 : 0,
                              height: 55,
                              curve: Curves.decelerate,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: RaisedButton.icon(
                                  color: Theme.of(context).accentColor,
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(100),
                                          bottomLeft: Radius.circular(100))),
                                  icon: Icon(Icons.done),
                                  label: Text(
                                    'SAVE',
                                    style: TextStyle(letterSpacing: 1),
                                  ),
                                  onPressed: () {
                                    _addNote();
                                  },
                                ),
                              )),
                        ],
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _delete(BuildContext context, Note note) async {
    if (note.id == null) {
      Navigator.pop(context, false);
    } else {
      int result = await helper.deleteNote(note.id);
      if (result != 0) {
        // Success
        Navigator.pop(context, true);
      } else {
        // Failure
        Navigator.pop(context, false);
      }
    }
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

    if (note.id != null) {
      // Case 1: Update Operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      // print('Successfully added/updated Note.');
    } else {
      // Failure
      // print('Failed to add/update Note.');
    }

    Navigator.pop(context, true);
  }
}
