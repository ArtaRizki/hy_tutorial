import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../models/measurement_model.dart';
import '../models/session_model.dart';

/// Singleton helper untuk SQLite database.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    log('[DB] opening database at $path');
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        name          TEXT    NOT NULL,
        part_number   TEXT,
        operator_name TEXT,
        tolerance_min REAL    NOT NULL,
        tolerance_max REAL    NOT NULL,
        unit          TEXT    NOT NULL DEFAULT 'mm',
        created_at    TEXT    NOT NULL,
        finished_at   TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE measurements (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id  INTEGER NOT NULL,
        value_mm    REAL    NOT NULL,
        status      TEXT    NOT NULL,
        timestamp   TEXT    NOT NULL,
        note        TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
      )
    ''');
    log('[DB] tables created');
  }

  // ── Sessions CRUD ─────────────────────────────────────────────

  Future<int> insertSession(Session session) async {
    final db = await database;
    final map = session.toMap()..remove('id');
    final id = await db.insert('sessions', map);
    log('[DB] session inserted id=$id');
    return id;
  }

  Future<List<Session>> getSessions() async {
    final db = await database;
    final rows = await db.query('sessions', orderBy: 'created_at DESC');
    return rows.map(Session.fromMap).toList();
  }

  Future<Session?> getSession(int id) async {
    final db = await database;
    final rows =
        await db.query('sessions', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Session.fromMap(rows.first);
  }

  Future<int> updateSession(Session session) async {
    final db = await database;
    return await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  // ── Measurements CRUD ─────────────────────────────────────────

  Future<int> insertMeasurement(Measurement m) async {
    final db = await database;
    final map = m.toMap()..remove('id');
    final id = await db.insert('measurements', map);
    log('[DB] measurement inserted id=$id value=${m.valueMm}');
    return id;
  }

  Future<List<Measurement>> getMeasurements(int sessionId) async {
    final db = await database;
    final rows = await db.query(
      'measurements',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return rows.map(Measurement.fromMap).toList();
  }

  Future<int> deleteMeasurement(int id) async {
    final db = await database;
    return await db.delete('measurements', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteLastMeasurement(int sessionId) async {
    final db = await database;
    final rows = await db.query(
      'measurements',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    final lastId = rows.first['id'] as int;
    return await db
        .delete('measurements', where: 'id = ?', whereArgs: [lastId]);
  }
}
