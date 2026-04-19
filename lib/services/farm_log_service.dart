import 'package:flutter/foundation.dart';
import '../models/farm_log.dart';

class FarmLogService extends ChangeNotifier {
  static final FarmLogService instance = FarmLogService._();
  FarmLogService._();

  final List<FarmLog> _records = [];

  List<FarmLog> get records => List.unmodifiable(_records);

  void addLog(FarmLog log) {
    _records.insert(0, log);
    notifyListeners();
  }
}
