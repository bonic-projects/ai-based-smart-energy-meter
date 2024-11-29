import 'package:ai_based_smart_energy_meter/app/app.logger.dart';
import 'package:ai_based_smart_energy_meter/models/device_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

const dbCode = 'i6v29xWLkNNXWfGjta1jh3z336j2';

class DatabaseService {
  final _dbRef = FirebaseDatabase.instance.ref('/devices/$dbCode/reading');
  final _resetRef=FirebaseDatabase.instance.ref('/devices/$dbCode/data/reset');
  final _databaseRef=FirebaseDatabase.instance;
  final log=getLogger('DatabaseService');

  Future<DeviceReading?> fetchDeviceData() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      return DeviceReading.fromMap(snapshot.value as Map);
    }
    return null;
  }

  Future<void> setEnergyLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('energy_limit', limit);
  }

  Future<double> getEnergyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('energy_limit') ?? 0.0;
  }


  Future<void> resetFlag() async {
    try {

      await _resetRef.set(true);

      await Future.delayed(const Duration(seconds: 5));

      await _resetRef.set(false);
    } catch (e) {
      log.e("Error in resetting flag: $e");
      // print("Error in resetting flag: $e");
      rethrow;
    }
  }


  Stream<DateTime> monitorDeviceChanges(String dbCode) {
    final deviceRef = _databaseRef.ref('/devices/i6v29xWLkNNXWfGjta1jh3z336j2/reading');
    return deviceRef.onValue.map((event) {
      // When a change occurs, return the current timestamp
      return DateTime.now();
    });
  }
}
