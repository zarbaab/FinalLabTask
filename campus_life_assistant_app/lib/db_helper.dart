import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('class_schedule.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2, // Increment version for schema changes
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Handles upgrades
    );
  }

  Future<void> _createDB(Database db, int version) async {
    print("Creating database...");

    // Classes table
    await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');
    print("Table 'classes' created successfully.");

    // Assignments table
    await db.execute('''
      CREATE TABLE assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT NOT NULL,
        due_time TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0
      )
    ''');
    print("Table 'assignments' created successfully.");
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion...");
    if (oldVersion < 2) {
      // Add assignments table if upgrading from version 1 to 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS assignments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          due_date TEXT NOT NULL,
          due_time TEXT NOT NULL,
          is_completed INTEGER DEFAULT 0
        )
      ''');
      print("Upgraded database with 'assignments' table.");
    }
  }

  // Add assignment
  Future<int> addAssignment(Map<String, dynamic> assignmentData) async {
    final db = await instance.database;
    return await db.insert('assignments', assignmentData);
  }

  // Get assignments
  Future<List<Map<String, dynamic>>> getAssignments() async {
    final db = await database;
    return await db.query(
      'assignments',
      orderBy: 'due_date ASC',
    );
  }

  // Update assignment
  Future<int> updateAssignment(int id, Map<String, dynamic> updatedData) async {
    final db = await instance.database;
    return await db.update(
      'assignments',
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark assignment as completed
  Future<int> updateAssignmentCompletion(int id, int isCompleted) async {
    final db = await database;
    return await db.update(
      'assignments',
      {'is_completed': isCompleted},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete assignment
  Future<int> deleteAssignment(int id) async {
    final db = await database;
    return await db.delete('assignments', where: 'id = ?', whereArgs: [id]);
  }

  // Add class
  Future<int> addClassRecord(Map<String, dynamic> classData) async {
    try {
      final db = await instance.database;
      return await db.insert('classes', classData);
    } catch (e) {
      print("Error adding class: $e");
      rethrow;
    }
  }

  // Get classes
  Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final db = await instance.database;
      return await db.query('classes', orderBy: 'id DESC');
    } catch (e) {
      print("Error retrieving classes: $e");
      rethrow;
    }
  }

  // Update class
  Future<int> updateClass(int id, Map<String, dynamic> updatedData) async {
    try {
      final db = await instance.database;
      return await db.update(
        'classes',
        updatedData,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error updating class: $e");
      rethrow;
    }
  }

  Future<int> markAssignmentCompleted(int id, int isCompleted) async {
    final db = await instance.database;
    return await db.update(
      'assignments',
      {'is_completed': isCompleted},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete class
  Future<int> deleteClass(int id) async {
    try {
      final db = await instance.database;
      return await db.delete('classes', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print("Error deleting class: $e");
      rethrow;
    }
  }
}
