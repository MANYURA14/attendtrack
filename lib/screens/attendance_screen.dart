import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/attendance_service.dart';
import '../services/auth_service.dart';

enum AttendState { idle, locating, success, failed, alreadyDone }

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  final _service = AttendanceService();
  final _auth = AuthService();
  AttendState _state = AttendState.idle;
  String _message = 'Tap the button below to verify your location and mark attendance.';
  double? _distance;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  static const bg = Color(0xFF07080F);
  static const card = Color(0xFF0D1220);
  static const accent = Color(0xFF00C8FF);
  static const green = Color(0xFF00FFB0);
  static const red = Color(0xFFFF4D6D);
  static const border = Color(0xFF1C2030);
  static const muted = Color(0xFF4A6480);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.92, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color get _stateColor {
    switch (_state) {
      case AttendState.success: return green;
      case AttendState.failed: return red;
      case AttendState.alreadyDone: return const Color(0xFFFFD166);
      default: return accent;
    }
  }

  IconData get _stateIcon {
    switch (_state) {
      case AttendState.success: return Icons.check_circle_outline;
      case AttendState.failed: return Icons.location_off_outlined;
      case AttendState.alreadyDone: return Icons.check_circle_outline;
      default: return Icons.my_location;
    }
  }

  String get _buttonLabel {
    switch (_state) {
      case AttendState.idle: return 'MARK ATTENDANCE';
      case AttendState.locating: return 'GETTING LOCATION...';
      case AttendState.success: return '✓ ATTENDANCE MARKED';
      case AttendState.failed: return 'TRY AGAIN';
      case AttendState.alreadyDone: return 'ALREADY MARKED TODAY';
    }
  }

  Future<void> _mark() async {
    setState(() {
      _state = AttendState.locating;
      _message = 'Acquiring GPS signal... Please wait.';
      _distance = null;
    });

    final result = await _service.markAttendance();

    setState(() {
      _distance = result.distance;
      _message = result.message;
      if (result.message.contains('already')) {
        _state = AttendState.alreadyDone;
      } else {
        _state = result.success ? AttendState.success : AttendState.failed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Mark Attendance',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                        color: Colors.white)),
                    Text(_today(),
                      style: const TextStyle(color: muted, fontSize: 13)),
                  ]),
                  GestureDetector(
                    onTap: () => _auth.signOut(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border),
                      ),
                      child: const Row(children: [
                        Icon(Icons.logout, color: muted, size: 15),
                        SizedBox(width: 6),
                        Text('Logout', style: TextStyle(color: muted, fontSize: 12)),
                      ]),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Student info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.email ?? 'Student',
                        style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700, fontSize: 14)),
                      const Text('Mobile Computing · CS301',
                        style: TextStyle(color: muted, fontSize: 12)),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: green.withOpacity(0.3)),
                    ),
                    child: const Text('LIVE', style: TextStyle(color: green,
                      fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),

              const SizedBox(height: 32),

              // GPS pulse animation
              Center(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Transform.scale(
                    scale: _state == AttendState.locating ? _pulse.value : 1.0,
                    child: Stack(alignment: Alignment.center, children: [
                      // Outer ring
                      Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _stateColor.withOpacity(0.15), width: 1),
                        ),
                      ),
                      // Middle ring
                      Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _stateColor.withOpacity(0.25), width: 1.5),
                        ),
                      ),
                      // Inner circle
                      Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _stateColor.withOpacity(0.08),
                          border: Border.all(
                            color: _stateColor.withOpacity(0.5), width: 2),
                          boxShadow: [BoxShadow(
                            color: _stateColor.withOpacity(0.25),
                            blurRadius: 30, spreadRadius: 5)],
                        ),
                        child: _state == AttendState.locating
                          ? Center(child: CircularProgressIndicator(
                              color: _stateColor, strokeWidth: 3))
                          : Icon(_stateIcon, size: 52, color: _stateColor),
                      ),
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Distance badge
              if (_distance != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: _stateColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _stateColor.withOpacity(0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.location_pin, color: _stateColor, size: 16),
                      const SizedBox(width: 6),
                      Text('${_distance!.toStringAsFixed(1)}m from classroom',
                        style: TextStyle(color: _stateColor,
                          fontWeight: FontWeight.w700, fontSize: 14)),
                    ]),
                  ),
                ),

              const SizedBox(height: 16),

              // Status message
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(_message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14, height: 1.5)),
                ),
              ),

              const SizedBox(height: 32),

              // Main button
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: (_state == AttendState.locating ||
                      _state == AttendState.success ||
                      _state == AttendState.alreadyDone)
                    ? null : _mark,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _stateColor,
                    disabledBackgroundColor: _stateColor.withOpacity(0.25),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(_buttonLabel,
                    style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ),
              ),

              const SizedBox(height: 32),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Column(children: [
                  _infoRow(Icons.location_on, 'Block B, Room 204', accent),
                  const SizedBox(height: 10),
                  _infoRow(Icons.radar, 'GPS geofence radius: 80 metres', muted),
                  const SizedBox(height: 10),
                  _infoRow(Icons.security, 'GPS-verified · Proxy-proof', green),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 10),
      Text(text, style: TextStyle(color: color, fontSize: 13)),
    ]);
  }

  String _today() {
    final now = DateTime.now();
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[now.weekday-1]}, ${now.day} ${months[now.month-1]} ${now.year}';
  }
}
