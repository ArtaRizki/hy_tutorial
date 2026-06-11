import 'package:flutter/foundation.dart';
import '../core/utils/measurement_helper.dart';
import '../data/local/database_helper.dart';
import '../data/models/measurement_model.dart';
import '../data/models/session_model.dart';

/// Provider yang mengelola sesi aktif dan list pengukuran.
class SessionProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Session? _activeSession;
  List<Session> _sessions = [];
  List<Measurement> _measurements = [];
  SessionStats _stats = SessionStats(
    totalCount: 0,
    okCount: 0,
    ngCount: 0,
    average: null,
    minValue: null,
    maxValue: null,
    range: null,
  );

  // ── Getters ────────────────────────────────────────────────────
  Session? get activeSession => _activeSession;
  List<Session> get sessions => _sessions;
  List<Measurement> get measurements => _measurements;
  SessionStats get stats => _stats;
  bool get hasActiveSession => _activeSession != null;

  // ── Sessions ───────────────────────────────────────────────────

  Future<void> loadSessions() async {
    _sessions = await _db.getSessions();
    notifyListeners();
  }

  Future<void> createSession(Session session) async {
    final id = await _db.insertSession(session);
    _activeSession = session.copyWith(id: id);
    _measurements = [];
    _recalcStats();
    await loadSessions();
  }

  Future<void> setActiveSession(Session session) async {
    _activeSession = session;
    _measurements = await _db.getMeasurements(session.id!);
    _recalcStats();
    notifyListeners();
  }

  Future<void> finishSession() async {
    if (_activeSession == null) return;
    final finished = _activeSession!.copyWith(finishedAt: DateTime.now());
    await _db.updateSession(finished);
    _activeSession = null;
    _measurements = [];
    _recalcStats();
    await loadSessions();
  }

  Future<void> deleteSession(int id) async {
    await _db.deleteSession(id);
    if (_activeSession?.id == id) {
      _activeSession = null;
      _measurements = [];
      _recalcStats();
    }
    await loadSessions();
  }

  // ── Measurements ───────────────────────────────────────────────

  /// Tambahkan pengukuran dari BLE ke sesi aktif.
  Future<void> addMeasurement(double valueMm) async {
    if (_activeSession == null) return;

    final status = MeasurementHelper.calcStatus(
      value: valueMm,
      toleranceMin: _activeSession!.toleranceMin,
      toleranceMax: _activeSession!.toleranceMax,
    );

    final m = Measurement(
      sessionId: _activeSession!.id!,
      valueMm: valueMm,
      status: status,
      timestamp: DateTime.now(),
    );

    final id = await _db.insertMeasurement(m);
    _measurements.add(Measurement(
      id: id,
      sessionId: m.sessionId,
      valueMm: m.valueMm,
      status: m.status,
      timestamp: m.timestamp,
    ));
    _recalcStats();
    notifyListeners();
  }

  /// Hapus pengukuran terakhir (undo)
  Future<void> deleteLastMeasurement() async {
    if (_activeSession == null || _measurements.isEmpty) return;
    await _db.deleteLastMeasurement(_activeSession!.id!);
    _measurements.removeLast();
    _recalcStats();
    notifyListeners();
  }

  // ── Stats ──────────────────────────────────────────────────────

  void _recalcStats() {
    _stats = MeasurementHelper.calcStats(
      _measurements.map((m) => m.valueMm).toList(),
      _measurements.map((m) => m.status).toList(),
    );
  }
}
