import 'package:blog_note_android/models/check_list_note.dart';
import 'package:blog_note_android/models/note.dart';
import 'package:blog_note_android/models/text_note.dart';
import 'package:blog_note_android/repositories/note_repository.dart';
import 'package:flutter/material.dart';

class NoteViewModel extends ChangeNotifier {
  final NoteRepository _textRepo;
  final NoteRepository _checklistRepo;

  List<Note> notes = [];
  bool isLoading = false;
  String? errorMessage;         // ← nuevo

  NoteViewModel({
    required NoteRepository textRepository,
    required NoteRepository checklistRepository,
  })  : _textRepo = textRepository,
        _checklistRepo = checklistRepository;

  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;        // ← limpia error anterior
    notifyListeners();

    try {
      final textNotes = await _textRepo.getAll();
      final checklists = await _checklistRepo.getAll();

      notes = [...textNotes, ...checklists]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      errorMessage = 'Error al cargar las notas';
    } finally {
      isLoading = false;        // ← siempre se ejecuta
      notifyListeners();
    }
  }

  Future<void> saveNote(Note note) async {
    try {
      if (note is TextNote) {
        await _textRepo.save(note);
      } else if (note is ChecklistNote) {
        await _checklistRepo.save(note);
      }
      await loadAll();
    } catch (e) {
      errorMessage = 'Error al guardar la nota';
      notifyListeners();
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      if (note is TextNote) {
        await _textRepo.delete(note.id!);
      } else if (note is ChecklistNote) {
        await _checklistRepo.delete(note.id!);
      }
      await loadAll();
    } catch (e) {
      errorMessage = 'Error al eliminar la nota';
      notifyListeners();
    }
  }
}