import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ble_provider.dart';
import '../../providers/calibration_provider.dart';
import '../../core/constants/app_constants.dart';

class CalibrationScreen extends StatelessWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Calibration Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to Default',
            onPressed: () {
              context.read<CalibrationProvider>().resetToDefault();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calibration reset to defaults.')),
              );
            },
          )
        ],
      ),
      body: Consumer2<CalibrationProvider, BleProvider>(
        builder: (context, calibration, ble, child) {
          if (!calibration.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final table = calibration.calibrationTable;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF1E293B),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Sensor Reading',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Raw ADC: ${ble.currentRawValue?.toStringAsFixed(0) ?? '---'}',
                          style: const TextStyle(
                              color: AppConstants.colorOk,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Measurement: ${ble.currentValue?.toStringAsFixed(3) ?? '---'} mm',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Calibration Points',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${table.length} points',
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: table.length,
                  itemBuilder: (context, index) {
                    final point = table[index];
                    return Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
                          child: Text('${index + 1}',
                              style: const TextStyle(color: Color(0xFF818CF8))),
                        ),
                        title: Text(
                          '${point['mm']} mm',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Raw: ${point['raw']}',
                          style: const TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppConstants.colorNg),
                          onPressed: () {
                            calibration.removeCalibrationPoint(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => _showAddPointDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Point', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddPointDialog(BuildContext context) {
    final ble = context.read<BleProvider>();
    final currentRaw = ble.currentRawValue;

    if (currentRaw == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sensor data available. Please connect first.')),
      );
      return;
    }

    final mmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Add Calibration Point', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Raw Value: ${currentRaw.toStringAsFixed(0)}',
                  style: const TextStyle(color: Color(0xFF94A3B8))),
              const SizedBox(height: 16),
              TextField(
                controller: mmController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Measurement (mm)',
                  labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF475569)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6366F1)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            FilledButton(
              onPressed: () {
                final mmText = mmController.text.replaceAll(',', '.');
                final mmValue = double.tryParse(mmText);
                if (mmValue != null) {
                  context.read<CalibrationProvider>().addCalibrationPoint(currentRaw, mmValue);
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Invalid mm value')),
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
