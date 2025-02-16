import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path =
        join(await getDatabasesPath(), 'attendance_tracker_database.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _migrateToAddSoftDelete,
    );
  }

  Future<String?> exportDatabase(String path) async {
    String dbPath = _database!.path;
    String exportPath = join(path, "export");
    if (!await Directory(exportPath).exists()) {
      await Directory(exportPath).create(recursive: true);
    }
    // Copy database file to export directory
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String exportFilePath =
        join(exportPath, "attendance_tracker_$timestamp.db");

    try {
      await _database!.close();
      File dbFile = File(dbPath);
      await dbFile.copy(exportFilePath);
      // Reopen the database
      _database = null;
      await database;
      return exportFilePath;
    } catch (e) {
      // Ensure database is reopened even if export fails
      _database = null;
      await database;
      return null;
    }
  }

  // Add this method to your DatabaseHelper class
  Future<bool> importDatabase(String importPath) async {
    File importFile = File(importPath);
    if (!await importFile.exists()) {
      throw Exception('Import file does not exist');
    }

    // Get current database path
    String currentDbPath = _database!.path;

    // Create backup of existing database
    String backupPath = '$currentDbPath.backup.db';
    await File(currentDbPath).copy(backupPath);

    try {
      await _database!.close();
      await importFile.copy(currentDbPath);
      // Reopen database
      _database = null;
      await database;
      await _validateDatabaseStructure();

      return true;
    } catch (e) {
      // Restore backup if import fails
      if (await File(backupPath).exists()) {
        await File(backupPath).copy(currentDbPath);
        await File(backupPath).delete();
      }

      _database = null;
      var db = await database;
      await db.execute('PRAGMA foreign_keys = ON');
      return false;
    }
  }

// Add validation helper method
  Future<void> _validateDatabaseStructure() async {
    final db = await database;

    // Verify tables exist
    List<String> requiredTables = [
      'Users',
      'Groups',
      'Subjects',
      'GroupUsers',
      'Attendance'
    ];
    for (String tableName in requiredTables) {
      var result = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type="table" AND name="$tableName"');
      if (result.isEmpty) {
        throw Exception('Missing required table: $tableName');
      }
    }

    // Verify foreign key constraints
    var fkResult = await db.rawQuery('PRAGMA foreign_key_check');
    if (fkResult.isNotEmpty) {
      throw Exception('Foreign key violations detected');
    }

    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = OFF');

    // Create Users table
    await db.execute('''CREATE TABLE Users (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      fatherName TEXT,
      primaryGroup INTEGER,
      deleted BOOLEAN DEFAULT 0,
      deletedAt DATETIME,
      FOREIGN KEY (primaryGroup) REFERENCES Groups(id) ON DELETE SET NULL
    )''');

    // Create Groups table
    await db.execute('''CREATE TABLE Groups (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      deleted BOOLEAN DEFAULT 0,
      deletedAt DATETIME
    )''');

    // Create Subjects table
    await db.execute('''CREATE TABLE Subjects (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      groupId INTEGER NOT NULL,
      deleted BOOLEAN DEFAULT 0,
      deletedAt DATETIME,
      FOREIGN KEY (groupId) REFERENCES Groups(id)
    )''');

    // Create GroupUsers table
    await db.execute('''
      CREATE TABLE GroupUsers (
        groupId TEXT NOT NULL,
        userId TEXT NOT NULL,
        PRIMARY KEY (groupId, userId),
        FOREIGN KEY (groupId) REFERENCES Groups(id),
        FOREIGN KEY (userId) REFERENCES Users(id)
      )
    ''');

    // Create Attendance table
    await db.execute('''CREATE TABLE Attendance (
      id TEXT NOT NULL PRIMARY KEY,
      subjectId INTEGER NOT NULL,
      userId INTEGER NOT NULL,
      at DATE NOT NULL,
      FOREIGN KEY (subjectId) REFERENCES Subjects(id),
      FOREIGN KEY (userId) REFERENCES Users(id)
    )''');

    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Add to DatabaseHelper class
  Future<void> _migrateToAddSoftDelete(
      Database db, int oldVersion, int newVersion) async {
    // Version 2 to 3 migration - Add soft delete columns
    if (oldVersion <= 2 && newVersion >= 3) {
      // Add columns to Users table
      await db.execute('''
      ALTER TABLE Users 
      ADD COLUMN deleted BOOLEAN DEFAULT 0
      ''');

      await db.execute('''
      ALTER TABLE Users 
      ADD COLUMN deletedAt DATETIME
      ''');

      // Add columns to Groups table
      await db.execute('''
      ALTER TABLE Groups 
      ADD COLUMN deleted BOOLEAN DEFAULT 0
      ''');
      await db.execute('''
      ALTER TABLE Groups 
      ADD COLUMN deletedAt DATETIME
      ''');

      // Add columns to Subjects table
      await db.execute('''
      ALTER TABLE Subjects 
      ADD COLUMN deleted BOOLEAN DEFAULT 0
      ''');
      await db.execute('''
      ALTER TABLE Subjects 
      ADD COLUMN deletedAt DATETIME
      ''');
    }

    if (4 <= newVersion) {
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }
}
