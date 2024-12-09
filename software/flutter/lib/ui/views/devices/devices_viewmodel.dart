import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stacked/stacked.dart';

class DeviceViewModel extends BaseViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _realtimeDatabase = FirebaseDatabase.instance.ref();

  Stream<QuerySnapshot> get devicesStream =>
      _firestore.collection('devices').snapshots();

  Future<void> addDevice(String deviceName, String deviceId) async {
    if (deviceName.isNotEmpty) {
      await _firestore.collection('devices').doc(deviceId).set({
        'name': deviceName,
        'totalUsage': 0,
        'beforeValue': 0,
        'isMonitoring': false,
      });
      notifyListeners();
    }
  }

  Future<void> startMonitoring(String deviceId) async {
    final energyRef =
    _realtimeDatabase.child('devices/i6v29xWLkNNXWfGjta1jh3z336j2/reading/energy');

    final snapshot = await energyRef.get();
    final currentEnergyValue = (snapshot.value as num?)?.toDouble() ?? 0.0;

    await _firestore.collection('devices').doc(deviceId).update({
      'isMonitoring': true,
      'beforeValue': currentEnergyValue,
    });
    notifyListeners();
  }

  Future<void> endMonitoring(String deviceId) async {
    final energyRef =
    _realtimeDatabase.child('devices/i6v29xWLkNNXWfGjta1jh3z336j2/reading/energy');

    final snapshot = await energyRef.get();
    final currentEnergyValue = (snapshot.value as num?)?.toDouble() ?? 0.0;

    final docSnapshot = await _firestore.collection('devices').doc(deviceId).get();
    final data = docSnapshot.data();

    if (data != null) {
      final beforeValue = (data['beforeValue'] as num?)?.toDouble() ?? 0.0;
      final totalUsage = (data['totalUsage'] as num?)?.toDouble() ?? 0.0;

      final currentUsage = currentEnergyValue - beforeValue;
      final updatedTotalUsage = totalUsage + currentUsage;

      await _firestore.collection('devices').doc(deviceId).update({
        'isMonitoring': false,
        'beforeValue': currentEnergyValue,
        'totalUsage': updatedTotalUsage,
      });
      notifyListeners();
    }
  }

  Future<void> resetUsage(String deviceId) async {
    await _firestore.collection('devices').doc(deviceId).update({
      'totalUsage': 0,
      'beforeValue': 0,
    });
    notifyListeners();
  }
}
