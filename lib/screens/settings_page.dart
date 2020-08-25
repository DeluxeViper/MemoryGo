import 'package:first_app/constants.dart';
import 'package:first_app/database_helper.dart';
import 'package:first_app/model/StudySet.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final StudySet studySet;

  SettingsPage(this.studySet);

  @override
  State<StatefulWidget> createState() {
    return SettingsPageState(this.studySet);
  }
}

class SettingsPageState extends State<SettingsPage> {
  DatabaseHelper helper = new DatabaseHelper();
  String _selectedDuration = durationList[0];
  bool vLowChecked,
      lowChecked,
      medChecked,
      highChecked,
      repeatVal,
      overwriteVal;

  StudySet studySet;

  SettingsPageState(this.studySet) {
    _selectedDuration = this.studySet.duration;
    if (studySet.frequency == freqList[0]) {
      vLowChecked = true;
      lowChecked = false;
      medChecked = false;
      highChecked = false;
    } else if (studySet.frequency == freqList[1]) {
      vLowChecked = false;
      lowChecked = true;
      medChecked = false;
      highChecked = false;
    } else if (studySet.frequency == freqList[2]) {
      vLowChecked = false;
      lowChecked = false;
      medChecked = true;
      highChecked = false;
    } else if (studySet.frequency == freqList[3]) {
      vLowChecked = false;
      lowChecked = false;
      medChecked = false;
      highChecked = true;
    }
    repeatVal = studySet.repeat;
    overwriteVal = studySet.overwrite;
  }

  void onSaved() {
    // Duration of study set
    studySet.duration = _selectedDuration;

    // Frequency of study set
    if (vLowChecked == true) {
      studySet.frequency = freqList[0];
    } else if (lowChecked == true) {
      studySet.frequency = freqList[1];
    } else if (medChecked == true) {
      studySet.frequency = freqList[2];
    } else if (highChecked == true) {
      studySet.frequency = freqList[3];
    }

    // Repeat of study set
    studySet.repeat = repeatVal;

    // Overwrite of study set
    studySet.overwrite = overwriteVal;

    print("Study set settings saved as: $studySet");

    _updateSet(studySet);

    Navigator.pop(context);
  }

  void _updateSet(StudySet studySet) async {
    int result = await helper.updateStudySet(studySet);

    if (result != 0) {
      // Successfully saved settings
      print("Saved settings successfully.");
      var studySetList = await helper.getStudySetList();
      print(studySetList.toString());
    } else {
      // Failed to save settings
      print("Failed to save settings.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('Settings'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new SizedBox(height: 30.0, width: double.infinity),
          // Duration
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Padding(
                  padding: new EdgeInsets.only(left: 10.0),
                  child: new Text('Duration',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              new Padding(
                  padding: new EdgeInsets.only(right: 10.0),
                  child: new DropdownButton<String>(
                      hint: Text('30 Mins'),
                      value: _selectedDuration,
                      items: durationList.map((String value) {
                        return new DropdownMenuItem<String>(
                            value: value, child: new Text(value));
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedDuration = newValue;
                        });
                      }))
            ],
          ),
          Divider(color: Colors.grey),
          // Frequency
          new Padding(
              padding: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text('Frequency',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          // Check Boxes column
          new Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              new CheckboxListTile(
                  title: Text('Very low', style: TextStyle(fontSize: 13)),
                  value: vLowChecked,
                  onChanged: (bool value) {
                    setState(() {
                      if (value == true) {
                        vLowChecked = value;
                        lowChecked = !value;
                        medChecked = !value;
                        highChecked = !value;
                      }
                    });
                  }),
              new CheckboxListTile(
                  title: Text('Low', style: TextStyle(fontSize: 13)),
                  value: lowChecked,
                  onChanged: (bool value) {
                    setState(() {
                      if (value == true) {
                        vLowChecked = !value;
                        lowChecked = value;
                        medChecked = !value;
                        highChecked = !value;
                      }
                    });
                  }),
              new CheckboxListTile(
                  title: Text('Medium', style: TextStyle(fontSize: 13)),
                  value: medChecked,
                  onChanged: (bool value) {
                    setState(() {
                      if (value == true) {
                        vLowChecked = !value;
                        lowChecked = !value;
                        medChecked = value;
                        highChecked = !value;
                      }
                    });
                  }),
              new CheckboxListTile(
                  title: Text('High', style: TextStyle(fontSize: 13)),
                  value: highChecked,
                  onChanged: (bool value) {
                    setState(() {
                      if (value == true) {
                        vLowChecked = !value;
                        lowChecked = !value;
                        medChecked = !value;
                        highChecked = value;
                      }
                    });
                  }),
            ],
          ),
          Divider(color: Colors.grey),
          // Repeat
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text('Repeat',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Switch(
                onChanged: (value) {
                  setState(() {
                    repeatVal = value;
                  });
                },
                value: repeatVal,
              )
            ],
          ),
          Divider(color: Colors.grey),
          // Overwrite
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text('Overwrite',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Switch(
                onChanged: (value) {
                  setState(() {
                    overwriteVal = value;
                  });
                },
                value: overwriteVal,
              )
            ],
          ),
          // Save Button
          new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            RaisedButton(
              elevation: 5,
              padding: EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 50.0, right: 50.0),
              child: Text('Save'),
              textColor: Colors.white,
              color: Colors.purple,
              onPressed: () => onSaved(),
            )
          ])
        ],
      ),
    );
  }
}
