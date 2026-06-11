import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ble_provider.dart';
import '../../core/constants/app_constants.dart';
import 'measurement_screen.dart';
import '../widgets/ble_status_indicator.dart';

/// Layar utama: scan BLE dan pilih device U-WAVE-T.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start scan saat pertama masuk
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BleProvider>().startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            Image.asset('assets/images/icon-apps.png', height: 28,
                errorBuilder: (_, __, ___) => const SizedBox()),
            const SizedBox(width: 10),
            const Text(
              'U-WAVE QC Inspector',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: const [
          BleStatusIndicator(),
          SizedBox(width: 12),
        ],
      ),
      body: Consumer<BleProvider>(
        builder: (context, ble, _) {
          return Column(
            children: [
              // ── Status Banner ──────────────────────────────────
              _StatusBanner(ble: ble),

              // ── Scan Results ───────────────────────────────────
              Expanded(
                child: ble.isConnected
                    ? _ConnectedView(ble: ble)
                    : _ScanView(ble: ble),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Connected View ─────────────────────────────────────────────────

class _ConnectedView extends StatelessWidget {
  final BleProvider ble;
  const _ConnectedView({required this.ble});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppConstants.colorOk.withValues(alpha: 0.15),
              border: Border.all(color: AppConstants.colorOk, width: 3),
            ),
            child: const Icon(Icons.bluetooth_connected,
                size: 60, color: AppConstants.colorOk),
          ),
          const SizedBox(height: 24),
          Text(
            ble.connectedDevice?.platformName ?? 'U-WAVE-T',
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Terhubung ✓',
              style: TextStyle(
                  color: AppConstants.colorOk,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 40),
          FilledButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MeasurementScreen())),
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text('Mulai Pengukuran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(
              backgroundColor: AppConstants.colorOk,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => ble.disconnect(),
            icon:
                const Icon(Icons.bluetooth_disabled, color: Color(0xFF94A3B8)),
            label: const Text('Putuskan Koneksi',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }
}

// ── Scan View ──────────────────────────────────────────────────────

class _ScanView extends StatelessWidget {
  final BleProvider ble;
  const _ScanView({required this.ble});

  @override
  Widget build(BuildContext context) {
    if (ble.isScanning && ble.scanResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text('Scanning Bluetooth...',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            SizedBox(height: 8),
            Text('Pastikan U-WAVE-T menyala dan dalam jangkauan',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Scan Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: ble.isScanning ? null : () => ble.startScan(),
              icon: ble.isScanning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.search_rounded),
              label: Text(ble.isScanning ? 'Scanning...' : 'Scan Ulang'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),

        // Device List
        if (ble.scanResults.isEmpty && !ble.isScanning)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_searching,
                      size: 80, color: Colors.white.withValues(alpha: 0.15)),
                  const SizedBox(height: 16),
                  const Text('Tidak ada device ditemukan',
                      style: TextStyle(color: Colors.white54, fontSize: 15)),
                  const SizedBox(height: 8),
                  const Text('Tap "Scan Ulang" untuk mencari lagi',
                      style:
                          TextStyle(color: Color(0xFF475569), fontSize: 13)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ble.scanResults.length,
              itemBuilder: (context, i) {
                final result = ble.scanResults[i];
                final name = result.device.platformName.isNotEmpty
                    ? result.device.platformName
                    : 'Unknown';
                final rssi = result.rssi;

                return _DeviceTile(
                  name: name,
                  rssi: rssi,
                  onTap: () => ble.connectTo(result.device),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ── Device Tile ────────────────────────────────────────────────────

class _DeviceTile extends StatelessWidget {
  final String name;
  final int rssi;
  final VoidCallback onTap;

  const _DeviceTile(
      {required this.name, required this.rssi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUwave = name.toUpperCase().contains('UWAVE') ||
        name.toUpperCase().contains('U-WAVE');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUwave
              ? const Color(0xFF6366F1).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isUwave
                ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.bluetooth,
              color: isUwave
                  ? const Color(0xFF818CF8)
                  : const Color(0xFF64748B)),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: isUwave ? Colors.white : Colors.white60,
            fontWeight:
                isUwave ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          'RSSI: $rssi dBm',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        trailing: isUwave
            ? FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Connect'),
              )
            : TextButton(
                onPressed: onTap,
                child: const Text('Connect',
                    style: TextStyle(color: Color(0xFF64748B))),
              ),
      ),
    );
  }
}

// ── Status Banner ──────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final BleProvider ble;
  const _StatusBanner({required this.ble});

  @override
  Widget build(BuildContext context) {
    if (ble.bleState == BleState.connecting) {
      return Container(
        color: const Color(0xFF1E293B),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: const Row(
          children: [
            SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF818CF8))),
            SizedBox(width: 12),
            Text('Menghubungkan...',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }
    if (ble.bleState == BleState.error && ble.errorMessage != null) {
      return Container(
        color: AppConstants.colorNg.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.error_outline,
                color: AppConstants.colorNg, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error: ${ble.errorMessage}',
                style: const TextStyle(
                    color: AppConstants.colorNg, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
