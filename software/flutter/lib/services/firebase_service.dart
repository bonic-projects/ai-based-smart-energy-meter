import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Save prediction without user ID
  Future<void> savePredictionWithoutUid(Map<String, dynamic> data) async {
    try {
      await _dbRef.child('devices').child('i6v29xWLkNNXWfGjta1jh3z336j2').child('predictions').set(data);
      print("Prediction saved successfully.");
    } catch (e) {
      print("Error saving prediction: $e");
    }
  }


  Future<double?> fetchPrediction(String dbCode) async {
    try {
      await Future.delayed(Duration(seconds: 5));
      final predictionRef = _dbRef.child('devices').child(dbCode).child('predictions_result');
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
            print("Unexpected type for result in predictions_result: $result (${result.runtimeType})");
          }
        } else {
          print("Unexpected type for predictions_result: $value (${value.runtimeType})");
        }
      } else {
        print("No predictions_result found at /devices/$dbCode.");
      }
    } catch (e) {
      print("Error fetching prediction from /devices/$dbCode/predictions_result: $e");
    }
    return null; // Return null if no valid value is found
  }

}