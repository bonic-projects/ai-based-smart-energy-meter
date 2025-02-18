import 'package:stacked/stacked.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewModel extends BaseViewModel {
  String _name = '';
  String _email = '';

  String get name => _name;
  String get email => _email;

  // Load saved data from SharedPreferences
  Future<void> loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name') ?? '';
    _email = prefs.getString('email') ?? '';
    notifyListeners(); // Notify the UI to update
  }

  // Save data to SharedPreferences
  Future<void> saveData(String name, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    _name = name;
    _email = email;
    notifyListeners(); // Notify the UI to update
  }
}
