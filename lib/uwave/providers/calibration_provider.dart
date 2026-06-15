import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalibrationProvider extends ChangeNotifier {
  static const String _prefKey = 'uwave_calibration_table';
  
  // Default fallback points if none are set.
  List<Map<String, double>> _calibrationTable = [
    {'raw': 105.0, 'mm': 0.0},
    {'raw': 404.0, 'mm': 10.0},
    {'raw': 685.0, 'mm': 20.0},
    {'raw': 1103.0, 'mm': 30.0},
    {'raw': 1358.0, 'mm': 40.0},
  ];

  bool _isLoaded = false;

  List<Map<String, double>> get calibrationTable => List.unmodifiable(_calibrationTable);
  bool get isLoaded => _isLoaded;

  CalibrationProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_prefKey);
      
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _calibrationTable = decoded.map((item) {
          final map = item as Map<String, dynamic>;
          return {
            'raw': (map['raw'] as num).toDouble(),
            'mm': (map['mm'] as num).toDouble(),
          };
        }).toList();
        
        // Ensure sorted by raw value
        _calibrationTable.sort((a, b) => a['raw']!.compareTo(b['raw']!));
      }
      _isLoaded = true;
      notifyListeners();
      log('[CalibrationProvider] Loaded ${_calibrationTable.length} points from SharedPreferences.');
    } catch (e) {
      log('[CalibrationProvider] Error loading preferences: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = jsonEncode(_calibrationTable);
      await prefs.setString(_prefKey, jsonStr);
      log('[CalibrationProvider] Saved ${_calibrationTable.length} points to SharedPreferences.');
    } catch (e) {
      log('[CalibrationProvider] Error saving preferences: $e');
    }
  }

  void addCalibrationPoint(double raw, double mm) {
    // Cek apakah raw sudah ada, jika ya timpa, jika tidak tambah baru
    final existingIndex = _calibrationTable.indexWhere((p) => p['raw'] == raw);
    if (existingIndex >= 0) {
      _calibrationTable[existingIndex]['mm'] = mm;
    } else {
      _calibrationTable.add({'raw': raw, 'mm': mm});
    }
    
    // Pastikan selalu urut berdasarkan raw
    _calibrationTable.sort((a, b) => a['raw']!.compareTo(b['raw']!));
    
    notifyListeners();
    _saveToPrefs();
  }

  void removeCalibrationPoint(int index) {
    if (index >= 0 && index < _calibrationTable.length) {
      _calibrationTable.removeAt(index);
      notifyListeners();
      _saveToPrefs();
    }
  }

  void resetToDefault() {
    _calibrationTable = [
      {'raw': 105.0, 'mm': 0.0},
      {'raw': 404.0, 'mm': 10.0},
      {'raw': 685.0, 'mm': 20.0},
      {'raw': 1103.0, 'mm': 30.0},
      {'raw': 1358.0, 'mm': 40.0},
    ];
    notifyListeners();
    _saveToPrefs();
  }
}
