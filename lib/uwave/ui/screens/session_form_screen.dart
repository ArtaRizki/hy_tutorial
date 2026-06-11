import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_provider.dart';
import '../../data/models/session_model.dart';

/// Form untuk membuat sesi pengukuran baru.
class SessionFormScreen extends StatefulWidget {
  const SessionFormScreen({super.key});

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _partCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  String _unit = 'mm';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _partCtrl.dispose();
    _operatorCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final session = Session(
      name: _nameCtrl.text.trim(),
      partNumber: _partCtrl.text.trim().isEmpty ? null : _partCtrl.text.trim(),
      operatorName: _operatorCtrl.text.trim().isEmpty
          ? null
          : _operatorCtrl.text.trim(),
      toleranceMin: double.parse(_minCtrl.text.trim()),
      toleranceMax: double.parse(_maxCtrl.text.trim()),
      unit: _unit,
      createdAt: DateTime.now(),
    );

    await context.read<SessionProvider>().createSession(session);
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Sesi Baru',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Nama Sesi *'),
              _field(
                controller: _nameCtrl,
                hint: 'Contoh: Poros Ø12 - Batch 001',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              _label('Nomor Part / Kode Drawing'),
              _field(controller: _partCtrl, hint: 'DRW-2024-001'),
              const SizedBox(height: 16),
              _label('Nama Operator'),
              _field(controller: _operatorCtrl, hint: 'Nama operator QC'),
              const SizedBox(height: 24),
              // Toleransi
              _label('Toleransi'),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _minCtrl,
                      hint: 'Min',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib';
                        if (double.tryParse(v) == null) return 'Angka?';
                        return null;
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('~',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 20)),
                  ),
                  Expanded(
                    child: _field(
                      controller: _maxCtrl,
                      hint: 'Max',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib';
                        if (double.tryParse(v) == null) return 'Angka?';
                        final min = double.tryParse(_minCtrl.text);
                        final max = double.tryParse(v);
                        if (min != null && max != null && max <= min) {
                          return 'Max > Min';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Satuan
              _label('Satuan'),
              Row(
                children: ['mm', 'inch'].map((u) {
                  final selected = _unit == u;
                  return GestureDetector(
                    onTap: () => setState(() => _unit = u),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF6366F1)
                              : Colors.white12,
                        ),
                      ),
                      child: Text(u,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white54,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Buat Sesi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      );

  Widget _field({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF475569)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
