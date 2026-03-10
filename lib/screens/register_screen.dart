import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  static const accent = Color(0xFF00C8FF);
  static const card = Color(0xFF0D1220);
  static const border = Color(0xFF1C2030);
  static const muted = Color(0xFF4A6480);

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty || _studentIdCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.signUp(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        name: _nameCtrl.text,
        studentId: _studentIdCtrl.text,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07080F),
        foregroundColor: Colors.white,
        title: const Text('Create Account',
          style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _field(_nameCtrl, 'Full Name', Icons.person_outline),
              const SizedBox(height: 16),
              _field(_studentIdCtrl, 'Student ID (e.g. STU-2024-0091)', Icons.badge_outlined),
              const SizedBox(height: 16),
              _field(_emailCtrl, 'Email Address', Icons.email_outlined),
              const SizedBox(height: 16),
              _field(_passCtrl, 'Password (min 6 chars)', Icons.lock_outline, obscure: true),
              const SizedBox(height: 14),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D6D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFF4D6D).withOpacity(0.3)),
                  ),
                  child: Text(_error!,
                    style: const TextStyle(color: Color(0xFFFF4D6D), fontSize: 13)),
                ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Create Account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF2E4060)),
        prefixIcon: Icon(icon, color: muted, size: 20),
        filled: true, fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5)),
      ),
    );
  }
}
