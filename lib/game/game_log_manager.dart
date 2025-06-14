import 'package:flutter/foundation.dart';

class GameLogManager extends ChangeNotifier {
  final List<String> _logEntries = [];

  List<String> get logEntries => List.unmodifiable(_logEntries);

  void add(String entry) {
    _logEntries.add(entry);
    notifyListeners();
  }

  void clear() {
    _logEntries.clear();
    notifyListeners();
  }
}
