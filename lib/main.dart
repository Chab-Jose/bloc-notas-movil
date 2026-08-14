import 'package:blog_note_android/app/app.dart';
import 'package:blog_note_android/viewmodels/theme_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:blog_note_android/data/local/database_helper.dart';
import 'package:blog_note_android/data/local/preferences_dao.dart';
import 'package:blog_note_android/data/local/note_dao.dart';
import 'package:blog_note_android/repositories/checklist_note_repository.dart';
import 'package:blog_note_android/repositories/text_note_repository.dart';
import 'package:blog_note_android/viewmodels/note_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DatabaseHelper.instance.database;
  final dao = NoteDao(db);
  final prefsDao = PreferencesDao(db); // ← nuevo

  final themeViewModel = ThemeViewModel(prefsDao);
  await themeViewModel.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeViewModel), // ← pasa prefsDao
        ChangeNotifierProvider(
          create: (_) => NoteViewModel(
            textRepository: TextNoteRepository(dao),
            checklistRepository: ChecklistNoteRepository(dao),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
