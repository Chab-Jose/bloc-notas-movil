import 'package:blog_note_android/data/local/note_dao.dart';
import 'package:blog_note_android/models/note.dart';
import 'package:blog_note_android/models/text_note.dart';
import 'note_repository.dart';

class TextNoteRepository implements NoteRepository {
  final NoteDao _dao;

  TextNoteRepository(this._dao);

  @override
  Future<List<Note>> getAll() async {
    final maps = await _dao.getAllText(); // solo notas de texto
    return maps.map((m) => TextNote.fromJson(m)).toList();
  }

  @override
  Future<Note?> getById(int id) async {
    final map = await _dao.getById(id);
    if (map == null) return null;
    return TextNote.fromJson(map);
  }

  @override
  Future<int> save(Note note) => _dao.save(note.toJson());

  @override
  Future<int> delete(int id) => _dao.delete(id);
}