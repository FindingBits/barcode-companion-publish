import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:barcode_companion/Backend/scan.dart';

/// Global variable that links to the database
Database _database;

/// Linking the global variable database to the actual database
/// A global variable is the best solution to avoid waiting for openDatabase function everytime we need to access the database
/// Should be called on initialization and when the database is changed
setdatabase() async {
  _database = await openDatabase(
    join(await getDatabasesPath(), 'scans_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE scans(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, date TEXT, code TEXT, description TEXT, path TEXT, fdat TEXT, issuerCode TEXT, eqID TEXT, itemPriority TEXT, serialNumber TEXT, trackID TEXT)",
      );
    },
    version: 1,
  );
}

/// Function to insert a scan into the database
/// Example:
/// ```dart
/// insertScan(new Scan(name: "Example", ), ...)
/// ```
Future<void> insertScan(Scan scan) async {
  print(scan);
  await _database.insert(
    'scans',
    scan.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

/// Function to retrieve a list of Scan objects
/// Example:
/// ```
/// List<Scan> scans_ = await scans();
/// ```
Future<List<Scan>> scans() async {
  //final database = getdatabase();
  //final Database db = await database;
  final List<Map<String, dynamic>> maps = await _database.query('scans');
  List<Scan> _list = List.generate(maps.length, (i) {
    return Scan(
      id: maps[i]['id'],
      name: maps[i]['name'],
      date: maps[i]['date'],
      code: maps[i]['code'],
      description: maps[i]['description'],
      path: maps[i]['path'],
      fdatcode: maps[i]['fdat'],
      issuerCode: maps[i]['issuerCode'],
      eqID: maps[i]['eqID'],
      itemPriority: maps[i]['itemPriority'],
      serialNumber: maps[i]['serialNumber'],
      trackID: maps[i]['trackID'],
    );
  });
  return _list.reversed.toList();
}

Future<void> updateScan(Scan scan) async {
  await _database.update(
    'scans',
    scan.toMap(),
    where: "id = ?",
    whereArgs: [scan.id],
  );
}

/// Function to delete a scan, providing the scan id
/// Example:
/// ```dart
/// deleteScan(currentScan.getID);
/// ```
Future<void> deleteScan(int id) async {
  await _database.delete(
    'scans',
    where: "id = ?",
    whereArgs: [id],
  );
}
