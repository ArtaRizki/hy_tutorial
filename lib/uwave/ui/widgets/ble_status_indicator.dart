import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ble_provider.dart';
import '../../core/constants/app_constants.dart';

/// Indikator status koneksi BLE di AppBar
class BleStatusIndicator extends StatelessWidget {
  const BleStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BleProvider>(
      builder: (context, ble, _) {
        Color color;
        IconData icon;
        String tooltip;

        switch (ble.bleState) {
          case BleState.connected:
            color = AppConstants.colorOk;
            icon = Icons.bluetooth_connected;
            tooltip = 'Terhubung ke ${ble.connectedDevice?.platformName ?? 'U-WAVE'}';
          case BleState.scanning:
            color = const Color(0xFF818CF8);
            icon = Icons.bluetooth_searching;
            tooltip = 'Scanning...';
          case BleState.connecting:
            color = const Color(0xFFFBBF24);
            icon = Icons.bluetooth;
            tooltip = 'Menghubungkan...';
          case BleState.disconnected:
          case BleState.error:
            color = AppConstants.colorNg;
            icon = Icons.bluetooth_disabled;
            tooltip = 'Tidak terhubung';
          case BleState.idle:
            color = const Color(0xFF64748B);
            icon = Icons.bluetooth;
            tooltip = 'Bluetooth idle';
        }

        return Tooltip(
          message: tooltip,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ble.bleState == BleState.scanning
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: color))
                : Icon(icon, color: color, size: 20),
          ),
        );
      },
    );
  }
}
