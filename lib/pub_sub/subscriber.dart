import 'package:flutter/material.dart';

// Notifies the app that the database has changed
class DatabaseNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

final detectionNotifier = DatabaseNotifier();
