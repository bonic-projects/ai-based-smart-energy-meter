import 'package:firebase_database/firebase_database.dart';
import '../models/smart_device.dart';

class DeviceService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String deviceId = 'q5GhnHGznPWqwTNh1bFYBapJW2J3';
  final String deviceId2 = '6G6BPp3v5Jdlw0EzhLa5QxK9gG13';
  final String deviceId3 = 'RBuQzGM8fsMBcn4fayDKhdG8x873';

  Stream<DeviceData> getDevice1Data() {
    return _database
        .child('devices/$deviceId/reading')
        .onValue
        .map(_mapToDeviceData);
  }

  Stream<DeviceData> getDevice2Data() {
    return _database
        .child('devices/$deviceId2/reading')
        .onValue
        .map(_mapToDeviceData);
  }

  Stream<DeviceData> getDevice3Data() {
    return _database
        .child('devices/$deviceId3/reading')
        .onValue
        .map(_mapToDeviceData);
  }

  DeviceData _mapToDeviceData(DatabaseEvent event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>;
    return DeviceData(
        totalUsage: data['energy']?.toDouble() ?? 0,
        voltage: data['voltage']?.toDouble() ?? 0,
        current: data['current']?.toDouble() ?? 0,
        power: data['power']?.toDouble() ?? 0,
        energy: data['energy']?.toDouble() ?? 0,
        cost: data['cost']?.toDouble() ?? 0,
        isOn: data['state'] ?? false,
        reset: data['reset'] ?? false);
  }

  // Device 1 state management
  Stream<bool> getDevice1State() {
    return _database.child('devices/$deviceId/data/state').onValue.map((event) {
      final data = event.snapshot.value;
      return data == true;
    });
  }

  // Device 2 state management
  Stream<bool> getDevice2State() {
    return _database
        .child('devices/$deviceId2/data/state')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      return data == true;
    });
  }

  // Device 3 state management
  Stream<bool> getDevice3State() {
    return _database
        .child('devices/$deviceId3/data/state')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      return data == true;
    });
  }

  // Generic method to update device state
  Future<void> updateDeviceState(String deviceId, bool isOn) async {
    await _database.child('devices/$deviceId/data').update({
      'state': isOn,
    });
  }

  Future<void> updateResetState(String deviceId, bool reset) async {
    // Simulate a network call to update the reset state in the database
    await _database.child('devices/$deviceId/data').update({
      'reset': reset,
    });
    await Future.delayed(Duration(seconds: 1)); // Simulate delay
    print('Reset state updated for device $deviceId: $reset');
  }
}
