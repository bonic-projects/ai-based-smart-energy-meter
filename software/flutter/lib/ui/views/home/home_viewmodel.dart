import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../models/device_data.dart';
import '../../../services/database_service.dart';
import '../notification/notification_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  final DatabaseService _databaseService;
  final NotificationViewModel _notificationViewModel;
  final SnackbarService _snackbarService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription? _deviceMonitorSubscription;
  StreamSubscription? _energyUpdateSubscription;
  Timer? _refreshTimer;
  Timer? _resultTimer;
  Map<DateTime, double> dailyEnergyConsumption = {};
  Map<String, double> _dailyEnergyData = {};
  Map<String, double> get dailyEnergyData => _dailyEnergyData;
  bool _isAlertShowing = false;
  bool _isAlertDismissed = false;
  bool isAIMonitoringEnabled = false;

  double _monthlyLimit = 0.0;
  DeviceReading? _deviceData;
  List<FlSpot> energyDataPoints = [];
  final Map<String, double> dailyTotals = {};
  String? aiPrediction;

  HomeViewModel({required DatabaseService databaseService, required NotificationViewModel notificationViewModel,
    required SnackbarService snackbarService
  })
      : _databaseService = databaseService,
        _notificationViewModel = notificationViewModel,
        _snackbarService=snackbarService
  {
    _initializeData();
    _startMonitoring();
  }

  DeviceReading? get deviceData => _deviceData;
  double get monthlyLimit => _monthlyLimit;
  bool get isAlertDismissed => _isAlertDismissed;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> _initializeData() async {
    setBusy(true);
    try {
      print("Starting initialization...");
      await _fetchDeviceData();
      await _loadEnergyLimit();
      fetchDailyEnergyData();
    } catch (e) {
      print("Error in initialization: $e");
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  void _setupDailyDataTracking() {
    _deviceMonitorSubscription?.cancel();
    _deviceMonitorSubscription =
        _databaseService.monitorDeviceChanges(dbCode).listen((_) async {
      await _fetchDeviceData();
    });
  }

  Future<void> _fetchDeviceData() async {
    try {
      _deviceData = await _databaseService.fetchDeviceData();
      _checkEnergyLimit();
      processDailyEnergy();
      notifyListeners();
    } catch (e) {
      setError(e);
    }
  }

  Future<void> fetchDailyEnergyData() async {
    _isLoading = true;
    notifyListeners();

    _dailyEnergyData = await _databaseService.getDailyEnergyData();
    print('🔥 Fetched Data from Firebase: $_dailyEnergyData');

    // Convert date keys (2025-02-07) to weekday names (Fri)
    Map<String, double> processedData = {};
    _dailyEnergyData.forEach((key, value) {
      try {
        DateTime date = DateTime.parse(key); // Convert "YYYY-MM-DD" to DateTime
        String dayName = DateFormat('EEE').format(date); // Convert to "Fri"
        processedData[dayName] = value; // Store in new map
      } catch (e) {
        print('❌ Error parsing date: $key');
      }
    });

    _dailyEnergyData = processedData;
    print('✅ Processed Data: $_dailyEnergyData');

    _isLoading = false;
    notifyListeners();
  }

  // Ensure daily calculation runs
  Future<void> processDailyEnergy() async {
    await _databaseService.calculateAndStoreDailyEnergy();
    await fetchDailyEnergyData();
  }

  List<BarChartGroupData> getBarChartData() {
    List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return List.generate(7, (index) {
      String day = days[index];
      double energyValue =
          dailyEnergyData[day] ?? 0.0; // Fetch correct energy value

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: energyValue,
            width: 18,
            color: index == (DateTime.now().weekday % 7)
                ? Colors.orange
                : Colors.amber, // Highlight current day
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        // showingTooltipIndicators: [0],
      );
    });
  }

  Future<void> _loadEnergyLimit() async {
    try {
      _monthlyLimit = await _databaseService.getEnergyLimit();
      _checkEnergyLimit();
      notifyListeners();
    } catch (e) {
      setError(e);
    }
  }

  Future<void> updateMonthlyLimit(double newLimit) async {
    try {
      await _databaseService.setEnergyLimit(newLimit);
      _monthlyLimit = newLimit;
      _checkEnergyLimit();
      notifyListeners();
    } catch (e) {
      setError(e);
    }
  }

  void _checkEnergyLimit() async {
    if (isOverLimit() && !_isAlertShowing) {
      _isAlertShowing = true;
      await _playBeepSound();

      // Show SnackBar using SnackbarService
      _snackbarService.showSnackbar(
        message: 'You have reached your energy usage limit!!',
        title: 'Current Monthly Usage: ${_deviceData?.energy.toStringAsFixed(2)} kWh',
        // duration: Duration(seconds: 5), // Adjust the duration as needed
      );

      // Add a notification using NotificationViewModel
      _notificationViewModel.addNotification(
        'You have reached your energy usage limit!!',
        'Current Monthly Usage: ${_deviceData?.energy.toStringAsFixed(2)} kWh',
      );

      notifyListeners();
    } else if (!isOverLimit()) {
      _isAlertShowing = false;
    }
  }

  Future<void> _playBeepSound() async {
    try {
      await _audioPlayer.play(AssetSource('beep.mp3'));
    } catch (e) {
      print("Error playing beep sound: $e");
    }
  }

  void dismissAlert() {
    _isAlertDismissed = true;
    notifyListeners();
  }

  int? _lastUpdatedDay;
  void _startMonitoring() {
    _deviceMonitorSubscription =
        _databaseService.monitorDeviceChanges(dbCode).listen((_) async {
      await _fetchDeviceData();
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchDeviceData();
    });
  }

  bool isOverLimit() {
    return _deviceData != null &&
        _monthlyLimit > 0 &&
        _deviceData!.energy > _monthlyLimit;
  }

  double getUsagePercentage() {
    return (_deviceData == null || _monthlyLimit <= 0)
        ? 0.0
        : (_deviceData!.energy / _monthlyLimit) * 100;
  }

  // Format values for display
  String formatVoltage() => _deviceData?.voltage.toStringAsFixed(2) ?? '0.00';
  String formatCurrent() => _deviceData?.current.toStringAsFixed(2) ?? '0.00';
  String formatPower() => _deviceData?.power.toStringAsFixed(2) ?? '0.00';
  String formatEnergy() => _deviceData?.energy.toStringAsFixed(2) ?? '0.00';

  void toggleAIMonitoring() async {
    isAIMonitoringEnabled = !isAIMonitoringEnabled;
    notifyListeners();

    if (isAIMonitoringEnabled) {
      await _databaseService
          .saveMonthForAIMonitoring(_getMonthName(DateTime.now().month));

      _resultTimer = Timer(const Duration(seconds: 5), () async {
        final result = await _databaseService.getAIMonitoringResult();
        debugPrint('AI Monitoring Result: $result'); // ✅ Debugging log

        aiPrediction = result?.toString() ?? 'No prediction available';
        notifyListeners();
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _energyUpdateSubscription?.cancel();
    _deviceMonitorSubscription?.cancel();
    _refreshTimer?.cancel();
    _resultTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
