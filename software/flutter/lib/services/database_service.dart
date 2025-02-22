import 'package:ai_based_smart_energy_meter/models/device_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const dbCode = 'i6v29xWLkNNXWfGjta1jh3z336j2';

class DatabaseService {
  final _dbRef = FirebaseDatabase.instance.ref('/devices/$dbCode/reading');
  final _resetRef =
      FirebaseDatabase.instance.ref('/devices/$dbCode/data/reset');
  final DatabaseReference _dbref =
      FirebaseDatabase.instance.ref('/devices/$dbCode');
  final _databaseRef = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      print("Error in resetting flag: $e");
      rethrow;
    }
  }

  Stream<DateTime> monitorDeviceChanges(String dbCode) {
    final deviceRef = _databaseRef.ref('/devices/$dbCode/reading');
    return deviceRef.onValue.map((event) => DateTime.now());
  }

  Stream<double> monitorEnergyUpdates() {
    return _dbRef.child('energy').onValue.map((event) {
      final energyValue = event.snapshot.value as double? ?? 0.0;
      return energyValue;
    });
  }

  Future<void> saveMonthForAIMonitoring(String month) async {
    await _databaseRef.ref().child('/devices/$dbCode/ai_monitoring').set({
      'month': month,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<dynamic> getAIMonitoringResult() async {
    final snapshot = await _databaseRef.ref()
        .child('devices/$dbCode/ai_monitoring_result/result')
        .get();

    if (snapshot.exists && snapshot.value != null) {
      print('Fetched result: ${snapshot.value}'); // ✅ Debugging log
      return snapshot.value; // Can be double, string, etc.
    } else {
      print('No result found.');
      return null; // Or default value
    }
  }

  Future<double> getLatestEnergyValue() async {
    final snapshot = await _dbref.child("reading/energy").get();
    if (snapshot.exists) {
      return (snapshot.value as num).toDouble();
    }
    return 0.0;
  }

  // Fetch daily stored energy consumption
  Future<Map<String, double>> getDailyEnergyData() async {
    final snapshot = await _dbref.child("daily_energy").get();
    Map<String, double> dailyData = {};

    if (snapshot.exists) {
      for (var child in snapshot.children) {
        dailyData[child.key!] = (child.value as num).toDouble();
      }
    }
    return dailyData;
  }

  // Store daily energy consumption
  Future<void> storeDailyEnergy(double dailyEnergy) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _dbref.child("daily_energy/$today").set(dailyEnergy);
  }

  // Calculate and store daily energy consumption
  Future<void> calculateAndStoreDailyEnergy() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(Duration(days: 1)));

    // 🛑 Step 1: Fetch Yesterday's Energy (Use 0 if Not Found)
    final lastDayData = await _dbref.child("daily_energy/$yesterday").get();
    double yesterdayEnergy = (lastDayData.exists && lastDayData.value != null)
        ? (lastDayData.value as num).toDouble()
        : 0.0;

    // 🛑 Step 2: Fetch Today's Latest Energy Value
    double latestEnergy = await getLatestEnergyValue();

    // 🔥 Step 3: Check if a new value has been recorded today
    final todayData = await _dbref.child("daily_energy/$today").get();
    double storedTodayEnergy = (todayData.exists && todayData.value != null)
        ? (todayData.value as num).toDouble()
        : -1.0; // -1 to indicate no value stored yet

    if (storedTodayEnergy == latestEnergy) {
      print("⚠️ No new energy reading for today. Skipping update.");
      return; // 🚫 Do not overwrite today's value if nothing new arrived
    }

    // ✅ Step 4: Calculate Daily Consumption (Ensure No Negative Values)
    double dailyConsumption = (latestEnergy >= yesterdayEnergy)
        ? latestEnergy - yesterdayEnergy
        : 0.0;

    // ✅ Step 5: Store Daily Consumption Only If a New Value Exists
    if (dailyConsumption > 0) {
      await _dbref.child("daily_energy/$today").set(dailyConsumption);
      print("✅ Stored Daily Energy for $today: $dailyConsumption kWh");
    } else {
      print("⚠️ No increase in energy today. Not storing duplicate values.");
    }
  }


}
