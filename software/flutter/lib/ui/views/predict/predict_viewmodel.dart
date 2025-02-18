import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import '../../../services/firebase_service.dart';

class PredictionViewModel extends BaseViewModel {
  final TextEditingController yearController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController inmatesController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, double> _monthlyEnergyData = {};
  Map<String, double> get monthlyEnergyData => _monthlyEnergyData;
  StreamSubscription? _energyReadingSubscription;
  bool _isLoading = false;
  double? _prediction;
  bool get isLoading => _isLoading;
  double? get prediction => _prediction;
  int currentIndex = 1; // For bottom navigation
  bool hasNotifications = true;
  String lastMonthCharge = '';
  double totalMonthlyCost = 0.0; // Total cost for the current month
  String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  StreamSubscription? _energySubscription;
  StreamSubscription? _monthlyDataSubscription;

  void listenToRealTimeCost() {
    _firebaseService.getRealTimeCost().listen((realTimeCost) {
      // Add the real-time cost to the total for this month
       totalMonthlyCost = realTimeCost;
       print('$realTimeCost');
      notifyListeners();
    });
  }

  Future<void> initializeMonthlyEnergy() async {
    await processMonthlyEnergy(); // Calculate and store
    await fetchMonthlyEnergyData(); // Fetch and update UI
  }

  // void resetMonthlyCost() {
  //   final newMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  //   if (newMonth != currentMonth) {
  //     // If a new month starts, reset the total cost
  //     currentMonth = newMonth;
  //     totalMonthlyCost = 0.0;
  //     notifyListeners();
  //   }
  // }
  //
  // void scheduleMonthlyCheck() {
  //   Timer.periodic(const Duration(days: 1), (timer) {
  //     final now = DateTime.now();
  //     final month = now.month;
  //     final year = now.year;
  //
  //     if (month.toString() != monthController.text) {
  //       calculateMonthlyCost(); // Fetch new data for the new month
  //     }
  //   });
  // }
  //
  // Future<void> calculateMonthlyCost() async {
  //   try {
  //     _isLoading = true;
  //     notifyListeners();
  //
  //     // Get the current year and month
  //     final now = DateTime.now();
  //     final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  //
  //     // Fetch data from Firebase
  //     final Map<dynamic, dynamic>? monthlyData =
  //         await _firebaseService.fetchMonthlyCosts(yearMonth);
  //
  //     if (monthlyData != null) {
  //       // Calculate the total cost for the month
  //       double totalCost = 0.0;
  //       monthlyData.forEach((key, value) {
  //         totalCost += value as double;
  //       });
  //
  //       lastMonthCharge = totalCost.toStringAsFixed(2); // Display as a string
  //     } else {
  //       lastMonthCharge = "0.00"; // No data for the month
  //     }
  //
  //     print("Total cost for $yearMonth: $lastMonthCharge");
  //   } catch (e) {
  //     print("Error calculating monthly cost: $e");
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  void onNavigationTap(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future<void> selectYear(BuildContext context) async {
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int? tempYear;
        return AlertDialog(
          title: Text('Select Year'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              itemCount: 100, // Show the last 100 years
              itemBuilder: (BuildContext context, int index) {
                final year = DateTime.now().year - index;
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () {
                    tempYear = year;
                    Navigator.of(context).pop(tempYear);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null) {
      yearController.text = selectedYear.toString();
      notifyListeners();
    }
  }

  Future<void> selectMonth(BuildContext context) async {
    final selectedMonth = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? tempMonth;
        return AlertDialog(
          title: Text('Select Month'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              itemCount: 12,
              itemBuilder: (BuildContext context, int index) {
                final monthName =
                    DateFormat('MMMM').format(DateTime(0, index + 1));
                return ListTile(
                  title: Text(monthName),
                  onTap: () {
                    tempMonth = monthName;
                    Navigator.of(context).pop(tempMonth);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedMonth != null) {
      monthController.text = selectedMonth;
      notifyListeners();
    }
  }

  void onYearChanged(String value) {
    notifyListeners();
  }

  void onMonthChanged(String value) {
    notifyListeners();
  }

  void onInmatesChanged(String value) {
    notifyListeners();
  }

  void onDaysChanged(String value) {
    notifyListeners();
  }

  Future<void> predict() async {
    if (monthController.text.isEmpty ||
        yearController.text.isEmpty ||
        inmatesController.text.isEmpty ||
        daysController.text.isEmpty) {
      print("Validation failed. All fields are required.");
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final data = {
        'month': monthController.text,
        'year': yearController.text,
        'inmates': inmatesController.text,
        'days': daysController.text,
      };

      await _firebaseService.savePredictionWithoutUid(data);

      monthController.clear();
      yearController.clear();
      inmatesController.clear();
      daysController.clear();

      print("Data saved successfully!");

      const dbCode = "i6v29xWLkNNXWfGjta1jh3z336j2";
      _prediction = await _firebaseService.fetchPrediction(dbCode);
      print("Fetched prediction: $_prediction");
    } catch (e) {
      print("Error saving prediction: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyEnergyData() async {
    _isLoading = true;
    notifyListeners();

    _monthlyEnergyData = await _firebaseService.getMonthlyEnergyData();
    print("monthlyenergy:$_monthlyEnergyData");
    _isLoading = false;
    notifyListeners();
  }

  // 🔹 Ensure Monthly Calculation Runs
  Future<void> processMonthlyEnergy() async {
    await _firebaseService.calculateAndStoreMonthlyEnergy();
    await fetchMonthlyEnergyData();
  }

  List<BarChartGroupData> getMonthlyChartData() {
    List<String> months = [
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

    return List.generate(12, (index) {
      String monthKey =
          "${DateTime.now().year}-${(index + 1).toString().padLeft(2, '0')}";

      double energyValue = _monthlyEnergyData[monthKey] ?? 0.0;
      if (energyValue.isNaN || energyValue.isInfinite) {
        energyValue = 0.0; // Prevent crash
      }
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: energyValue,
            width: 18,
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
        ],

        // showingTooltipIndicators: [0],
      );
    });
  }

  String getCurrentYearMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    yearController.dispose();
    monthController.dispose();
    inmatesController.dispose();
    daysController.dispose();
    _energyReadingSubscription?.cancel();
    _monthlyDataSubscription?.cancel();
    super.dispose();
  }
}
