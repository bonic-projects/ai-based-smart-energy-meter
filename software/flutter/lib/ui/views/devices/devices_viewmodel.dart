import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stacked/stacked.dart';

class DeviceViewModel extends BaseViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _realtimeDatabase = FirebaseDatabase.instance.ref();

  Stream<QuerySnapshot> get devicesStream =>
      _firestore.collection('devices').snapshots();

  // Add a new device to Firestore
  Future<void> addDevice(String deviceName, String deviceId) async {
    if (deviceName.isNotEmpty) {
      await _firestore.collection('devices').doc(deviceId).set({
        'name': deviceName,
        'totalUsage': 0,
        'beforeValue': 0,
        'isMonitoring': false,
      });
    }
  }

  // Start monitoring a device
  Future<void> startMonitoring(String deviceId) async {
    final energyRef = _realtimeDatabase.child('devices/i6v29xWLkNNXWfGjta1jh3z336j2/reading/energy');

    // Fetch current energy value from Realtime Database
    final snapshot = await energyRef.get();
    final currentEnergyValue = snapshot.value as double? ?? 00;

    // Update Firestore with the starting point for monitoring
    await _firestore.collection('devices').doc(deviceId).update({
      'isMonitoring': true,
      'beforeValue': currentEnergyValue, // Save the "starting point"
    });

    notifyListeners();
  }

  // End monitoring and update total usage
  Future<void> endMonitoring(String deviceId) async {
    final energyRef = _realtimeDatabase.child('devices/i6v29xWLkNNXWfGjta1jh3z336j2/reading/energy');

    // Fetch current energy value
    final snapshot = await energyRef.get();
    final currentEnergyValue =( snapshot.value as num?)?.toDouble()?? 0.0;

    // Get Firestore data for the device
    final docSnapshot = await _firestore.collection('devices').doc(deviceId).get();
    final data = docSnapshot.data();

    if (data != null) {
      final beforeValue = (data['beforeValue'] as num?)?.toDouble() ?? 0.0;
      final totalUsage = (data['totalUsage'] as num?)?.toDouble() ?? 0.0;

      // Calculate new total usage
      final currentUsage = currentEnergyValue - beforeValue;
      final updatedTotalUsage = totalUsage + currentUsage;

      // Update Firestore with the new values
      await _firestore.collection('devices').doc(deviceId).update({
        'isMonitoring': false,
        'beforeValue': updatedTotalUsage, // Set to new total usage
        'totalUsage': updatedTotalUsage,
      });
    }

    notifyListeners();
  }
  // Reset usage to zero for a specific device
  Future<void> resetUsage(String deviceId) async {
    await _firestore.collection('devices').doc(deviceId).update({
      'totalUsage': 0,
      'beforeValue': 0,
    });
    notifyListeners();
  }

}
