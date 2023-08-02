import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper.internal();

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    print(databasesPath);
    String path = join(databasesPath, 'gym.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute('''
    CREATE TABLE exercise(
      id INTEGER PRIMARY KEY,
      name TEXT,
      sets INTEGER,
      weight INTEGER,
      reps INTEGER,
      date TEXT,
      duration TEXT
    )
  ''');
  }

  // Function to insert data to the database
  Future<void> insertExercise({
    required String name,
    required int sets,
    required int weight,
    required int reps,
    required String date,
    required String duration,
  }) async {
    final db = await this.db;
    if (db == null) return;

    await db.insert(
      'exercise',
      {
        'name': name,
        'sets': sets,
        'weight': weight,
        'reps': reps,
        'date': date,
        'duration': duration,
      },
    );
  }

  // Function to get all workout dates from the database
  Future<List<String>> getDates() async {
    final db = await this.db;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT DISTINCT date FROM exercise');
    return List.generate(maps.length, (i) {
      return maps[i]['date'];
    });
  }

  // Funtcion to get duration of a spefic workout date
  Future<String> getDuration(String date) async {
    final db = await this.db;
    if (db == null) return '';

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT duration FROM exercise WHERE date = "$date"');

    return maps[0]
        ['duration']; // Return an empty string if no results are found.
  }

  // Function to calculate the total weight for a specific day
  Future<int> getTotalWeight(String date) async {
    final db = await this.db;
    if (db == null) return 0;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT SUM(weight) AS total_weight 
      FROM exercise 
      WHERE date = "$date"
    ''');

    // Extract the total weight from the query result
    int totalWeight = maps[0]['total_weight'] ?? 0;
    return totalWeight;
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final databasePath = join(dbPath, 'gym.db');
    await databaseFactory
        .deleteDatabase(databasePath); // Now delete the database file.

    // After deleting, set _db to null so that it can be re-initialized if needed.
    _db = null;
  }

  // Add this function to the DatabaseHelper class
  Future<List<Map<String, dynamic>>> getExercisesByDate(String date) async {
    final db = await this.db;
    if (db == null) return [];

    return await db
        .rawQuery('SELECT DISTINCT name FROM exercise WHERE date = "$date"');
  }

  // Function to get the amount of sets for an exercise on a specific date
  Future<int> getSets(String date, String name) async {
    final db = await this.db;
    if (db == null) return 0;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT MAX(sets) AS total_sets
      FROM exercise 
      WHERE date = "$date" AND name = "$name"
    ''');

    // Extract the total sets from the query result
    int totalSets = maps[0]['total_sets'] ?? 0;
    return totalSets;
  }
}
