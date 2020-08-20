import 'package:flutter/material.dart';

class Note extends StatefulWidget {
  final noteTitle, noteBody, dateCreated;

  Note({this.noteTitle, this.noteBody, this.dateCreated});

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "Note title: $noteTitle\nNote Body: $noteBody\nDate Created: $dateCreated";
  }

  @override
  State<StatefulWidget> createState() {
    return new _NoteState();
  }
}

class _NoteState extends State<Note> {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "Note title: ${widget.noteTitle}\nNote Body: ${widget.noteBody}\nDate Created: ${widget.dateCreated}";
  }

  @override
  Widget build(BuildContext context) {
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
                child: Text(widget.noteTitle, style: TextStyle(fontSize: 20))),
            new Padding(
                padding: EdgeInsets.all(20.0), child: Text(widget.noteBody)),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Created ${widget.dateCreated}',
                      style: TextStyle(fontSize: 10),
                    )),
                new Container(
                    padding: EdgeInsets.only(bottom: 10.0, right: 10.0),
                    child: new Row(
                      children: [
                        new GestureDetector(
                            onTap: () => {}, // TODO: Implement edit note
                            child: Icon(
                              Icons.edit,
                              semanticLabel: 'Edit Note',
                            )),
                        new SizedBox(height: 10.0, width: 10.0),
                        new GestureDetector(
                            onTap:
                                () {}, // TODO: Implement delete note                                },
                            child: Icon(Icons.delete,
                                semanticLabel: 'Delete Note'))
                      ],
                    ))
              ],
            ),
          ],
        )));
  }
}
