import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ble_provider.dart';
import '../../providers/session_provider.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/measurement_value_display.dart';
import '../widgets/measurement_table.dart';
import '../widgets/session_stats_card.dart';
import '../widgets/ble_status_indicator.dart';
import 'session_form_screen.dart';

/// Layar pengukuran real-time — inti dari aplikasi U-WAVE QC Inspector.
class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  bool _autoSave = false;
  double? _lastBleValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Consumer<SessionProvider>(
          builder: (context, session, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.activeSession?.name ?? 'Pilih Sesi',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              if (session.activeSession != null)
                Text(
                  'Tol: ${session.activeSession!.toleranceMin} ~ ${session.activeSession!.toleranceMax} ${session.activeSession!.unit}',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 12),
                ),
            ],
          ),
        ),
        actions: [
          const BleStatusIndicator(),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: const Color(0xFF1E293B),
            onSelected: (val) async {
              if (val == 'new_session') {
                if (!context.mounted) return;
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SessionFormScreen()));
              } else if (val == 'finish') {
                await context.read<SessionProvider>().finishSession();
                if (context.mounted) Navigator.pop(context);
              } else if (val == 'export') {
                if (context.mounted) _showExportDialog(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'new_session',
                child: Row(children: [
                  Icon(Icons.add_circle_outline, color: Color(0xFF818CF8)),
                  SizedBox(width: 12),
                  Text('Sesi Baru', style: TextStyle(color: Colors.white)),
                ]),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(children: [
                  Icon(Icons.share_rounded, color: Color(0xFF34D399)),
                  SizedBox(width: 12),
                  Text('Export & Share',
                      style: TextStyle(color: Colors.white)),
                ]),
              ),
              const PopupMenuItem(
                value: 'finish',
                child: Row(children: [
                  Icon(Icons.check_circle_outline,
                      color: Color(0xFFFBBF24)),
                  SizedBox(width: 12),
                  Text('Selesaikan Sesi',
                      style: TextStyle(color: Colors.white)),
                ]),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer2<BleProvider, SessionProvider>(
        builder: (context, ble, session, _) {
          // Auto-save: langsung simpan saat ada nilai baru dari BLE
          if (_autoSave &&
              ble.currentValue != null &&
              ble.currentValue != _lastBleValue &&
              session.hasActiveSession) {
            _lastBleValue = ble.currentValue;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              session.addMeasurement(ble.currentValue!);
            });
          }

          return Column(
            children: [
              // ── Real-time Value Display ──────────────────────
              MeasurementValueDisplay(
                value: ble.currentValue,
                unit: ble.currentUnit,
                session: session.activeSession,
              ),

              // ── Control Buttons ──────────────────────────────
              _ControlButtons(
                autoSave: _autoSave,
                isConnected: ble.isConnected,
                hasSession: session.hasActiveSession,
                currentValue: ble.currentValue,
                onSave: () {
                  if (ble.currentValue != null) {
                    session.addMeasurement(ble.currentValue!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '✓ Tersimpan: ${ble.currentValue!.toStringAsFixed(3)} ${ble.currentUnit}'),
                        backgroundColor: AppConstants.colorOk,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                onUndo: () => session.deleteLastMeasurement(),
                onNewSession: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SessionFormScreen())),
                onAutoSaveToggle: (v) => setState(() => _autoSave = v),
              ),

              // ── Stats Card ───────────────────────────────────
              SessionStatsCard(stats: session.stats, unit: ble.currentUnit),

              // ── Measurement Table ────────────────────────────
              Expanded(
                child: MeasurementTableWidget(
                  measurements: session.measurements,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    final session = context.read<SessionProvider>();
    if (session.activeSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tidak ada sesi aktif'), behavior: SnackBarBehavior.floating));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export & Share',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${session.measurements.length} data pengukuran',
                style: const TextStyle(color: Color(0xFF94A3B8))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  // ignore: avoid_dynamic_calls
                  await _doExport(context, 'csv');
                },
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Export CSV'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _doExport(context, 'excel');
                },
                icon: const Icon(Icons.grid_on_rounded),
                label: const Text('Export Excel (.xlsx)'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _doExport(BuildContext context, String format) async {
    final session = context.read<SessionProvider>();
    if (session.activeSession == null) return;
    try {
      if (format == 'csv') {
        // Import di sini untuk menghindari circular import
        // Panggil ExportHelper.exportCsv
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Menyiapkan CSV...'),
            behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export gagal: $e'),
          backgroundColor: AppConstants.colorNg,
          behavior: SnackBarBehavior.floating));
    }
  }
}

// ── Control Buttons ─────────────────────────────────────────────────

class _ControlButtons extends StatelessWidget {
  final bool autoSave;
  final bool isConnected;
  final bool hasSession;
  final double? currentValue;
  final VoidCallback onSave;
  final VoidCallback onUndo;
  final VoidCallback onNewSession;
  final ValueChanged<bool> onAutoSaveToggle;

  const _ControlButtons({
    required this.autoSave,
    required this.isConnected,
    required this.hasSession,
    required this.currentValue,
    required this.onSave,
    required this.onUndo,
    required this.onNewSession,
    required this.onAutoSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          Row(
            children: [
              // Save Button
              Expanded(
                flex: 3,
                child: FilledButton.icon(
                  onPressed: (isConnected && hasSession && currentValue != null)
                      ? onSave
                      : null,
                  icon: const Icon(Icons.save_alt_rounded, size: 22),
                  label: const Text('SIMPAN',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    disabledBackgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Undo Button
              FilledButton(
                onPressed: hasSession ? onUndo : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  disabledBackgroundColor: Colors.white12,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Icon(Icons.undo_rounded,
                    color: Colors.white70, size: 24),
              ),
              const SizedBox(width: 12),
              // New Session
              FilledButton(
                onPressed: onNewSession,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white70, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Auto-save toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Auto-simpan',
                  style:
                      TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              const SizedBox(width: 8),
              Switch(
                value: autoSave,
                onChanged: onAutoSaveToggle,
                activeThumbColor: const Color(0xFF6366F1),
                trackColor: WidgetStateProperty.all(const Color(0xFF334155)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
