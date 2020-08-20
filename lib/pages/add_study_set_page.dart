import 'package:first_app/main.dart';
import 'package:first_app/study_set.dart';
import 'package:flutter/material.dart';

class AddSet extends StatefulWidget {
  final MyHomePageState myHomePageState;

  AddSet(this.myHomePageState);

  @override
  State<StatefulWidget> createState() {
    return AddSetState();
  }
}

class AddSetState extends State<AddSet> {
  TextEditingController nameOfSetController = new TextEditingController();

  static String getCurrentDate() {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate =
        "${dateParse.day.toString().padLeft(2, '0')}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.year} ${dateParse.hour.toString().padLeft(2, '0')}:${dateParse.minute.toString().padLeft(2, '0')}";

    return formattedDate;
  }

  void addSet() {
    widget.myHomePageState.addToStudySet(new StudySet(
      myHomePageState: widget.myHomePageState,
      nameOfSet: nameOfSetController.text,
      dateCreated: getCurrentDate(),
      numOfCards: 0,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Create New Study Set"),
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () => addSet(),
                  child: Icon(Icons.keyboard_arrow_right)))
        ],
      ),
      body: new Column(
        children: <Widget>[
          // Title of Study Set
          new Padding(
              padding: EdgeInsets.all(10),
              child: new TextField(
                autocorrect: false,
                controller: nameOfSetController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Study Set Name'),
                onSubmitted: (value) => addSet(),
              )),
        ],
      ),
    );
  }
}
