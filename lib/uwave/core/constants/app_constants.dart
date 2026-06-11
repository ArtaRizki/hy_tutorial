import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // ── Warna Status ─────────────────────────────────────────────
  static const Color colorOk = Color(0xFF22C55E);   // green-500
  static const Color colorNg = Color(0xFFEF4444);   // red-500
  static const Color colorOkLight = Color(0xFFDCFCE7);
  static const Color colorNgLight = Color(0xFFFEE2E2);

  // ── Satuan ───────────────────────────────────────────────────
  static const String unitMm = 'mm';
  static const String unitInch = 'inch';

  // ── Database ─────────────────────────────────────────────────
  static const String dbName = 'uwave_qc.db';
  static const int dbVersion = 1;

  // ── SharedPreferences Keys ───────────────────────────────────
  static const String prefUnit = 'pref_unit';
  static const String prefOperatorName = 'pref_operator_name';
  static const String prefCompanyName = 'pref_company_name';
  static const String prefToleranceMin = 'pref_tol_min';
  static const String prefToleranceMax = 'pref_tol_max';
}
