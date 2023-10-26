import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database; // Make _database nullable

  DatabaseHelper._internal();

  Future<void> deleteClass(String className) async {
    final db = await database;
    await db.delete(
      'scanned_data',
      where: 'className = ?',
      whereArgs: [className],
    );
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<ScannedData>> getAttendanceForExport(
      String className, DateTime? selectedDate) async {
    final db = await database;
    String whereClause = 'className = ?';
    List<String> whereArgs = [className];

    if (selectedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      whereClause += ' AND currentDate LIKE ?';
      whereArgs.add('$formattedDate%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'scanned_data',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) {
      return ScannedData(
        className: maps[i]['className'],
        registerNumber: maps[i]['registerNumber'],
        currentDate: DateTime.parse(maps[i]['currentDate']),
      );
    });
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'attendance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE scanned_data(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            className TEXT,
            registerNumber TEXT,
            name TEXT,
            currentDate TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertScannedData(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('scanned_data', row);
  }

  Future<List<ScannedData>> getAttendanceForDate(
      DateTime date, String className) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final List<Map<String, dynamic>> maps = await db.query(
      'scanned_data',
      where: 'className = ? AND currentDate LIKE ?',
      whereArgs: [className, '$formattedDate%'],
    );

    return List.generate(maps.length, (i) {
      return ScannedData(
        className: maps[i]['className'],
        registerNumber: maps[i]['registerNumber'],
        currentDate: DateTime.parse(maps[i]['currentDate']),
      );
    });
  }
}

class ScannedData {
  final String className;
  final String registerNumber;
  // final String name;
  final DateTime currentDate;

  ScannedData({
    required this.className,
    required this.registerNumber,
    // required this.name,
    required this.currentDate,
  });
}
