import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  static const bg = Color(0xFF07080F);
  static const card = Color(0xFF0D1220);
  static const accent = Color(0xFF00C8FF);
  static const border = Color(0xFF1C2030);
  static const muted = Color(0xFF4A6480);

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.signIn(_emailCtrl.text, _passCtrl.text);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: accent.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.location_on, color: accent, size: 40),
                ),
              ),
              const SizedBox(height: 24),

              const Center(
                child: Text('AttendTrack',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900,
                    color: Colors.white, letterSpacing: -0.5)),
              ),
              const Center(
                child: Text('GPS Attendance System',
                  style: TextStyle(fontSize: 14, color: muted)),
              ),
              const SizedBox(height: 48),

              // Email
              _label('Email Address'),
              const SizedBox(height: 8),
              _field(controller: _emailCtrl, hint: 'student@university.ac.ke',
                icon: Icons.email_outlined),
              const SizedBox(height: 18),

              // Password
              _label('Password'),
              const SizedBox(height: 8),
              _field(
                controller: _passCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                    color: muted, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 14),

              // Error
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D6D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFF4D6D).withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Color(0xFFFF4D6D), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!,
                      style: const TextStyle(color: Color(0xFFFF4D6D), fontSize: 13))),
                  ]),
                ),

              const SizedBox(height: 28),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    disabledBackgroundColor: accent.withOpacity(0.3),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                    : const Text('Sign In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                          letterSpacing: 0.5)),
                ),
              ),

              const SizedBox(height: 24),

              // Register link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: RichText(text: const TextSpan(
                    text: "Don't have an account?  ",
                    style: TextStyle(color: muted, fontSize: 14),
                    children: [
                      TextSpan(text: 'Register',
                        style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
    style: const TextStyle(fontSize: 12, color: Color(0xFF7A9BB5),
      fontWeight: FontWeight.w600, letterSpacing: 0.8));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF2E4060), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF4A6480), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00C8FF), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
