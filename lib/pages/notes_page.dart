import 'package:first_app/pages/add_note_page.dart';
import 'package:flutter/material.dart';

import '../note.dart';
import '../study_set.dart';

class NotesPage extends StatefulWidget {
  final String title;
  final List<Note> notes;
  final StudySetState studySetState;

  NotesPage({this.studySetState, @required this.title, @required this.notes});

  @override
  State<StatefulWidget> createState() {
    return NotesPageState(studySetState);
  }
}

// Note: might want to add notes array to note page?
// Problem: adding a note wont change anything (because notes list is final)?
class NotesPageState extends State<NotesPage> {
  StudySetState studySetState;

  NotesPageState(this.studySetState);

  void openAddNotePage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => new AddNotePage(this)));
  }

  void addNoteToStudySet(Note note) {
    setState(() {
      studySetState.notes.add(note);
      studySetState.numOfCards++;
    });
    studySetState.editNumOfCards(studySetState.numOfCards);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Notes of ${widget.title}'),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: new Container(
            child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: studySetState.notes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return studySetState.notes.elementAt(index);
                    }))
          ],
        )), // TODO: Implement body
        floatingActionButton: FloatingActionButton(
          onPressed: () => openAddNotePage(),
          tooltip: 'Add Note',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
