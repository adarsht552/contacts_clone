import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        company TEXT,
        address TEXT,
        notes TEXT,
        photoPath TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // CRUD Operations
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      orderBy: 'firstName ASC, lastName ASC',
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<List<Contact>> getFavoriteContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'firstName ASC, lastName ASC',
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<Contact?> getContactById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Contact.fromMap(maps.first);
  }

  Future<List<Contact>> searchContacts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where:
          'firstName LIKE ? OR lastName LIKE ? OR phoneNumber LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'firstName ASC, lastName ASC',
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(String id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(String id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'contacts',
      {
        'isFavorite': isFavorite ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String()
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
