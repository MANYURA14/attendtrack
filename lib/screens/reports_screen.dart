import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/attendance_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const bg = Color(0xFF07080F);
  static const card = Color(0xFF0D1220);
  static const accent = Color(0xFF00C8FF);
  static const green = Color(0xFF00FFB0);
  static const red = Color(0xFFFF4D6D);
  static const yellow = Color(0xFFFFD166);
  static const border = Color(0xFF1C2030);
  static const muted = Color(0xFF4A6480);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Reports',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                  color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Your attendance history',
                style: TextStyle(color: muted, fontSize: 13)),
              const SizedBox(height: 24),

              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: AttendanceService().getMyAttendance(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: accent));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 64, color: muted.withOpacity(0.4)),
                            const SizedBox(height: 16),
                            const Text('No attendance records yet.',
                              style: TextStyle(color: muted, fontSize: 15)),
                            const SizedBox(height: 8),
                            const Text('Mark your first attendance to see it here.',
                              style: TextStyle(color: Color(0xFF2E4060), fontSize: 13)),
                          ],
                        ),
                      );
                    }

                    final records = snapshot.data!;
                    final presentCount = records.where((r) => r['status'] == 'present').length;
                    final rate = records.isEmpty ? 0 : (presentCount / records.length * 100).round();

                    return Column(
                      children: [
                        // Summary cards
                        Row(children: [
                          _statCard('${records.length}', 'Total', accent),
                          const SizedBox(width: 10),
                          _statCard('$presentCount', 'Present', green),
                          const SizedBox(width: 10),
                          _statCard('$rate%', 'Rate',
                            rate >= 75 ? green : rate >= 50 ? yellow : red),
                        ]),

                        const SizedBox(height: 16),

                        // Rate bar
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: card, borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border),
                          ),
                          child: Column(children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Attendance Rate',
                                  style: TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                                Text('$rate%',
                                  style: TextStyle(
                                    color: rate >= 75 ? green : red,
                                    fontWeight: FontWeight.w900, fontSize: 16)),
                              ]),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: rate / 100,
                                backgroundColor: border,
                                valueColor: AlwaysStoppedAnimation(
                                  rate >= 75 ? green : red),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Min required: 75%',
                                  style: TextStyle(color: muted, fontSize: 11)),
                                Text(rate >= 75 ? '✓ Exam eligible' : '⚠ Below minimum',
                                  style: TextStyle(
                                    color: rate >= 75 ? green : red, fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                              ]),
                          ]),
                        ),

                        const SizedBox(height: 16),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Recent Records',
                            style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800, fontSize: 15)),
                        ),
                        const SizedBox(height: 10),

                        // Records list
                        Expanded(
                          child: ListView.separated(
                            itemCount: records.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final r = records[i];
                              final status = r['status'] ?? 'absent';
                              final ts = r['markedAt'];
                              final color = status == 'present' ? green
                                : status == 'late' ? yellow : red;
                              String dateStr = '—';
                              if (ts is Timestamp) {
                                final d = ts.toDate();
                                const m = ['Jan','Feb','Mar','Apr','May','Jun',
                                           'Jul','Aug','Sep','Oct','Nov','Dec'];
                                dateStr = '${d.day} ${m[d.month-1]} · '
                                  '${d.hour.toString().padLeft(2,'0')}:'
                                  '${d.minute.toString().padLeft(2,'0')}';
                              }

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: border),
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 10, height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                      boxShadow: [BoxShadow(color: color.withOpacity(0.5),
                                        blurRadius: 6)],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(dateStr,
                                        style: const TextStyle(color: Colors.white,
                                          fontWeight: FontWeight.w600, fontSize: 13)),
                                      if (r['distanceFromClass'] != null)
                                        Text('📍 ${(r['distanceFromClass'] as num).toStringAsFixed(0)}m from classroom',
                                          style: const TextStyle(color: muted, fontSize: 11)),
                                    ],
                                  )),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: color.withOpacity(0.3)),
                                    ),
                                    child: Text(status.toUpperCase(),
                                      style: TextStyle(color: color, fontSize: 10,
                                        fontWeight: FontWeight.w800)),
                                  ),
                                ]),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: card, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(children: [
          Text(val, style: TextStyle(color: color, fontSize: 22,
            fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: muted, fontSize: 11,
            letterSpacing: 0.8)),
        ]),
      ),
    );
  }
}
