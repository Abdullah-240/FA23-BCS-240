import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:studentapp/models/person.dart';

class DatabaseHelper {
  static const _databaseName = 'persons.db';
  static const _databaseVersion = 2; // Incremented version

  static const table = 'persons';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnEmail = 'email';
  static const columnAge = 'age';
  static const columnImage = 'image';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnAge INTEGER NOT NULL,
        $columnImage TEXT
      )
      ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE $table ADD COLUMN $columnAge INTEGER NOT NULL DEFAULT 0");
      await db.execute("ALTER TABLE $table ADD COLUMN $columnImage TEXT");
    }
  }

  Future<int> insert(Person person) async {
    final db = await instance.database;
    return await db.insert(table, person.toMap());
  }

  Future<List<Person>> getAllPersons() async {
    final db = await instance.database;
    final maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Person.fromMap(maps[i]);
    });
  }

  Future<int> update(Person person) async {
    final db = await instance.database;
    final id = person.id;
    return await db.update(table, person.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    final db = await instance.database;
    return await db.delete(table);
  }
}
