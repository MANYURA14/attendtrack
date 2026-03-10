import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class GpsService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS is disabled. Please turn on Location in settings.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Enable in App Settings.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0;
    double toRad(double d) => d * pi / 180;
    double dLat = toRad(lat2 - lat1);
    double dLon = toRad(lng2 - lng1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(toRad(lat1)) * cos(toRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  bool isWithinGeofence(double distanceMeters, double radiusMeters) {
    return distanceMeters <= radiusMeters;
  }

  Future<Map<String, dynamic>> getActiveClass() async {
    final query = await FirebaseFirestore.instance
        .collection('classes')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw Exception('No active class found right now.');

    final data = query.docs.first.data();
    final GeoPoint geoPoint = data['location'];

    return {
      'classId': query.docs.first.id,
      'lat': geoPoint.latitude,
      'lng': geoPoint.longitude,
      'radius': (data['geofenceRadius'] as num).toDouble(),
      'roomName': data['roomName'] ?? 'Classroom',
      'courseId': data['courseId'] ?? '',
    };
  }
}
