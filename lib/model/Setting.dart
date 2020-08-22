// Settings object for StudySet
class Setting {
  String _duration;
  String _frequency;
  bool _repeat;
  bool _overwrite;

  Setting(this._duration, this._frequency) {
    _repeat = false;
    _overwrite = false;
  }

  String get duration => _duration;

  String get frequency => _frequency;

  bool get repeat => _repeat;

  bool get overwrite => _overwrite;

  set duration(String newDuration) {
    this._duration = newDuration;
  }

  set frequency(String newFreq) {
    this._frequency = newFreq;
  }

  set repeat(bool newRepeat) {
    this._repeat = newRepeat;
  }

  set overwrite(bool newOverwrite) {
    this._overwrite = newOverwrite;
  }

  // Convert a Settings object into a Map object
  Map<String, dynamic> settingToMap() {
    var settingsMap = Map<String, dynamic>();
    settingsMap['duration'] = _duration;
    settingsMap['frequency'] = _frequency;
    settingsMap['repeat'] = _repeat;
    settingsMap['overwrite'] = _overwrite;

    return settingsMap;
  }

  // Extract a Settings object from a Map object
  Setting.fromMapObject(Map<String, dynamic> map) {
    this._duration = map['duration'];
    this._frequency = map['frequency'];
    this._repeat = map['repeat'];
    this._overwrite = map['overwrite'];
  }
}
