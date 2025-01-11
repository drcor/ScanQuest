import 'dart:async';
import 'package:path/path.dart';
import 'package:scan_quest_app/models/items_connection_model.dart';
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
        ${TreasureItemFields.collectedOn} DATETIME NULL,  -- Date of collection of the item
        ${TreasureItemFields.isFound} INTEGER DEFAULT 0   -- Whether the item has been found (0 = No, 1 = Yes)
      )
    ''');

    List<TreasureItem> data = [
      TreasureItem(
        nfcId: '0',
        name: 'Arrow',
        description: 'This is sharp, be careful.',
        image: 'arrow',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
      TreasureItem(
        nfcId: '1',
        name: 'Basic Sword',
        description: 'Just a basic sword...',
        image: 'basic_sword',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
      TreasureItem(
        nfcId: '2',
        name: 'Berry',
        description: 'To eat if you are hungry.',
        image: 'berry',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
      TreasureItem(
        nfcId: '3',
        name: 'Cat',
        description: 'Meoww...',
        image: 'cat',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
      TreasureItem(
        nfcId: '4',
        name: 'Chameleon',
        description: 'I dare you to find me...',
        image: 'chameleon',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
      TreasureItem(
        nfcId: '5',
        name: 'Chicken Leg',
        description: 'Hmmm, delicious...',
        image: 'chicken_leg',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
      TreasureItem(
        nfcId: '6',
        name: 'Falcon',
        description: 'Scanning the skies.',
        image: 'falcon',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
      TreasureItem(
        nfcId: '7',
        name: 'Fire Arrow',
        description: 'This is sharp and hot, be careful',
        image: 'fire_arrow',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
      TreasureItem(
        nfcId: '8',
        name: 'Fox',
        description: 'Do you have some berries with you?',
        image: 'fox',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
      TreasureItem(
        nfcId: '9',
        name: 'Goblin',
        description: 'Where is the gold?',
        image: 'goblin',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
      TreasureItem(
        nfcId: '10',
        name: 'Skeleton',
        description: 'I can feel all my bones!',
        image: 'skeleton',
        collectedOn: DateTime.now(),
        isFound: false,
      ),
    ];

    // Create all the treasure items
    for (var e in data) {
      create(e);
    }
  }

  Future<TreasureItem> create(TreasureItem treasureItem) async {
    final db = await instance.database;
    final id = await db.insert(tableTreasureItems, treasureItem.toJson());

    return treasureItem.copy(id: id);
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

  Future<List<TreasureItem>?> readAll() async {
    final db = await instance.database;

    final maps = await db.query(
      tableTreasureItems,
      columns: TreasureItemFields.allValues,
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
      where: '${TreasureItemFields.id} = ?',
      whereArgs: [item.id],
    );

    return read(id);
  }

  Future<int> deleteAll() async {
    final db = await instance.database;

    return db.delete(
      tableTreasureItems,
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
