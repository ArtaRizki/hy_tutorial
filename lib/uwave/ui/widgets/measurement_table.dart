import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/measurement_model.dart';
import 'status_badge.dart';

/// Tabel daftar pengukuran dalam sesi aktif.
class MeasurementTableWidget extends StatelessWidget {
  final List<Measurement> measurements;
  static final _timeFmt = DateFormat('HH:mm:ss');

  const MeasurementTableWidget({super.key, required this.measurements});

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_rows_rounded, size: 48, color: Colors.white12),
            SizedBox(height: 12),
            Text('Belum ada data pengukuran',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          color: const Color(0xFF1E293B),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(
            children: [
              SizedBox(
                  width: 40,
                  child: Text('No',
                      style: _headerStyle, textAlign: TextAlign.center)),
              Expanded(
                  flex: 3,
                  child: Text('Nilai (mm)', style: _headerStyle)),
              Expanded(
                  flex: 2,
                  child: Text('Status',
                      style: _headerStyle, textAlign: TextAlign.center)),
              Expanded(
                  flex: 3,
                  child: Text('Waktu',
                      style: _headerStyle, textAlign: TextAlign.right)),
            ],
          ),
        ),
        // Data rows
        Expanded(
          child: ListView.builder(
            reverse: true, // Terbaru di atas
            itemCount: measurements.length,
            itemBuilder: (context, i) {
              // Index dari belakang karena reverse: true
              final actualIndex = measurements.length - 1 - i;
              final m = measurements[actualIndex];
              final isNg = m.status == 'NG';
              return Container(
                color: isNg
                    ? const Color(0xFFEF4444).withOpacity(0.05)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: Colors.white.withOpacity(0.03), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${actualIndex + 1}',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        m.valueMm.toStringAsFixed(3),
                        style: TextStyle(
                          color: isNg
                              ? const Color(0xFFFCA5A5)
                              : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(child: StatusBadge(status: m.status)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _timeFmt.format(m.timestamp),
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontFamily: 'Inter'),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static const _headerStyle = TextStyle(
    color: Color(0xFF64748B),
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
