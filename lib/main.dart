import 'package:blog_note_android/app/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:blog_note_android/data/local/database_helper.dart';
import 'package:blog_note_android/data/local/note_dao.dart';
import 'package:blog_note_android/repositories/checklist_note_repository.dart';
import 'package:blog_note_android/repositories/text_note_repository.dart';
import 'package:blog_note_android/viewmodels/note_viewmodel.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // requerido antes de usar plugins

  final db = await DatabaseHelper.instance.database;
  final dao = NoteDao(db);

  runApp(
    ChangeNotifierProvider(
      create: (_) => NoteViewModel(
        textRepository: TextNoteRepository(dao),
        checklistRepository: ChecklistNoteRepository(dao),
      ),
      child: const App(),
    ),
  );
}