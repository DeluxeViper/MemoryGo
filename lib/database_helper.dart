import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import 'model/Note.dart';
import 'model/StudySet.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String studySetsTable = 'studyset_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colNumCards = 'numCards';

  // Study set Settings columns
  String colDur = 'duration';
  String colFreq = 'frequency';
  String colRepeat = 'repeat';
  String colOvwrite = 'overwrite';

  // Notes relevant columns
  String notesTable = 'notes_table';
  String colStudySetId = 'studySetId';
  String colBody = 'body';

  DatabaseHelper._createInstance(); // Create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'memoryGoDatabase.db';

    // open/create database at path
    var memoryGoDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);

    return memoryGoDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $studySetsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colNumCards TEXT, $colDur TEXT, $colFreq TEXT, $colRepeat TEXT, $colOvwrite TEXT)');

    await db.execute(
        'CREATE TABLE $notesTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colStudySetId INTEGER, $colTitle TEXT, $colBody TEXT, $colDate TEXT)');
  }

  // STUDYSETS CRUD Operations

  // Fetch Operation: Get all studyset objects from database
  Future<List<Map<String, dynamic>>> getStudySetMapList() async {
    Database db = await this.database;

    var result = await db.query(studySetsTable, orderBy: '$colId ASC');
    return result;
  }

  // Insert Operation: Insert studyset object to database
  Future<int> insertStudySet(StudySet studySet) async {
    Database db = await this.database;
    var result = await db.insert(studySetsTable, studySet.setToMap());
    print('Inserting into database');
    return result;
  }

  // Update Operation: Update a studyset object and save it to database
  Future<int> updateStudySet(StudySet studySet) async {
    var db = await this.database;
    var result = await db.update(studySetsTable, studySet.setToMap(),
        where: '$colId = ?', whereArgs: [studySet.id]);
    return result;
  }

  // Delete Operation: Delete a studyset object from database
  Future<int> deleteStudySet(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $studySetsTable WHERE $colId = $id');
    return result;
  }

  // Get number of studyset objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $studySetsTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'studyset List' [ List<StudySet> ]
  Future<List<StudySet>> getStudySetList() async {
    var studySetMapList = await getStudySetMapList();
    int count = studySetMapList.length;

    List<StudySet> studySetList = List<StudySet>();
    for (int i = 0; i < count; i++) {
      studySetList.add(StudySet.fromMapObject(studySetMapList[i]));
    }

    return studySetList;
  }

  // NOTES CRUD Operations
  // Fetch Operation: Get all notes object from a studyset
  Future<List<Map<String, dynamic>>> getNotesMapList(int studySetId) async {
    Database db = await this.database;

    String whereString = '$colStudySetId = ?';
    List<dynamic> whereArguments = [studySetId];
    var result = await db.query(notesTable,
        where: whereString, whereArgs: whereArguments);

    // Printing results
    result.forEach((row) {
      print(row);
    });

    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(notesTable, note.noteToMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(notesTable, note.noteToMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteNote(int noteId) async {
    var db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $notesTable WHERE $colId = $noteId');
    return result;
  }

  // Get number of notes in a studyset in database
  Future<int> getNotesCountInSet(int studySetId) async {
    var db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT COUNT (*) from $notesTable WHERE $colStudySetId = $studySetId)');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note list' [ List<Note> ]
  Future<List<Note>> getNoteList(int studySetId) async {
    var noteMapList = await getNotesMapList(studySetId);
    List<Note> noteList = List<Note>();

    noteMapList.forEach((element) {
      noteList.add(Note.fromMapObject(element));
    });

    return noteList;
  }
}
