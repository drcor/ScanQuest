import 'package:path/path.dart';
import 'package:scan_quest_app/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ScanQuestUser.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUser (
        ${UserFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${UserFields.name} TEXT NOT NULL,             -- Name of the user
        ${UserFields.lastModification} DATETIME, -- Last user modification time
        ${UserFields.experience} INTEGER NOT NULL     -- Experience points of the user
      )
    ''');

    await db.execute('''
      INSERT INTO $tableUser (
        ${UserFields.id},
        ${UserFields.name},
        ${UserFields.lastModification},
        ${UserFields.experience}
      ) VALUES 
      ('0','Anonymous','${DateTime.now().toIso8601String()}', 0)
    ''');
  }

  Future<User?> getUser() async {
    final db = await instance.database;
    final maps = await db.query(
      tableUser,
      columns: UserFields.allValues,
      where: '${UserFields.id} = ?',
      whereArgs: [0],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<User?> update(User user) async {
    final db = await instance.database;

    await db.update(
      tableUser,
      user.toJson(),
      where: '${UserFields.id} = ?',
      whereArgs: [0],
    );

    return getUser();
  }

  Future<void> resetUser() async {
    final db = await instance.database;

    await db.update(
      tableUser,
      {
        UserFields.name: 'Anonymous',
        UserFields.lastModification: DateTime.now().toIso8601String(),
        UserFields.experience: 0,
      },
      where: '${UserFields.id} = ?',
      whereArgs: [0],
    );
  }
}
