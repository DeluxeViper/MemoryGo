import 'Note.dart';

class StudySet {
  int _id;
  String _title;
  String _date;
  int _numCards;
  List<Note> _notes;

  StudySet(this._title, this._numCards, this._notes) {
    _date = getCurrentDate();
  }

  StudySet.withId(this._id, this._title, this._numCards, this._notes) {
    _date = getCurrentDate();
  }

  int get id => _id;

  String get title => _title;

  String get date => _date;

  int get numCards => _numCards;

  List<Note> get notes => _notes;

  set title(String newTitle) {
    this._title = newTitle;
  }

  set numCards(int newNum) {
    this._numCards = newNum;
  }

  // TODO: CRUD operations for notes

  // Convert a StudySet object into a Map object
  Map<String, dynamic> setToMap() {
    var studySetMap = Map<String, dynamic>();
    if (id != null) {
      studySetMap['id'] = _id;
    }
    studySetMap['title'] = _title;
    studySetMap['date'] = _date;
    studySetMap['numCards'] = _numCards.toString();
    // studySetMap['notes'] = _notes;

    return studySetMap;
  }

  // Extract a StudySet object from a Map object
  StudySet.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._date = map['date'];
    this._numCards = int.parse(map['numCards']);
    // this._notes = map['notes'];
  }

  // Retrieve current date & time and format it
  String getCurrentDate() {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate =
        "${dateParse.day.toString().padLeft(2, '0')}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.year} ${dateParse.hour.toString().padLeft(2, '0')}:${dateParse.minute.toString().padLeft(2, '0')}";

    return formattedDate;
  }
}
