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
      duration TEXT,
      starttime TEXT,
      durationexercise TEXT
    )
  ''');
    await db.execute('''
    CREATE TABLE exerciselist(
      id INTEGER PRIMARY KEY,
      name TEXT,
      muscle TEXT,
      favorite INTEGER,
      description TEXT
    )
  ''');
  }

  // Function to insert data to the database
  Future<void> insertExercise(
      {required String name,
      required int sets,
      required int weight,
      required int reps,
      required String date,
      required String duration,
      required String startTime,
      required String exerciseduration}) async {
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
        'starttime': startTime,
        'durationexercise': exerciseduration,
      },
    );
  }

  Future<void> insertExerciseList(
      {required String name,
      required String muscle,
      required int favorite,
      required String description}) async {
    final db = await this.db;
    if (db == null) return;

    await db.insert(
      'exerciselist',
      {
        'name': name,
        'muscle': muscle,
        'favorite': favorite,
        'description': description,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllExerciseListInformation() async {
    final db = await this.db;
    if (db == null) return [];

    return await db.rawQuery('SELECT * FROM exerciselist');
  }

  Future<void> updateExerciseFavoriteStatus(
      String name, int favoriteStatus) async {
    final db = await this.db;
    if (db == null) return;

    await db.update(
      'exerciselist',
      {'favorite': favoriteStatus},
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<bool> isExerciseFavorite(String name) async {
    final db = await this.db;
    if (db == null) return false;

    final List<Map<String, dynamic>> maps = await db.query(
      'exerciselist',
      columns: ['favorite'],
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps[0]['favorite'] == 1;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getExerciseByName(String name) async {
    final db = await this.db;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'exerciselist',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps[0];
    } else {
      return null;
    }
  }

  // Function to get all workout dates from the database
  Future<List<String>> getDates() async {
    final db = await this.db;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps =
        await db.rawQuery('''SELECT DISTINCT date
    FROM exercise
    ORDER BY SUBSTR(date, 7, 4) DESC, SUBSTR(date, 4, 2) DESC, SUBSTR(date, 1, 2) DESC''');
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

    if (maps.isNotEmpty && maps[0]['duration'] != null) {
      return maps[0]['duration'];
    } else {
      return ''; // Return an empty string or a default value if no duration is found.
    }
  }

  Future<String?> getStartTime(String date) async {
    final db = await this.db;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT starttime FROM exercise WHERE date = "$date"');

    if (maps.isNotEmpty && maps[0]['starttime'] != null) {
      return maps[0]['starttime'];
    } else {
      return null; // Return null if no start time is found.
    }
  }

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

    _db = null;
  }

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

  Future<List<Map<String, dynamic>>> getExercisesWithDurationsByDate(
      String date) async {
    final db = await this.db;
    if (db == null) return [];

    return await db.rawQuery('''
    SELECT DISTINCT name, durationexercise
    FROM exercise
    WHERE date = "$date"
  ''');
  }

  // Function to get all exercises for a specific workout date
  Future<List<Map<String, dynamic>>> getAllInformationByDate(
      String date) async {
    final db = await this.db;
    if (db == null) return [];

    return await db.rawQuery('SELECT * FROM exercise WHERE date = "$date"');
  }

  Future<List<Map<String, dynamic>>> getMaxWeightRepsForExercise(
      String exerciseName) async {
    final db = await this.db;
    if (db == null) return [];

    return await db.rawQuery('''
    SELECT name, date, MAX(weight * reps) as max_weight_reps
    FROM exercise
    WHERE name = "$exerciseName"
    GROUP BY name, date
    ORDER BY date DESC
  ''');
  }

  Future<List<Map<String, dynamic>>> getMaxWeightForExercise(
      String exerciseName) async {
    final db = await this.db;
    if (db == null) return [];

    return await db.rawQuery('''
    SELECT name, date, MAX(weight) as max_weight
    FROM exercise
    WHERE name = "$exerciseName"
    GROUP BY name, date
    ORDER BY date DESC
  ''');
  }

  Future<Map<String, dynamic>> getMaxWeight(String exerciseName) async {
    final db = await this.db;
    if (db == null) return {'max_weight': 0, 'date': null};

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT MAX(weight) as max_weight, date
    FROM exercise
    WHERE name = "$exerciseName"
  ''');

    if (result.isNotEmpty) {
      return result[0];
    } else {
      return {'max_weight': 0, 'date': null};
    }
  }

  Future<Map<String, dynamic>> getMaxReps(String exerciseName) async {
    final db = await this.db;
    if (db == null) return {'max_reps': 0, 'date': null};

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT MAX(reps) as max_reps, date
    FROM exercise
    WHERE name = "$exerciseName"
  ''');

    if (result.isNotEmpty) {
      return result[0];
    } else {
      return {'max_reps': 0, 'date': null};
    }
  }

  Future<List<Map<String, dynamic>>> getMaxRepsForExercise(
      String exerciseName) async {
    final db = await this.db;
    if (db == null) return [];

    return await db.rawQuery('''
    SELECT name, date, MAX(reps) as max_reps
    FROM exercise
    WHERE name = "$exerciseName"
    GROUP BY name, date
    ORDER BY date DESC
  ''');
  }

  Map<String, List<String>> groupDatesByMonthAndYear(List<String> dates) {
    Map<String, List<String>> groupedDates = {};

    for (String date in dates) {
      DateTime dateTime = DateTime.parse(date);
      String monthYearKey =
          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}";

      if (groupedDates.containsKey(monthYearKey)) {
        groupedDates[monthYearKey]!.add(date);
      } else {
        groupedDates[monthYearKey] = [date];
      }
    }

    return groupedDates;
  }
}
