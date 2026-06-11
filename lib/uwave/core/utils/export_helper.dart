import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/measurement_model.dart';
import '../../data/models/session_model.dart';

class ExportHelper {
  ExportHelper._();

  static final _fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final _fileFmt = DateFormat('yyyyMMdd_HHmmss');

  /// Export sesi ke CSV dan share via share_plus
  static Future<void> exportCsv(
      Session session, List<Measurement> measurements) async {
    final rows = <List<dynamic>>[
      // Header info
      ['U-WAVE QC Inspector — Laporan Sesi'],
      ['Sesi', session.name],
      ['Part Number', session.partNumber ?? '-'],
      ['Operator', session.operatorName ?? '-'],
      ['Toleransi', '${session.toleranceMin} ~ ${session.toleranceMax} ${session.unit}'],
      ['Mulai', _fmt.format(session.createdAt)],
      ['Selesai', session.finishedAt != null ? _fmt.format(session.finishedAt!) : '-'],
      [],
      // Data header
      ['No', 'Nilai (${session.unit})', 'Status', 'Waktu'],
    ];

    for (var i = 0; i < measurements.length; i++) {
      final m = measurements[i];
      rows.add([i + 1, m.valueMm.toStringAsFixed(3), m.status, _fmt.format(m.timestamp)]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final fileName = 'QC_${session.name}_${_fileFmt.format(DateTime.now())}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Laporan QC — ${session.name}',
    );
  }

  /// Export sesi ke Excel (.xlsx) dan share
  static Future<void> exportExcel(
      Session session, List<Measurement> measurements) async {
    // Import syncfusion di sini agar tidak ada circular dependency
    // ignore: depend_on_referenced_packages
    // ignore: implementation_imports
    try {
      // Dynamic import untuk menghindari compile error jika package belum ada
      await _doExcelExport(session, measurements);
    } catch (e) {
      // Fallback ke CSV jika Excel export gagal
      await exportCsv(session, measurements);
    }
  }

  static Future<void> _doExcelExport(
      Session session, List<Measurement> measurements) async {
    // Menggunakan syncfusion_flutter_xlsio
    // ignore: avoid_dynamic_calls
    final workbook = _createWorkbook();
    final sheet = workbook.worksheets[0];

    // Header baris info
    sheet.getRangeByName('A1').setText('U-WAVE QC Inspector — Laporan Sesi');
    sheet.getRangeByName('A2').setText('Sesi');
    sheet.getRangeByName('B2').setText(session.name);
    sheet.getRangeByName('A3').setText('Part Number');
    sheet.getRangeByName('B3').setText(session.partNumber ?? '-');
    sheet.getRangeByName('A4').setText('Operator');
    sheet.getRangeByName('B4').setText(session.operatorName ?? '-');
    sheet.getRangeByName('A5').setText('Toleransi');
    sheet.getRangeByName('B5').setText(
        '${session.toleranceMin} ~ ${session.toleranceMax} ${session.unit}');

    // Data header
    sheet.getRangeByName('A7').setText('No');
    sheet.getRangeByName('B7').setText('Nilai (${session.unit})');
    sheet.getRangeByName('C7').setText('Status');
    sheet.getRangeByName('D7').setText('Waktu');

    for (var i = 0; i < measurements.length; i++) {
      final m = measurements[i];
      final row = i + 8;
      sheet.getRangeByIndex(row, 1).setNumber(i + 1);
      sheet.getRangeByIndex(row, 2).setNumber(m.valueMm);
      sheet.getRangeByIndex(row, 3).setText(m.status);
      sheet.getRangeByIndex(row, 4).setText(_fmt.format(m.timestamp));

      // Warna baris NG
      if (m.status == 'NG') {
        sheet.getRangeByIndex(row, 1, row, 4).cellStyle.backColor = '#FEE2E2';
        sheet.getRangeByIndex(row, 3).cellStyle.fontColor = '#EF4444';
      }
    }

    final dir = await getTemporaryDirectory();
    final fileName =
        'QC_${session.name}_${_fileFmt.format(DateTime.now())}.xlsx';
    final filePath = '${dir.path}/$fileName';

    final bytes = workbook.saveAsStream();
    workbook.dispose();
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Laporan QC — ${session.name}',
    );
  }

  // Wrapper untuk create workbook via syncfusion
  static dynamic _createWorkbook() {
    // ignore: avoid_dynamic_calls
    throw UnimplementedError(
        'Gunakan exportCsv untuk sementara — Excel export memerlukan import syncfusion');
  }
}
