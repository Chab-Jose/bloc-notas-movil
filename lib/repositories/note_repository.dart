import 'package:blog_note_android/models/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getAll();
  Future<Note?> getById(int id);
  Future<int> save(Note note);
  Future<int> delete(int id);
}