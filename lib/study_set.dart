import 'package:first_app/main.dart';
import 'package:first_app/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'note.dart';
import 'pages/notes_page.dart';

// BUG: Notes of study sets are only bound to the
// listview position of study sets and not the actual
// studyset.

// Search up how to assign a dynamic variable to a
// stateful widget
class StudySet extends StatefulWidget {
  final nameOfSet, dateCreated, numOfCards;
  final MyHomePageState myHomePageState;

  StudySet(
      {this.myHomePageState,
      this.nameOfSet,
      this.dateCreated,
      this.numOfCards});

  void deleteStudySet() {
    myHomePageState.deleteStudySet(this);
  }

  @override
  State<StatefulWidget> createState() {
    return StudySetState(
        nameOfSet: this.nameOfSet,
        dateCreated: this.dateCreated,
        numOfCards: this.numOfCards);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "nameOfSet: $nameOfSet\ndateCreated: $dateCreated\nnumOfCards: $numOfCards\n";
  }
}

class StudySetState extends State<StudySet> {
  var nameOfSet, dateCreated, numOfCards;

  List<Note> notes = [];

  StudySetState({this.nameOfSet, this.dateCreated, this.numOfCards});

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "nameOfSet: $nameOfSet\ndateCreated: $dateCreated\nnumOfCards: $numOfCards\nnotes: $notes";
  }

  bool removeNote(Note note) {
    if (notes.contains(note)) {
      notes.remove(note);
      return true;
    }
    return false;
  }

  //     void _editNameOfSet(String nameOfSet) {
  //   setState(() {
  //     this.nameOfSet = nameOfSet;
  //   });
  // }

  // void _editDateCreated(String dateCreated) {
  //   setState(() {
  //     this.dateCreated = dateCreated;
  //   });
  // }

  void editNumOfCards(int numOfCards) {
    setState(() {
      this.numOfCards = numOfCards;
    });
  }

  void openSettingsPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => new SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.all(20.0),
        child: Card(
            child: InkWell(
                splashColor: Colors.blue.withAlpha(20),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NotesPage(
                      studySetState: this,
                      title: widget.nameOfSet,
                      notes: this.notes,
                    ),
                  ));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(widget.nameOfSet,
                            style: TextStyle(fontSize: 20))),
                    new Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(widget.dateCreated)),
                    new Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(numOfCards.toString())),
                    new Padding(
                        padding: EdgeInsets.all(10.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            new GestureDetector(
                                onTap: () => openSettingsPage(),
                                child: Icon(
                                  Icons.settings,
                                  semanticLabel: 'Study set settings',
                                )),
                            new SizedBox(height: 10.0, width: 10.0),
                            new GestureDetector(
                                onTap: () {
                                  widget.deleteStudySet();
                                },
                                child: Icon(Icons.delete,
                                    semanticLabel: 'Delete Study set'))
                          ],
                        ))
                  ],
                ))));
  }
}
