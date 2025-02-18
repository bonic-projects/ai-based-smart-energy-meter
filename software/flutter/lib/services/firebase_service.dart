import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Save prediction without user ID
  Future<void> savePredictionWithoutUid(Map<String, dynamic> data) async {
    try {
      await _dbRef
          .child('devices')
          .child('i6v29xWLkNNXWfGjta1jh3z336j2')
          .child('predictions')
          .set(data);
      print("Prediction saved successfully.");
    } catch (e) {
      print("Error saving prediction: $e");
    }
  }

  Future<double?> fetchPrediction(String dbCode) async {
    try {
      await Future.delayed(Duration(seconds: 5));
      final predictionRef =
          _dbRef.child('devices').child(dbCode).child('predictions_result');
      final snapshot = await predictionRef.get();

      if (snapshot.exists) {
        final value = snapshot.value;

        if (value is Map) {
          // Access the 'result' field in the map
          final result = value['result'];

          if (result is double) {
            return result; // Return directly if already a double
          } else if (result is int) {
            return result.toDouble(); // Convert int to double
          } else if (result is String) {
            return double.tryParse(result); // Attempt parsing if a string
          } else {
            print(
                "Unexpected type for result in predictions_result: $result (${result.runtimeType})");
          }
        } else {
          print(
              "Unexpected type for predictions_result: $value (${value.runtimeType})");
        }
      } else {
        print("No predictions_result found at /devices/$dbCode.");
      }
    } catch (e) {
      print(
          "Error fetching prediction from /devices/$dbCode/predictions_result: $e");
    }
    return null; // Return null if no valid value is found
  }

  Stream<double> getRealTimeCost() {
    final costRef = _dbRef.child('devices/i6v29xWLkNNXWfGjta1jh3z336j2/reading/cost');
    return costRef.onValue.map((event) {
      final cost = event.snapshot.value;
      if (cost != null && cost is num) {
        return cost.toDouble(); // Ensure it's a double
      }
      return 0.0; // Default to 0 if no cost value exists
    });
  }

  // Future<Map<dynamic, dynamic>?> fetchMonthlyCosts(String yearMonth) async {
  //   try {
  //     final ref = FirebaseDatabase.instance
  //         .ref()
  //         .child('electricity_costs')
  //         .child(yearMonth);
  //
  //     final snapshot = await ref.get();
  //
  //     if (snapshot.exists) {
  //       return snapshot.value as Map<dynamic, dynamic>;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Error fetching monthly costs: $e");
  //     return null;
  //   }
  // }
  //
  // void saveDailyCost(double dailyCost) async {
  //   final now = DateTime.now();
  //   final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  //   final day = 'day${now.day}';
  //
  //   try {
  //     final ref = FirebaseDatabase.instance
  //         .ref()
  //         .child('electricity_costs')
  //         .child(yearMonth)
  //         .child(day);
  //
  //     await ref.set(dailyCost);
  //     print("Daily cost saved: $dailyCost");
  //   } catch (e) {
  //     print("Error saving daily cost: $e");
  //   }
  // }

  Future<double> getLatestEnergyValue() async {
    final snapshot = await _dbRef
        .child("devices/i6v29xWLkNNXWfGjta1jh3z336j2/reading/energy")
        .get();
    print("energyvalue:$snapshot");
    return snapshot.exists ? (snapshot.value as num).toDouble() : 0.0;
  }

  // 🔹 Store Monthly Energy Consumption in Firebase
  Future<void> storeMonthlyEnergy(double value) async {
    DateTime now = DateTime.now();
    String currentMonth =
        "${now.year}-${now.month.toString().padLeft(2, '0')}"; // Format: "2025-02"
    await _dbRef
        .child(
            "devices/i6v29xWLkNNXWfGjta1jh3z336j2/monthly_energy/$currentMonth")
        .set(value);
    print("current month:$currentMonth");
  }

  // 🔹 Fetch Monthly Energy Data from Firebase
  Future<Map<String, double>> getMonthlyEnergyData() async {
    final snapshot = await _dbRef
        .child("devices/i6v29xWLkNNXWfGjta1jh3z336j2/monthly_energy")
        .get();

    if (snapshot.exists && snapshot.value != null) {
      Map<String, double> data = {};
      (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
        data[key.toString()] = (value as num).toDouble();
      });
      return data;
    }
    return {};
  }

  // 🔹 Calculate and Store Monthly Energy
  Future<void> calculateAndStoreMonthlyEnergy() async {
    DateTime now = DateTime.now();
    String currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    String lastMonth =
        "${now.year}-${(now.month - 1).toString().padLeft(2, '0')}";

    // Fetch last month's cumulative energy
    final lastMonthSnapshot = await _dbRef
        .child("devices/i6v29xWLkNNXWfGjta1jh3z336j2/monthly_energy/$lastMonth")
        .get();
    double lastMonthCumulativeEnergy = lastMonthSnapshot.exists
        ? (lastMonthSnapshot.value as num).toDouble()
        : 0.0;

    // Get the latest energy value from the energy meter
    double latestEnergy = await getLatestEnergyValue();

    // Debug: Print fetched values
    print("Last Month: $lastMonth -> Cumulative Energy: $lastMonthCumulativeEnergy");
    print("Current Month: $currentMonth -> Latest Energy: $latestEnergy");

    // Fetch the existing cumulative energy for the current month (if any)
    final currentMonthSnapshot = await _dbRef
        .child("devices/i6v29xWLkNNXWfGjta1jh3z336j2/monthly_energy/$currentMonth")
        .get();
    double existingCurrentMonthEnergy = currentMonthSnapshot.exists
        ? (currentMonthSnapshot.value as num).toDouble()
        : 0.0;

    // Fetch the last recorded energy value for the current month
    final lastRecordedEnergySnapshot = await _dbRef
        .child("devices/i6v29xWLkNNXWfGjta1jh3z336j2/last_recorded_energy/$currentMonth")
        .get();
    double lastRecordedEnergy = lastRecordedEnergySnapshot.exists
        ? (lastRecordedEnergySnapshot.value as num).toDouble()
        : 0.0;

    // Check if the energy meter value has changed
    if (latestEnergy != lastRecordedEnergy) {
      // Calculate the current month's cumulative energy
      double currentMonthCumulativeEnergy;
      if (latestEnergy >= lastMonthCumulativeEnergy) {
        // Normal case: No reset, calculate the difference
        currentMonthCumulativeEnergy = latestEnergy - lastMonthCumulativeEnergy;
      } else {
        // Reset detected: Assume the latestEnergy is the new starting point
        currentMonthCumulativeEnergy = latestEnergy;
      }

      // Add the new consumption to the existing cumulative energy for the current month
      double updatedCumulativeEnergy =
          existingCurrentMonthEnergy + currentMonthCumulativeEnergy;

      // Store the updated cumulative energy in Firebase
      await _dbRef
          .child(
          "devices/i6v29xWLkNNXWfGjta1jh3z336j2/monthly_energy/$currentMonth")
          .set(updatedCumulativeEnergy);
      print("Stored $updatedCumulativeEnergy for $currentMonth in Firebase");

      // Update the last recorded energy value for the current month
      await _dbRef
          .child(
          "devices/i6v29xWLkNNXWfGjta1jh3z336j2/last_recorded_energy/$currentMonth")
          .set(latestEnergy);
      print("Updated last recorded energy for $currentMonth to $latestEnergy");
    } else {
      print("No change in energy value. Skipping update.");
    }
  }
}
