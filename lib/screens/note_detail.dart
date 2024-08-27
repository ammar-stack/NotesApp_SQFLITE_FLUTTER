import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app_sqflite_flutter/models/note.dart';
import 'package:notes_app_sqflite_flutter/utilities/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appbarTitle;
  final Note? note;

  NoteDetail({super.key, this.note, required this.appbarTitle});

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  Note? note;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  DatabaseHelper helper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    note = widget.note ?? Note('', '');
    titleController = TextEditingController(text: note?.title ?? '');
    descriptionController = TextEditingController(text: note?.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            icon: const Icon(Icons.arrow_back)),
        title: Text(widget.appbarTitle,
            style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.amber.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  hintText: 'Enter Title'),
              onChanged: (value) {
                updateTitle();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextField(
                controller: descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 7,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    hintText: 'Enter Description'),
                onChanged: (value) {
                  updateDescription();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      _save();
                    },
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.amber.shade600,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: const Center(
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _delete();
                    },
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.amber.shade600,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: const Center(
                        child: Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void updateTitle() {
    note?.title = titleController.text;
  }

  void updateDescription() {
    note?.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();

    note!.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note!.id != null) {
      // update operation
      result = await helper.updateNote(note!);
    } else {
      // insert operation
      result = await helper.insertNote(note!);
    }

    if (result != 0) {
      // success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void _delete() async {
    moveToLastScreen();
    // Case 1: If the user is trying to delete a new note
    if (note!.id == null) {
      _showAlertDialog('Status', 'No Note Was Deleted');
      return;
    }
    // Case 2: If the user is trying to delete an existing note
    int result = await helper.deleteNote(note!.id!);
    if (result != 0) {
      // success
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      // failure
      _showAlertDialog('Status', 'Problem Deleting Note');
    }
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
}
