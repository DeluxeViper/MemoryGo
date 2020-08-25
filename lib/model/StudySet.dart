import '../constants.dart';

class StudySet {
  int _id;
  String _title;
  String _date;
  int _numCards;

  // Setting
  String _duration;
  String _frequency;
  bool _repeat;
  bool _overwrite;

  StudySet(this._title, this._numCards) {
    _date = getCurrentDate();

    // Setting Default
    _duration = durationList[0];
    _frequency = freqList[2];
    _repeat = false;
    _overwrite = false;
  }

  StudySet.withId(this._id, this._title, this._numCards) {
    _date = getCurrentDate();
  }

  int get id => _id;

  String get title => _title;

  String get date => _date;

  int get numCards => _numCards;

  String get duration => _duration;

  String get frequency => _frequency;

  bool get repeat => _repeat;

  bool get overwrite => _overwrite;

  set title(String newTitle) {
    this._title = newTitle;
  }

  set numCards(int newNum) {
    this._numCards = newNum;
  }

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

  // Convert a StudySet object into a Map object
  Map<String, dynamic> setToMap() {
    var studySetMap = Map<String, dynamic>();
    if (id != null) {
      studySetMap['id'] = _id;
    }
    studySetMap['title'] = _title;
    studySetMap['date'] = _date;
    studySetMap['numCards'] = _numCards.toString();

    // Settings
    studySetMap['duration'] = _duration;
    studySetMap['frequency'] = _frequency;
    studySetMap['repeat'] = _repeat.toString();
    studySetMap['overwrite'] = _overwrite.toString();

    return studySetMap;
  }

  // Extract a StudySet object from a Map object
  StudySet.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._date = map['date'];
    this._numCards = int.parse(map['numCards']);

    // Settings
    this._duration = map['duration'];
    this._frequency = map['frequency'];
    if (map['repeat'] == 'true') {
      this._repeat = true;
    } else {
      this._repeat = false;
    }
    if (map['overwrite'] == 'true') {
      this._overwrite = true;
    } else {
      this._overwrite = false;
    }
  }

  // Retrieve current date & time and format it
  String getCurrentDate() {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate =
        "${dateParse.day.toString().padLeft(2, '0')}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.year} ${dateParse.hour.toString().padLeft(2, '0')}:${dateParse.minute.toString().padLeft(2, '0')}";

    return formattedDate;
  }

  String toString() {
    return 'id: ${this._id}, title: ${this._title}, date: ${this._date}, numCards: ${this._numCards}, duration: ${this._duration}, frequency: ${this._frequency}, repeat: ${this._repeat}, overwrite: ${this.overwrite}';
  }
}
