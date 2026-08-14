import 'package:sqflite/sqflite.dart';

class PreferencesDao {
  final Database db;

  PreferencesDao(this.db);

  Future<String?> getString(String key) async {
    final result = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  Future<void> setString(String key, String value) async {
    await db.insert(
      'preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}