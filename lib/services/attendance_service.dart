import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gps_service.dart';

class AttendanceResult {
  final bool success;
  final String message;
  final double? distance;

  AttendanceResult({required this.success, required this.message, this.distance});
}

class AttendanceService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _gps = GpsService();

  Future<AttendanceResult> markAttendance() async {
    final user = _auth.currentUser;
    if (user == null) return AttendanceResult(success: false, message: 'Not logged in.');

    try {
      // Get active class
      final classData = await _gps.getActiveClass();
      final classId = classData['classId'];

      // Check already marked
      final existing = await _db
          .collection('attendance')
          .where('classId', isEqualTo: classId)
          .where('studentId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return AttendanceResult(
          success: false,
          message: 'You have already marked attendance for this class.',
        );
      }

      // Get GPS position
      final position = await _gps.getCurrentPosition();

      // Calculate distance
      final distance = _gps.calculateDistance(
        position.latitude, position.longitude,
        classData['lat'], classData['lng'],
      );

      // Geofence check
      if (!_gps.isWithinGeofence(distance, classData['radius'])) {
        return AttendanceResult(
          success: false,
          distance: distance,
          message:
              'You are ${distance.toStringAsFixed(0)}m away. Must be within ${classData['radius'].toInt()}m of the classroom.',
        );
      }

      // Write to Firestore
      await _db.collection('attendance').add({
        'studentId': user.uid,
        'classId': classId,
        'courseId': classData['courseId'],
        'status': 'present',
        'markedAt': FieldValue.serverTimestamp(),
        'studentLocation': GeoPoint(position.latitude, position.longitude),
        'distanceFromClass': distance,
        'gpsVerified': true,
      });

      return AttendanceResult(
        success: true,
        distance: distance,
        message: 'Attendance marked! You are ${distance.toStringAsFixed(0)}m from the classroom.',
      );
    } catch (e) {
      return AttendanceResult(success: false, message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Stream<List<Map<String, dynamic>>> getMyAttendance() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('attendance')
        .where('studentId', isEqualTo: uid)
        .orderBy('markedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }
}
