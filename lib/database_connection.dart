import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'daily_plan.dart';

class DatabaseConnection {
  DatabaseConnection._privateConstructor();
  static final DatabaseConnection instance =
      DatabaseConnection._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    var db = await _initDatabase();

    if (db == null) {
      throw Exception("Gagal inisialisasi database");
    }

    _database = db;
    return _database!;
  }

  // Future<Database> _initDatabase() async {
  //   Directory ambilDirectory = await getApplicationDocumentsDirectory();
  //   // Nama database disesuaikan untuk daily plan
  //   String path = join(ambilDirectory.path, 'dailyplan.db');
  //   return await openDatabase(path, version: 1, onCreate: _onCreate);
  // }

  Future<Database?> _initDatabase() async {
    try {
      Directory ambilDirectory = await getApplicationDocumentsDirectory();
      String path = join(ambilDirectory.path, 'dailyplan.db');
      Database db = await openDatabase(path, version: 1, onCreate: _onCreate);
      try {
        var info = await db.rawQuery("PRAGMA table_info(daily_plan)");
        bool hasWeekday = info.any((col) => col['name'] == 'weekday');
        if (!hasWeekday) {
          await db.execute(
            "ALTER TABLE daily_plan ADD COLUMN weekday TEXT DEFAULT ''",
          );
        }
      } catch (e) {
        print('Info migration: $e');
      }
      print("Database berhasil diinisialisasi di: $path");
      return db;
    } catch (e) {
      print("Error saat inisialisasi database: $e");
      return null;
    }
  }

  Future _onCreate(Database db, int versi) async {
    await db.execute("""
      CREATE TABLE daily_plan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        desc TEXT,
        startTime TEXT,
        finishTime TEXT,
        weekday TEXT
      )
    """);
  }

  Future<List<DailyPlan>> getPlans() async {
    Database db = await instance.database;
    var plans = await db.query('daily_plan', orderBy: 'startTime ASC');

    List<DailyPlan> planList = plans.isNotEmpty
        ? plans.map((e) => DailyPlan.fromMap(e)).toList()
        : [];
    return planList;
  }

  Future<List<DailyPlan>> getPlansByWeekday(String weekday) async {
    Database db = await instance.database;
    var plans = await db.query(
      'daily_plan',
      where: 'weekday = ?',
      whereArgs: [weekday],
      orderBy: 'startTime ASC',
    );

    List<DailyPlan> planList = plans.isNotEmpty
        ? plans.map((e) => DailyPlan.fromMap(e)).toList()
        : [];
    return planList;
  }

  Future<int> addPlan(DailyPlan plan) async {
    Database db = await instance.database;
    return await db.insert('daily_plan', plan.toMap());
  }

  Future<int> removePlan(int id) async {
    Database db = await instance.database;
    return await db.delete('daily_plan', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updatePlan(DailyPlan plan) async {
    Database db = await instance.database;
    return await db.update(
      'daily_plan',
      plan.toMap(),
      where: "id = ?",
      whereArgs: [plan.id],
    );
  }
}
