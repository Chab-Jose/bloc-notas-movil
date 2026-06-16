import 'package:blog_note_android/data/local/note_dao.dart';
import 'package:blog_note_android/models/check_list_note.dart';
import 'package:blog_note_android/models/note.dart';

import 'note_repository.dart';

class ChecklistNoteRepository implements NoteRepository {
  final NoteDao _dao;

  ChecklistNoteRepository(this._dao);

  @override
  Future<List<Note>> getAll() async {
    final maps = await _dao.getAllChecklists(); // solo checklists
    return maps.map((m) => ChecklistNote.fromJson(m)).toList();
  }

  @override
  Future<Note?> getById(int id) async {
    final map = await _dao.getById(id);
    if (map == null) return null;
    return ChecklistNote.fromJson(map);
  }

  @override
  Future<int> save(Note note) => _dao.save(note.toJson());

  @override
  Future<int> delete(int id) => _dao.delete(id);
}