import 'dart:io';

import 'package:barcode_companion/Backend/database.dart';
import 'package:flutter/material.dart';

import 'package:barcode_companion/Backend/scan.dart';

/// History Manager is the class that manages the registries, using provider to deal with state management
/// Call only once in ChangeNotifierProvider, after the database loads into the list of scans
/// Example:
/// ```dart
/// ChangeNotifierProvider(create: (_) => HistoryManager(history: _scan))
/// ```
class HistoryManager with ChangeNotifier {
  HistoryManager({Key key, List<Scan> history}) {
    this.history = history;
    _length = history.length;
  }

  /// Contains all of the scans saved
  List<Scan> history;

  int _currIndex;
  get currIndex => _currIndex;

  int _length;
  get length => _length;

  /// Function to get a specific scan according to the index provided
  Scan getItem(int index) {
    assert(index < history.length);
    _currIndex = index;
    return history[index];
  }

  /// Function to save a scan
  void addItem(Scan data) async {
    insertScan(data);
    history = await scans();
    _length = history.length;

    /// This specific function will alert the ui that it needs to be rebuilt, if they have Consumer<HistoryManager> on top of them
    notifyListeners();
  }

  /// Function to remove a scan
  void removeItem(Scan data) async {
    deleteScan(data.getID);
    history = await scans();
    _length = history.length;

    Directory dir = Directory(data.getPath);

    try {
      dir.deleteSync(recursive: true);
    } catch (ex) {
    }

    notifyListeners();
  }
}
