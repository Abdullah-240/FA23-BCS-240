
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'guess_game.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_results(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guess INTEGER,
        status TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future<void> insertGuess(GameModel gameModel) async {
    final db = await database;
    await db.insert(
      'game_results',
      gameModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GameModel>> getHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('game_results', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return GameModel(
        id: maps[i]['id'],
        guess: maps[i]['guess'],
        status: maps[i]['status'],
        timestamp: DateTime.parse(maps[i]['timestamp']),
      );
    });
  }
}
