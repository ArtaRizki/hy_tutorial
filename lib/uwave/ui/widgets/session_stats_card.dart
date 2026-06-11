import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/measurement_helper.dart';

/// Card statistik sesi: total, OK, NG, avg, min, max.
class SessionStatsCard extends StatelessWidget {
  final SessionStats stats;
  final String unit;

  const SessionStatsCard({
    super.key,
    required this.stats,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.totalCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'Total',
            value: '${stats.totalCount}',
            color: Colors.white,
          ),
          _divider(),
          _StatItem(
            label: 'OK',
            value: '${stats.okCount}',
            color: AppConstants.colorOk,
            sub: '${stats.okRate.toStringAsFixed(0)}%',
          ),
          _divider(),
          _StatItem(
            label: 'NG',
            value: '${stats.ngCount}',
            color: AppConstants.colorNg,
            sub: '${stats.ngRate.toStringAsFixed(0)}%',
          ),
          _divider(),
          _StatItem(
            label: 'Avg',
            value: stats.average?.toStringAsFixed(3) ?? '-',
            color: const Color(0xFF818CF8),
          ),
          _divider(),
          _StatItem(
            label: 'Range',
            value: stats.range?.toStringAsFixed(3) ?? '-',
            color: const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 36,
        width: 1,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.white.withValues(alpha: 0.06),
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? sub;

  const _StatItem(
      {required this.label,
      required this.value,
      required this.color,
      this.sub});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter')),
          if (sub != null)
            Text(sub!,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 11)),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF475569), fontSize: 11)),
        ],
      ),
    );
  }
}
