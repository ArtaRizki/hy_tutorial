import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Badge kecil OK / NG
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isOk = status == 'OK';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOk
            ? AppConstants.colorOk.withOpacity(0.15)
            : AppConstants.colorNg.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isOk ? AppConstants.colorOk : AppConstants.colorNg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
