import 'package:first_app/main.dart';
import 'package:first_app/pages/settings_page.dart';
import 'package:first_app/pages/studyset_list.dart';
import 'package:flutter/material.dart';
import 'note.dart';
import 'pages/notes_page.dart';

// BUG: Notes of study sets are only bound to the
// listview position of study sets and not the actual
// studyset.

// Search up how to assign a dynamic variable to a
// stateful widget
class StudySetCard extends StatefulWidget {
  final nameOfSet, dateCreated;

  StudySetCard({this.nameOfSet, this.dateCreated});

  @override
  State<StatefulWidget> createState() => StudySetCardState();
}

class StudySetCardState extends State<StudySetCard> {
  var nameOfSet, dateCreated, numOfCards;

  List<Note> notes = [];

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
                                  // TODO: Implement delete study set
                                },
                                child: Icon(Icons.delete,
                                    semanticLabel: 'Delete Study set'))
                          ],
                        ))
                  ],
                ))));
  }
}
