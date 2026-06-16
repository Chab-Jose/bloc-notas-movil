
import 'package:sqflite/sqflite.dart';

class NoteDao {
  final Database db;

  NoteDao(this.db);

  // ─────────────────────────────────────────
  // Notas de texto
  // ─────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllText() async {
    return await db.query(
      'notes',
      where: 'type = ?',
      whereArgs: ['text'],
      orderBy: 'created_at DESC',
    );
  }

  // ─────────────────────────────────────────
  // Notas checklist
  // ─────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllChecklists() async {
    // Trae todas las notas tipo checklist
    final notes = await db.query(
      'notes',
      where: 'type = ?',
      whereArgs: ['checklist'],
      orderBy: 'created_at DESC',
    );

    // Por cada nota, busca sus items
    final result = <Map<String, dynamic>>[];

    for (final note in notes) {
      final items = await db.query(
        'check_items',
        where: 'note_id = ?',
        whereArgs: [note['id']],
      );

      result.add({
        ...note,
        'items': items, // agrega los items al mapa de la nota
      });
    }

    return result;
  }

  // ─────────────────────────────────────────
  // Compartidos
  // ─────────────────────────────────────────

  Future<Map<String, dynamic>?> getById(int id) async {
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final note = maps.first;

    // Si es checklist, agrega sus items
    if (note['type'] == 'checklist') {
      final items = await db.query(
        'check_items',
        where: 'note_id = ?',
        whereArgs: [id],
      );
      return {...note, 'items': items};
    }

    return note;
  }

  Future<int> save(Map<String, dynamic> json) async {
    final items = json['items'] as List<dynamic>?;

    // Inserta o actualiza la nota principal
    final noteMap = Map<String, dynamic>.from(json)..remove('items');

    final id = await db.insert(
      'notes',
      noteMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Si tiene items (checklist), guárdalos
    if (items != null) {
      await _saveItems(id, items);
    }

    return id;
  }

  Future<int> delete(int id) async {
    // Borra primero los items relacionados
    await db.delete(
      'check_items',
      where: 'note_id = ?',
      whereArgs: [id],
    );

    // Luego borra la nota
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────────────────────
  // Privado — guarda items de checklist
  // ─────────────────────────────────────────

  Future<void> _saveItems(int noteId, List<dynamic> items) async {
    // Borra los items anteriores de esa nota
    await db.delete(
      'check_items',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );

    // Inserta los nuevos
    for (final item in items) {
      final map = Map<String, dynamic>.from(item as Map);
      map['note_id'] = noteId; // relaciona el item con la nota
      map.remove('id');        // deja que SQLite genere el id

      await db.insert('check_items', map);
    }
  }
}