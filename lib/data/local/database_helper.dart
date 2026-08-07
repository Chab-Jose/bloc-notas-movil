import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        title      TEXT NOT NULL,
        content    TEXT,
        type       TEXT NOT NULL,
        category   TEXT NOT NULL DEFAULT 'purple',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE check_items (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        note_id  INTEGER NOT NULL,
        content  TEXT NOT NULL,
        isDone   INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (note_id) REFERENCES notes(id)
      )
    ''');
  }
}