import 'package:first_app/pages/add_note_page.dart';
import 'package:flutter/material.dart';

import '../note.dart';
import '../studyset_card.dart';

class NotesPage extends StatefulWidget {
  final String title;
  final List<Note> notes;
  final StudySetCardState studySetState;

  NotesPage({this.studySetState, @required this.title, @required this.notes});

  @override
  State<StatefulWidget> createState() {
    return NotesPageState(studySetState);
  }
}

// Note: might want to add notes array to note page?
class NotesPageState extends State<NotesPage> {
  StudySetCardState studySetState;

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
    print("StudySetState: $studySetState");
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
