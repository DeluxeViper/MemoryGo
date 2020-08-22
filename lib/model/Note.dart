class Note {
  int _id;
  int _studySetId;
  String _title;
  String _body;
  String _date;

  Note(this._studySetId, this._title, this._body) {
    this._date = getCurrentDate();
  }

  Note.withId(this._id, this._studySetId, this._title, this._body) {
    this._date = getCurrentDate();
  }

  int get id => _id;

  int get studySetId => _studySetId;

  String get title => _title;

  String get body => _body;

  String get date => _date;

  set title(String newTitle) {
    this._title = newTitle;
  }

  set body(String newBody) {
    this._body = newBody;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> noteToMap() {
    var noteMap = Map<String, dynamic>();
    if (id != null) {
      noteMap['id'] = _id;
    }
    noteMap['studySetId'] = _studySetId;
    noteMap['title'] = _title;
    noteMap['body'] = _body;
    noteMap['date'] = _date;

    return noteMap;
  }

  // Extract a Note object from a Map object
  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._studySetId = map['studySetId'];
    this._title = map['title'];
    this._body = map['body'];
    this._date = map['date'];
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
    return 'id: $id, studySetId: $studySetId, title: $title, body: $body, date: $date';
  }
}
