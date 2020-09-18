import 'package:MemoryGo/constants.dart';
import 'package:MemoryGo/utils/database_helper.dart';
import 'package:MemoryGo/model/StudySet.dart';
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
      overwriteVal,
      shuffleVal;

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
    shuffleVal = studySet.shuffle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          RaisedButton.icon(
            label: Text('Save', style: TextStyle(color: Colors.white)),
            icon: Icon(
              Icons.navigate_next,
              color: Colors.white,
              semanticLabel: 'Save',
            ),
            color: kPrimaryColor,
            onPressed: () => onSaved(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new SizedBox(height: 20.0, width: double.infinity),
            // Duration
            buildCardWidget(new Row(
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
            )),
            // Frequency
            buildCardWidget(Column(
              children: [
                new Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Text('Frequency',
                        style: TextStyle(fontWeight: FontWeight.bold))),
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
              ],
            )),
            // Repeat
            buildCardWidget(new Row(
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
            )),
            // Overwrite
            buildCardWidget(new Row(
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
            )),
            // Shuffle
            buildCardWidget(new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text('Shuffle',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Switch(
                  onChanged: (value) {
                    setState(() {
                      shuffleVal = value;
                    });
                  },
                  value: shuffleVal,
                )
              ],
            )),
            // Save Button
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      elevation: 5,
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 50, right: 50),
                      child: Text('Save'),
                      textColor: Colors.white,
                      color: Colors.purple,
                      onPressed: () => onSaved(),
                    )
                  ]),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCardWidget(Widget child) {
    return Container(
        margin: EdgeInsets.all(15),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 8),
                  color: Colors.black.withAlpha(20),
                  blurRadius: 16)
            ]),
        child: child);
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

    // Shuffle of study set
    studySet.shuffle = shuffleVal;

    _updateSet(studySet);

    Navigator.pop(context);
  }

  void _updateSet(StudySet studySet) async {
    int result = await helper.updateStudySet(studySet);

    if (result != 0) {
      // Successfully saved settings
      print('Successfully saved settings');
    } else {
      // Failed to save settings
      print('Failed to save settings');
    }
  }
}
