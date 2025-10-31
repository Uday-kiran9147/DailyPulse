import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/mood_entry.dart';

class DBService {
  static final DBService instance = DBService._init();
  static Database? _database;
  DBService._init();

  /// Get the singleton database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('daily_pulse.db');
    return _database!;
  }

  /// Initialize and open the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // ✅ Enforce foreign key constraints for future expansion
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Database creation schema
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE,
        emoji TEXT NOT NULL,
        note TEXT,
        score INTEGER NOT NULL
      )
    ''');
  }

  /// Future migration handler (safe to leave empty for now)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE moods ADD COLUMN category TEXT');
    // }
  }

  /// Insert or replace an entry
  Future<MoodEntry?> insert(MoodEntry entry) async {
    try {
      final db = await instance.database;
      // Ensure consistent date format (for uniqueness)
      final id = await db.insert(
        'moods',
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return entry.copyWith(id: id);
    } catch (e) {
      print('⚠️ DB Insert Error: $e');
      return null;
    }
  }

  /// Update an existing entry
  Future<void> update(MoodEntry entry) async {
    try {
      final db = await instance.database;
      await db.update(
        'moods',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    } catch (e) {
      print('⚠️ DB Update Error: $e');
    }
  }

  /// Fetch all moods ordered by date DESC
  Future<List<MoodEntry>> fetchAll() async {
    try {
      final db = await instance.database;
      final result = await db.query('moods', orderBy: 'date DESC');
      return result.map((e) => MoodEntry.fromMap(e)).toList();
    } catch (e) {
      print('⚠️ DB Fetch Error: $e');
      return [];
    }
  }

  /// Delete entry by ID
  Future<void> delete(int id) async {
    try {
      final db = await instance.database;
      await db.delete('moods', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('⚠️ DB Delete Error: $e');
    }
  }

  /// Delete all entries (optional for reset)
  Future<void> clearAll() async {
    try {
      final db = await instance.database;
      await db.delete('moods');
    } catch (e) {
      print('⚠️ DB Clear Error: $e');
    }
  }

  /// Safely close the database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
