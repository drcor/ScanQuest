import 'dart:async';
import 'package:path/path.dart';
import 'package:scan_quest_app/models/treasure_items_model.dart';
import 'package:sqflite/sqflite.dart';

class TreasureItemsDatabase {
  static final TreasureItemsDatabase instance = TreasureItemsDatabase._init();
  static Database? _database;

  TreasureItemsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ScanQuestTreasureItems.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTreasureItems (
        ${TreasureItemFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TreasureItemFields.nfcId} TEXT NOT NULL UNIQUE, -- Unique nfc identifier for each item
        ${TreasureItemFields.name} TEXT NOT NULL,         -- Name of the item
        ${TreasureItemFields.description} TEXT,           -- Description of the item
        ${TreasureItemFields.image} TEXT NOT NULL,        -- Image path for the item
        ${TreasureItemFields.experience} INTEGER NOT NULL,-- Experience points gained when collecting the item
        ${TreasureItemFields.collectedOn} DATETIME NULL,  -- Date of collection of the item
        ${TreasureItemFields.isFound} INTEGER DEFAULT 0   -- Whether the item has been found (0 = No, 1 = Yes)
      )
    ''');

    await db.execute('''
      INSERT INTO $tableTreasureItems (
        ${TreasureItemFields.nfcId},
        ${TreasureItemFields.name},
        ${TreasureItemFields.description},
        ${TreasureItemFields.image},
        ${TreasureItemFields.experience},
        ${TreasureItemFields.collectedOn},
        ${TreasureItemFields.isFound}
      ) VALUES 
      ('0','Arrow','This is sharp, be careful.','arrow',3,'2025-01-01 00:00:00', 0),
      ('1','Basic Sword','Just a basic sword...','basic_sword',2,'2025-01-01 00:00:00', 0),
      ('2','Berry','To eat if you are hungry.','berry',4,'2025-01-01 00:00:00', 0),
      ('3','Cat','Meoww...','cat',7,'2025-01-01 00:00:00', 0),
      ('4','Chameleon','I dare you to find me...','chameleon',12,'2025-01-01 00:00:00', 0),
      ('5','Chicken Leg','Hmmm, delicious...','chicken_leg',3,'2025-01-01 00:00:00', 0),
      ('6','Falcon','Scanning the skies.','falcon',5,'2025-01-01 00:00:00', 0),
      ('7','Fire Arrow','This is sharp and hot, be careful','fire_arrow',6,'2025-01-01 00:00:00', 0),
      ('8','Fox','What does the fox say?','fox',10,'2025-01-01 00:00:00', 0),
      ('9','Goblin','Where is the gold?','goblin',15,'2025-01-01 00:00:00', 0),
      ('10','Skeleton','I can feel all my bones!','skeleton',8,'2025-01-01 00:00:00', 0)
    ''');
  }

  Future<TreasureItem> create(TreasureItem treasureItem) async {
    final db = await instance.database;
    // final id = await db.insert(tableTreasureItems, treasureItem.toJson());

    return await db.transaction((txn) async {
      final id = await txn.insert(tableTreasureItems, treasureItem.toJson());
      return treasureItem.copy(id: id);
    });
  }

  Future<TreasureItem?> read(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableTreasureItems,
      columns: TreasureItemFields.allValues,
      where: '${TreasureItemFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TreasureItem.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<TreasureItem?> readByNfcId(String nfcId) async {
    final db = await instance.database;

    final maps = await db.query(
      tableTreasureItems,
      columns: TreasureItemFields.allValues,
      where: '${TreasureItemFields.nfcId} = ?',
      whereArgs: [nfcId],
    );

    if (maps.isNotEmpty) {
      return TreasureItem.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<TreasureItem?> readFirst() async {
    final db = await instance.database;

    final maps = await db.query(
      tableTreasureItems,
      columns: TreasureItemFields.allValues,
    );

    if (maps.isNotEmpty) {
      return TreasureItem.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<TreasureItem>?> readAllCollected() async {
    final db = await instance.database;

    final maps = await db.query(
      tableTreasureItems,
      columns: TreasureItemFields.allValues,
      where: '${TreasureItemFields.isFound} = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return List<TreasureItem>.from(
        (maps as List<dynamic>).map(
          (model) => TreasureItem.fromJson(model as Map<String, dynamic>),
        ),
      );
    } else {
      return null;
    }
  }

  Future<TreasureItem?> update(TreasureItem item) async {
    final db = await instance.database;

    final id = await db.update(
      tableTreasureItems,
      item.toJson(),
      where: '${TreasureItemFields.nfcId} = ?',
      whereArgs: [item.nfcId],
    );

    return read(id);
  }

  Future<int> deleteAll() async {
    final db = await instance.database;

    return db.delete(
      tableTreasureItems,
    );
  }

  Future<int> resetCollected() async {
    final db = await instance.database;

    return db.update(
      tableTreasureItems,
      {TreasureItemFields.isFound: 0},
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
