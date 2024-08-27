import 'package:flutter/material.dart';
import 'package:notes_app_sqflite_flutter/screens/note_detail.dart';
import 'dart:async';
import 'package:notes_app_sqflite_flutter/models/note.dart';
import 'package:notes_app_sqflite_flutter/utilities/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper(); // instance of database helper class
  List<Note> noteList = []; // Initialized the list properly
  int count = 0;
  String titlee = 'Edit Note';

  @override
  Widget build(BuildContext context) {
    if (noteList.isEmpty) {
      updateListView();
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber.shade600,
        shape: const CircleBorder(),
        onPressed: () {
          setState(() {
            titlee = 'Add New Note';
          });
          navigateToDetail(Note('', ''), titlee);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text(
          "Notes_App",
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber.shade600,
      ),
      body: ListView.builder(
          itemCount: count,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber.shade600,
                  child: const Icon(
                    Icons.note_sharp,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  noteList[index].title.toString(),
                  style:const TextStyle(fontSize: 22),
                ),
                subtitle: Text(
                  noteList[index].date.toString(),
                  style:const TextStyle(fontSize: 18),
                ),
                trailing: GestureDetector(
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onTap: () {
                    _delete(context, noteList[index]);
                  },
                ),
                onTap: () {
                  setState(() {
                    titlee = 'Edit Note';
                  });
                  navigateToDetail(noteList[index], titlee);
                },
              ),
            );
          }),
    );
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id!);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    // Getting instance of the database
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note: note, appbarTitle: title);
    }));

    if (result == true) {
      updateListView();
    }
  }
}
