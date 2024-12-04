import 'package:ai_based_smart_energy_meter/app/app.logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import '../../../services/firebase_service.dart';

class PredictViewModel extends BaseViewModel {
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController kidsController = TextEditingController();
  final TextEditingController adultsController = TextEditingController();
 // final log=getLogger('PredictViewModel');
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;
  double? _prediction;

  bool get isLoading => _isLoading;
  double? get prediction => _prediction;

  // Sets the selected month
  void setMonth(DateTime date) {
    monthController.text = DateFormat.MMMM().format(date);
    notifyListeners();
  }

  // Sets the selected year
  void setYear(DateTime date) {
    yearController.text = DateFormat.y().format(date);
    notifyListeners();
  }

  // Save the prediction data
  Future<void> savePrediction() async {
    if (monthController.text.isEmpty ||
        yearController.text.isEmpty ||
        kidsController.text.isEmpty ||
        adultsController.text.isEmpty) {
      // log.i("Validation failed. All fields are required.");
      // print("Validation failed. All fields are required.");
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final data = {
        'month': monthController.text,
        'year': yearController.text,
        'kids': kidsController.text,
        'adults': adultsController.text,
      };

      await _firebaseService.savePredictionWithoutUid(data);

      // Clear fields after saving
      monthController.clear();
      yearController.clear();
      kidsController.clear();
      adultsController.clear();

      // log.i("Data saved successfully!");
      // print("Data saved successfully!");

      // Fetch prediction after saving
      const dbCode = "i6v29xWLkNNXWfGjta1jh3z336j2";
      _prediction = await _firebaseService.fetchPrediction(dbCode);
      // log.i("Fetched prediction: $_prediction");
      // print("Fetched prediction: $_prediction");
    } catch (e) {
      // log.e("Error saving prediction: $e");
      // print("Error saving prediction: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
