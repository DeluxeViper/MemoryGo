import 'dart:io';

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  List<String> durations = <String>['30 Mins', '60 Mins', '2 Hrs'];
  String _selectedDuration = '30 Mins';
  bool vLowChecked = false,
      lowChecked = false,
      medChecked = false,
      highChecked = false,
      repeatVal = false,
      overwriteVal = false;

  void onSaved() {
    // TODO: Implement onSaved method
    Navigator.pop(context);
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
                      items: durations.map((String value) {
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
                      vLowChecked = value;
                    });
                  }),
              new CheckboxListTile(
                  title: Text('Low', style: TextStyle(fontSize: 13)),
                  value: lowChecked,
                  onChanged: (bool value) {
                    setState(() {
                      lowChecked = value;
                    });
                  }),
              new CheckboxListTile(
                  title: Text('Medium', style: TextStyle(fontSize: 13)),
                  value: medChecked,
                  onChanged: (bool value) {
                    setState(() {
                      medChecked = value;
                    });
                  }),
              new CheckboxListTile(
                  title: Text('High', style: TextStyle(fontSize: 13)),
                  value: highChecked,
                  onChanged: (bool value) {
                    setState(() {
                      highChecked = value;
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
