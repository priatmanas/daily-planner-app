import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'daily_plan.dart';

class DatabaseConnection {
  // Singleton Pattern (Sama seperti DatabaseHelper)
  DatabaseConnection._privateConstructor();
  static final DatabaseConnection instance =
      DatabaseConnection._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Hapus tanda seru (!) di sini karena _initDatabase bisa null di kode kamu
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
      // Pastikan kolom 'weekday' ada (jika aplikasi diupdate dari versi lama)
      try {
        var info = await db.rawQuery("PRAGMA table_info(daily_plan)");
        bool hasWeekday = info.any((col) => col['name'] == 'weekday');
        if (!hasWeekday) {
          await db.execute(
            "ALTER TABLE daily_plan ADD COLUMN weekday TEXT DEFAULT ''",
          );
        }
      } catch (e) {
        // Jika tabel belum ada, _onCreate akan membuatnya saat pertama kali.
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
    // Membuat tabel sesuai dengan atribut yang ada di model DailyPlan
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

  // --- CRUD METHODS (Disesuaikan dengan kebutuhan DailyPlan) ---

  // Sama seperti 'ambilSemuaMahasiswa' tapi untuk Plan
  Future<List<DailyPlan>> getPlans() async {
    Database db = await instance.database;
    // Kita urutkan berdasarkan startTime agar jadwal tampil urut
    var plans = await db.query('daily_plan', orderBy: 'startTime ASC');

    List<DailyPlan> planList = plans.isNotEmpty
        ? plans.map((e) => DailyPlan.fromMap(e)).toList()
        : [];
    return planList;
  }

  // Ambil rencana berdasarkan nama hari (misal: 'Senin')
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

  // Sama seperti 'add' di helper
  Future<int> addPlan(DailyPlan plan) async {
    Database db = await instance.database;
    return await db.insert('daily_plan', plan.toMap());
  }

  // Sama seperti 'remove' di helper
  Future<int> removePlan(int id) async {
    Database db = await instance.database;
    return await db.delete('daily_plan', where: 'id = ?', whereArgs: [id]);
  }

  // Sama seperti 'update' di helper
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
