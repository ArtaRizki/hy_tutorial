import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/ble_provider.dart';
import '../../core/constants/ble_constants.dart';

class BleDiagnosticScreen extends StatefulWidget {
  const BleDiagnosticScreen({super.key});

  @override
  State<BleDiagnosticScreen> createState() => _BleDiagnosticScreenState();
}

class _BleDiagnosticScreenState extends State<BleDiagnosticScreen> {
  final TextEditingController _customWriteController = TextEditingController();
  String _selectedWriteChar = BleConstants.write1;
  bool _isHexMode = false;

  @override
  void dispose() {
    _customWriteController.dispose();
    super.dispose();
  }

  // Share logs as a txt file
  Future<void> _shareLogs(BuildContext context, BleProvider ble) async {
    if (ble.diagnosticLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log masih kosong.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/uwave_ble_diagnostic_log.txt');
      
      final buffer = StringBuffer();
      buffer.writeln('=== U-WAVE BLE DIAGNOSTIC LOG ===');
      buffer.writeln('Device: ${ble.connectedDevice?.platformName ?? 'Unknown'} (${ble.connectedDevice?.remoteId ?? 'Unknown'})');
      buffer.writeln('Export Date: ${DateTime.now()}\n');
      
      for (final logItem in ble.diagnosticLogs) {
        buffer.writeln(logItem.formatForLogging);
      }
      
      await file.writeAsString(buffer.toString());
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'U-WAVE BLE Diagnostic Logs',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membagikan log: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _sendCustomBytes(BuildContext context, BleProvider ble) {
    final text = _customWriteController.text.trim();
    if (text.isEmpty) return;

    List<int> bytes = [];
    if (_isHexMode) {
      // Parse HEX: e.g. "01 0D" or "010D"
      try {
        final cleanHex = text.replaceAll(RegExp(r'\s+'), '');
        for (var i = 0; i < cleanHex.length; i += 2) {
          final hexByte = cleanHex.substring(i, i + 2);
          bytes.add(int.parse(hexByte, radix: 16));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format HEX tidak valid! Contoh: "01 0D"'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } else {
      // Parse ASCII text
      bytes = text.codeUnits;
    }

    ble.writeCommand(_selectedWriteChar, bytes);
    _customWriteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'U-WAVE BLE Diagnostic Tool',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<BleProvider>(
            builder: (context, ble, _) => IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white70),
              tooltip: 'Share Log',
              onPressed: () => _shareLogs(context, ble),
            ),
          ),
          Consumer<BleProvider>(
            builder: (context, ble, _) => IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
              tooltip: 'Clear Log',
              onPressed: () => ble.clearDiagnosticLogs(),
            ),
          ),
        ],
      ),
      body: Consumer<BleProvider>(
        builder: (context, ble, _) {
          return Column(
            children: [
              // ── Header Status Koneksi ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF1E293B),
                child: Row(
                  children: [
                    Icon(
                      ble.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: ble.isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ble.isConnected ? 'Terhubung: ${ble.connectedDevice?.platformName}' : 'Perangkat Terputus',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            ble.isConnected ? 'ID: ${ble.connectedDevice?.remoteId}' : 'Hubungkan perangkat di layar utama untuk memulai sniffer',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Panel Write Commands ───────────────────────────
              if (ble.isConnected)
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kirim Write Command (Trigger)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Karakteristik:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedWriteChar,
                              dropdownColor: const Color(0xFF1E293B),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: BleConstants.write1,
                                  child: Text('write1 (...f154)'),
                                ),
                                DropdownMenuItem(
                                  value: BleConstants.write2,
                                  child: Text('write2 (...f155)'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedWriteChar = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Predefined commands
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickButton(context, ble, 'Send [0x01]', [0x01]),
                          _buildQuickButton(context, ble, 'Send [0x0D] (CR)', [0x0D]),
                          _buildQuickButton(context, ble, "Send '1' (0x31)", [0x31]),
                          _buildQuickButton(context, ble, "Send '?' (0x3F)", [0x3F]),
                          _buildQuickButton(context, ble, 'Handshake [0x5F]', [0x5F]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Custom command input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customWriteController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: _isHexMode ? 'HEX: e.g. 01 0D' : 'ASCII: e.g. read',
                                hintStyle: const TextStyle(color: Color(0xFF475569)),
                                isDense: true,
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF475569)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Toggle Mode
                          TextButton(
                            onPressed: () => setState(() => _isHexMode = !_isHexMode),
                            child: Text(_isHexMode ? 'HEX' : 'ASCII', style: const TextStyle(color: Color(0xFF6366F1))),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: Color(0xFF10B981)),
                            onPressed: () => _sendCustomBytes(context, ble),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // ── Live Logs View ────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF020617),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: ble.diagnosticLogs.isEmpty
                      ? const Center(
                          child: Text(
                            'Menunggu data masuk...\nSilakan tekan tombol DATA pada transmitter U-WAVE\natau kirim write command di atas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.5),
                          ),
                        )
                      : ListView.builder(
                          reverse: true, // log terbaru di atas
                          itemCount: ble.diagnosticLogs.length,
                          itemBuilder: (context, index) {
                            final logItem = ble.diagnosticLogs[ble.diagnosticLogs.length - 1 - index];
                            final isWrite = logItem.characteristicUuid.contains('WRITE');
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isWrite ? const Color(0xFF06201B) : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isWrite ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '⏱ ${logItem.timeStr}',
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                      ),
                                      Text(
                                        isWrite ? '🖊 WRITE' : '📥 NOTIFY (...${logItem.characteristicUuid.substring(Math.max(0, logItem.characteristicUuid.length - 4))})',
                                        style: TextStyle(
                                          color: isWrite ? const Color(0xFF34D399) : const Color(0xFF818CF8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  SelectableText(
                                    'Raw: ${logItem.bytes}',
                                    style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 12),
                                  ),
                                  SelectableText(
                                    'HEX: ${logItem.hex}',
                                    style: const TextStyle(color: Color(0xFFFBBF24), fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    'ASCII: ${logItem.ascii}',
                                    style: const TextStyle(color: Color(0xFF38BDF8), fontFamily: 'monospace', fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickButton(BuildContext context, BleProvider ble, String label, List<int> bytes) {
    return ActionChip(
      backgroundColor: const Color(0xFF334155),
      side: BorderSide.none,
      label: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      onPressed: () {
        ble.writeCommand(_selectedWriteChar, bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Command $bytes dikirim!'),
            duration: const Duration(milliseconds: 500),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}

class Math {
  static int max(int a, int b) => a > b ? a : b;
}
