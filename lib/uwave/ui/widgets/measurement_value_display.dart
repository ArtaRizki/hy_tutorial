import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/session_model.dart';

/// Widget utama yang menampilkan nilai pengukuran real-time — angka besar di tengah.
class MeasurementValueDisplay extends StatelessWidget {
  final double? value;
  final String unit;
  final Session? session;

  const MeasurementValueDisplay({
    super.key,
    required this.value,
    required this.unit,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final status = _calcStatus();
    final color = status == 'OK'
        ? AppConstants.colorOk
        : status == 'NG'
            ? AppConstants.colorNg
            : const Color(0xFF94A3B8);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: status != null ? color.withValues(alpha: 0.4) : Colors.white12,
          width: 2,
        ),
        boxShadow: status != null
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          // Label
          Text(
            session != null ? session!.name : 'Belum ada sesi aktif',
            style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Nilai besar
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value != null ? value!.toStringAsFixed(3) : '---',
              key: ValueKey(value?.toStringAsFixed(3)),
              style: TextStyle(
                color: value != null ? color : const Color(0xFF334155),
                fontSize: 72,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (session != null && value != null) ...[
            const SizedBox(height: 16),
            // Toleransi bar
            _ToleranceBar(
              value: value!,
              min: session!.toleranceMin,
              max: session!.toleranceMax,
              statusColor: color,
            ),
            const SizedBox(height: 12),
            // Status badge besar
            _StatusPill(status: status!, color: color),
          ] else if (value == null) ...[
            const SizedBox(height: 16),
            const Text(
              'Hubungkan U-WAVE-T dan buat sesi baru',
              style: TextStyle(color: Color(0xFF475569), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String? _calcStatus() {
    if (value == null || session == null) return null;
    return (value! >= session!.toleranceMin && value! <= session!.toleranceMax)
        ? 'OK'
        : 'NG';
  }
}

// ── Toleransi Bar ──────────────────────────────────────────────────

class _ToleranceBar extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final Color statusColor;

  const _ToleranceBar({
    required this.value,
    required this.min,
    required this.max,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    // Extended range untuk visualisasi
    final range = max - min;
    final extMin = min - range * 0.5;
    final extMax = max + range * 0.5;
    final totalRange = extMax - extMin;

    double pos = ((value - extMin) / totalRange).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(min.toStringAsFixed(3),
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 11)),
            Text(max.toStringAsFixed(3),
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final minPos = ((min - extMin) / totalRange * w).clamp(0.0, w);
            final maxPos = ((max - extMin) / totalRange * w).clamp(0.0, w);
            final indicatorPos = (pos * w - 6).clamp(0.0, w - 12);
            return Stack(
              children: [
                // Background bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Toleransi zone (hijau)
                Positioned(
                  left: minPos,
                  width: (maxPos - minPos).clamp(0.0, w),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppConstants.colorOk.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Value indicator
                Positioned(
                  left: indicatorPos,
                  child: Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: -2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: statusColor.withValues(alpha: 0.5),
                            blurRadius: 6)
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ── Status Pill ────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusPill({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
        ),
      ),
    );
  }
}
