import 'dart:async';
import 'dart:io';
import 'package:notes_app_sqflite_flutter/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() { //factory constructor heps us to return a value
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  // Table and database names
  final String noteTable = 'note_table';
  final String colId = 'id';
  final String colTitle = 'title';
  final String colDescription = 'description';
  final String colDate = 'date';

  // Database getter
  Future<Database> get database async {
    _database ??= await initializeDatabase(); //if _database is null then ....
    return _database!;
  }

  // Initialize the database
  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'notes.db');

    // Open or create the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  // Create the database and the notes table
  void _createDb(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
      '$colDescription TEXT, $colDate TEXT)',
    );
  }

  // CRUD Operations

  // Insert a Note object into the database
  Future<int> insertNote(Note note) async {
    Database db = await database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Retrieve a list of all Note objects(maps) from the database
  Future<List<Map<String, Object?>>> getNoteMapList() async {
    Database db =   await this.database;

    var result = await db.query(noteTable, orderBy: '$colId ASC');

    return result;
  }

  // Update a Note object in the database
  Future<int> updateNote(Note note) async {
    Database db = await database;
    var result = await db.update(
      noteTable,
      note.toMap(),
      where: '$colId = ?',
      whereArgs: [note.id],
    );
    return result;
  }

  // Delete a Note object from the database
  Future<int> deleteNote(int id) async {
    Database db = await database;
    var result = await db.delete(
      noteTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }

  // Get the number of Note objects in the database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int? result = Sqflite.firstIntValue(x);
    return result ?? 0;
  }

  // Close the database
  Future close() async {
    Database db = await database;
    await db.close();
  }

  //convert map to list
  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteMapList(); //get map
    int count = noteMapList.length; //count number of map entries in database

    //creating n empty list of note

    List<Note> noteList = <Note>[];

    //for loop to copy every item from map list to our note list
    for(int i = 0; i<count;i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}
