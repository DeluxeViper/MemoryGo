import 'package:MemoryGo/constants.dart';
import 'package:MemoryGo/utils/database_helper.dart';
import 'package:MemoryGo/model/StudySet.dart';
import 'package:MemoryGo/screens/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../notes_page.dart';

class StudySetList extends StatefulWidget {
  StudySetList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  StudySetListState createState() => StudySetListState();
}

class StudySetListState extends State<StudySetList> {
  static DatabaseHelper databaseHelper = DatabaseHelper();
  TextEditingController nameOfSetController, searchController;
  static List<StudySet> studySets, filteredStudySets;
  int fetchedStudySetListCount = 0, filteredStudySetCount = 0;

  @override
  void initState() {
    super.initState();
    nameOfSetController = new TextEditingController();
    searchController = new TextEditingController();
  }

  void dispose() {
    nameOfSetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (studySets == null) {
      studySets = List<StudySet>();
      updateListView();
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeaderWithSearchBox(size),
            Container(
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Cards
                  Expanded(child: getStudySetListView())
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addStudySetModalBottomSheet(context),
        tooltip: 'Add Study Set',
        child: Icon(Icons.add),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Padding(
        padding: EdgeInsets.only(left: 0, top: 15),
        child: Text(
          "${widget.title}",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
      elevation: 0,
    );
  }

  Container buildHeaderWithSearchBox(Size size) {
    return Container(
      height: size.height * 0.2,
      margin: EdgeInsets.only(bottom: 30),
      child: Stack(
        children: [
          // 0.2 of height blue box
          Container(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 50),
            height: size.height * 0.2 - 20,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36)),
            ),
          ),
          // Title
          new Container(
              margin: new EdgeInsets.only(top: 30.0),
              child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    'My Study Sets',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ))),
          // Search bar
          Positioned(
              bottom: 0,
              left: 10,
              right: 10,
              child: Container(
                alignment: Alignment.center,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 50,
                          color: kPrimaryColor.withOpacity(0.23))
                    ]),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        maxLines: 1,
                        onChanged: (studySetTitle) {
                          buildStudySetComponentList();
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 15),
                          hintText: "Search",
                          hintStyle:
                              TextStyle(color: kPrimaryColor.withOpacity(0.5)),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image(
                          alignment: Alignment.center,
                          image: AssetImage('assets/icons/search.png')),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Displays studyset list
  ListView getStudySetListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: filteredStudySetCount,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              width: double.infinity,
              margin: EdgeInsets.all(20.0),
              child: Card(
                  child: InkWell(
                      splashColor: Colors.blue.withAlpha(20),
                      onTap: () {
                        openNotesPage(filteredStudySets[index]);
                      },
                      // Study set
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Image(
                                  height: 40,
                                  width: 40,
                                  image: AssetImage(
                                      'assets/icons/notebook_icon.png'),
                                ),
                                new Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(filteredStudySets[index].title,
                                        style: TextStyle(fontSize: 20))),
                              ],
                            ),
                          ),
                          // Date of study set
                          new Padding(
                              padding: EdgeInsets.only(left: 15.0, bottom: 5),
                              child: Text(filteredStudySets[index].date)),
                          // Number of cards
                          new Padding(
                              padding: EdgeInsets.only(left: 15, bottom: 5),
                              child: Text(filteredStudySets[index]
                                  .numCards
                                  .toString())),
                          // Delete and settings page icons
                          new Padding(
                              padding: EdgeInsets.all(15.0),
                              child: new Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  new GestureDetector(
                                      onTap: () =>
                                          openSettingsPage(studySets[index]),
                                      child: Icon(
                                        Icons.settings,
                                        semanticLabel: 'Study set settings',
                                      )),
                                  new SizedBox(height: 10.0, width: 10.0),
                                  new GestureDetector(
                                      onTap: () {
                                        showAlertDialog(context, index);
                                      },
                                      child: Icon(Icons.delete,
                                          semanticLabel: 'Delete Study set'))
                                ],
                              ))
                        ],
                      ))));
        });
  }

  void addStudySetModalBottomSheet(BuildContext context) {
    nameOfSetController.text = '';
    showModalBottomSheet(
        enableDrag: true,
        isScrollControlled: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (BuildContext context) {
          return new Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Title of Study Set
                  new Padding(
                      padding: EdgeInsets.all(10),
                      child: new TextField(
                          autocorrect: false,
                          controller: nameOfSetController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Study Set Name'),
                          onSubmitted: (value) {
                            print("submitted");
                            _addSet();
                            nameOfSetController.text = '';
                          })),
                  new RaisedButton(
                    onPressed: () {
                      _addSet();
                      nameOfSetController.text = '';
                    },
                    color: kPrimaryColor,
                    child: Text("Add Study Set"),
                  ),
                ],
              ));
        });
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<StudySet>> studySetListFuture =
          databaseHelper.getStudySetList();
      studySetListFuture.then((studySetList) {
        setState(() {
          studySets = studySetList;
          fetchedStudySetListCount = studySetList.length;
          buildStudySetComponentList();
        });
      });
    });
  }

  void buildStudySetComponentList() {
    List<StudySet> studySetComponentList = [];
    if (searchController.text.isNotEmpty) {
      studySets.forEach((studySet) {
        if (studySet.title
            .toLowerCase()
            .contains(searchController.text.toLowerCase())) {
          studySetComponentList.add(studySet);
        }
      });
    } else {
      studySetComponentList = studySets;
    }
    setState(() {
      filteredStudySets = studySetComponentList;
      filteredStudySetCount = studySetComponentList.length;
    });
  }

  void _addSet() async {
    print('Adding set');
    StudySet studySet = new StudySet('', 0);
    int result;
    studySet.title = nameOfSetController.text;
    if (studySet.id != null) {
      // Case 1: Update Operation -> Studyset exists
      result = await databaseHelper.updateStudySet(studySet);
    } else {
      result = await databaseHelper.insertStudySet(studySet);
    }

    if (result != 0) {
      // Success
      print('Studyset saved Successfully.');
      updateListView();
      // _showAlertDialog('Status', 'Studyset saved Successfully.');
    } else {
      // Failure
      print('Problem saving Studyset.');
      // _showAlertDialog('Status', 'Problem saving Studyset.');
    }

    // Update list with studyset and return back to the page
    Navigator.pop(context, true);
  }

  showAlertDialog(BuildContext context, int index) {
    AlertDialog alert = new AlertDialog(
      title: Text("Delete Study Set"),
      content: Text("Are you sure you want to delete this study set?"),
      actions: [
        FlatButton(
            child: Text("Yes"),
            color: Colors.green,
            onPressed: () {
              _delete(context, studySets[index]);
              Navigator.of(context).pop();
            }),
        FlatButton(
            color: Colors.red,
            child: Text("No"),
            onPressed: () => Navigator.of(context).pop())
      ],
      elevation: 20.0,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  // deletes studyset
  void _delete(BuildContext context, StudySet studySet) async {
    int result = await databaseHelper.deleteStudySet(studySet.id);
    if (result != 0) {
      _showSnackbar(context, 'StudySet deleted Successfully.');
      updateListView();
    } else {
      _showSnackbar(context, 'Error deleting Studyset.');
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void openSettingsPage(StudySet studySet) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => new SettingsPage(studySet)));
  }

  void openNotesPage(StudySet studySet) async {
    int result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => NotesPage(studySet),
    ));

    // Updating number of cards in study set once returning from notes page
    if (result != null) {
      studySet.numCards = result;
      int updateResult = await databaseHelper.updateStudySet(studySet);

      if (updateResult != 0) {
        // Success
        // print('Successfully updated number of cards.');
        updateListView();
      } else {
        // Failure
        // print('Failure to update number of cards');
      }
    }
  }
}
