import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bills.db');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE bills (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customerName TEXT,
              contactNumber TEXT,
              totalAmount REAL,
              isPaid INTEGER,
              date TEXT,
              items TEXT
            )
          ''');
        await db.execute('''
            CREATE TABLE items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              billId INTEGER,
              itemName TEXT,
              quantity INTEGER,
              unitPrice REAL,
              FOREIGN KEY (billId) REFERENCES bills (id)
            )
          ''');
      },
      version: 1,
    );
  }

  Future<int> insertBill(Map<String, dynamic> bill) async {
    final db = await database;
    bill['items'] = jsonEncode(bill['items'] ?? []);
    return await db.insert('bills', bill);
  }

  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    return db.insert('items', item);
  }

  Future<List<Map<String, dynamic>>> getBills() async {
    final db = await database;
    return await db.query('bills');
  }

  Future<List<Map<String, dynamic>>> fetchBills() async {
    final db = await database;
    return db.query('bills');
  }

  Future<List<Map<String, dynamic>>> fetchItems(int billId) async {
    final db = await database;
    return db.query('items', where: 'billId = ?', whereArgs: [billId]);
  }

  Future<void> updateBillStatus(int billId, int status) async {
    final db = await database;
    await db.update(
      'bills',
      {'isPaid': status},
      where: 'id = ?',
      whereArgs: [billId],
    );
  }

  Future<List<Map<String, dynamic>>> getItemsByBillId(int billId) async {
    final db = await database;
    return await db.query(
      'items',
      where: 'billId = ?',
      whereArgs: [billId],
    );
  }

  // Future<Map<String, dynamic>> fetchBillWithItems(int billId) async {
  //   final db = await database;

  //   // Fetch the bill details
  //   final billResults = await db.query(
  //     'bills',
  //     where: 'id = ?',
  //     whereArgs: [billId],
  //   );

  //   if (billResults.isEmpty) {
  //     throw Exception("Bill with id $billId not found");
  //   }

  //   final bill = billResults.first;

  //   // Fetch the associated items
  //   final itemResults = await db.query(
  //     'items',
  //     where: 'billId = ?',
  //     whereArgs: [billId],
  //   );

  //   // Combine bill and items into a single map
  //   return {
  //     ...bill,
  //     'items': itemResults,
  //   };
  // }
}
