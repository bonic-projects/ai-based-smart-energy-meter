import 'dart:async';

import 'package:ai_based_smart_energy_meter/app/app.locator.dart';
import 'package:ai_based_smart_energy_meter/app/app.logger.dart';
import 'package:ai_based_smart_energy_meter/services/database_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../models/device_data.dart';

class HomeViewModel extends ReactiveViewModel {
  final _databaseService = locator<DatabaseService>();
  // final FirebaseService _firebaseService = FirebaseService();
  final _snackbarService = SnackbarService();
// final log= getLogger('HomeViewModel');

  DeviceReading? _deviceReading;
  double _energyLimit = 0.0;
  double _dailyConsumption = 0.0;
  double _previousEnergy = 0.0;
  bool isOnline = false;
  DateTime? lastUpdateTime;
  Timer? _statusCheckTimer;

  DeviceReading? get deviceReading => _deviceReading;
  double get energyLimit => _energyLimit;
  double get dailyConsumption => _dailyConsumption;

  Future<void> initialize() async {
    await _loadEnergyLimit();
    await fetchDeviceData();
    await _loadPreviousEnergy();
    await _checkDailyReset();
    // await _getPreviousEnergy();
    _monitorDeviceChanges();
    _startStatusCheck();
  }

  Future<void> _loadEnergyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    _energyLimit = prefs.getDouble('energy_limit') ?? 0.0;
    notifyListeners();
  }

  Future<void> _loadPreviousEnergy() async {
    final prefs = await SharedPreferences.getInstance();
    _previousEnergy = prefs.getDouble('previous_energy') ?? 0.0;
  }

  Future<void> setEnergyLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('energy_limit', limit);
    _energyLimit = limit;
    notifyListeners();
    checkLimitExceeded();
  }

  Future<void> fetchDeviceData() async {
    try {
      final data = await _databaseService.fetchDeviceData();
      if (data != null) {
        _deviceReading = data;
        notifyListeners();
      } else {
        // log.i('No data returned from Firebase');
      }
    } catch (e) {
      // log.e('Error fetching device data: $e');
      // print('Error fetching device data: $e');
    }
  }

  /// Reset daily consumption at the start of a new day
  Future<void> _checkDailyReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetTimestamp = prefs.getInt('last_reset_timestamp') ?? 0;

    final now = DateTime.now();
    final lastResetDate =
    DateTime.fromMillisecondsSinceEpoch(lastResetTimestamp);

    if (now.day != lastResetDate.day ||
        now.month != lastResetDate.month ||
        now.year != lastResetDate.year) {
      // New day detected
      await prefs.setInt('last_reset_timestamp', now.millisecondsSinceEpoch);
      final currentEnergy = _deviceReading?.energy ?? 0.0;
      await prefs.setDouble('previous_energy', currentEnergy);
      // log.i("New day reset. Current energy stored as previous: $currentEnergy");
      // print("New day reset. Current energy stored as previous: $currentEnergy");
      _dailyConsumption = 0.0; // Reset daily consumption
    } else {
      // Calculate consumption
      final previousEnergy = prefs.getDouble('previous_energy') ?? 0.0;
      final currentEnergy = _deviceReading?.energy ?? 0.0;
      _dailyConsumption = currentEnergy - previousEnergy;
      // log.i("Continuing day. Current energy: $currentEnergy, Previous energy: $previousEnergy, Daily consumption: $_dailyConsumption");
      // print(
      //     "Continuing day. Current energy: $currentEnergy, Previous energy: $previousEnergy, Daily consumption: $_dailyConsumption");
    }

    notifyListeners();
  }


  void calculateDailyConsumption() {
    _dailyConsumption = (_deviceReading?.energy ?? 0.0) - _previousEnergy;
    if (_dailyConsumption < 0)
      _dailyConsumption = 0.0; // Prevent negative values
    notifyListeners();
    checkLimitExceeded();
  }

  // Future<double> _getPreviousEnergy() {
  //   final prefs = SharedPreferences.getInstance();
  //   return prefs.then((prefs) => prefs.getDouble('previous_energy') ?? 0.0);
  // }

  void checkLimitExceeded() {
    if (_dailyConsumption > _energyLimit) {
      _snackbarService.showSnackbar(
        message: 'You have exceeded your set limit!',
        title: 'Limit Exceeded',
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _monitorDeviceChanges() {
    final dbCode = "devices/i6v29xWLkNNXWfGjta1jh3z336j2/reading";
    _databaseService.monitorDeviceChanges(dbCode).listen((timestamp) {
      lastUpdateTime = timestamp;
      isOnline = true;
      notifyListeners();
    });
  }

  void _startStatusCheck() {
    const offlineThreshold = Duration(seconds: 5); // Threshold for offline status
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (lastUpdateTime == null) return;

      final timeSinceLastUpdate = DateTime.now().difference(lastUpdateTime!);
      if (timeSinceLastUpdate > offlineThreshold) {
        if (isOnline) {
          isOnline = false;
          notifyListeners(); // Notify only if the status changes
        }
      }
    });
  }
  @override
  void dispose() {
    _statusCheckTimer?.cancel(); // Cancel the timer when the view model is disposed
    super.dispose();
  }

  Future<void> resetValue() async {
    try {
      setBusy(true); // Indicate that the ViewModel is busy
      await _databaseService.resetFlag();
    } catch (e) {
      // log.e("Error resetting value in ViewModel: $e");
      // print("Error resetting value in ViewModel: $e");
    } finally {
      setBusy(false); // Reset the busy state
    }
  }
}
