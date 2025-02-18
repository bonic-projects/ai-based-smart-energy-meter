// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:stacked/stacked.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../models/smart_device.dart';
// import '../../../services/device_service.dart';
//
// class DeviceViewModel extends StreamViewModel<List<DeviceData>> {
//   final DeviceService _deviceService;
//   List<DeviceData> _devices = [];
//   List<bool> isButtonToggled = [false, false, false]; // One for each device
//   bool _isUserToggling = false; // Flag to track user-initiated toggles
//
//   DeviceViewModel(this._deviceService) {
//     _loadLimits();
//   }
//
//   List<DeviceData> get devices => _devices;
//   List<double> _limits = [0.0, 0.0, 0.0]; // One for each device
//   double _peakConsumption = 0.0;
//   bool _showPeakAlert = false;
//   bool _showAlert = false;
//   bool alertShown = false;
//
//   double getLimit(int index) => _limits[index];
//   double get peakConsumption => _peakConsumption;
//   bool get showPeakAlert => _showPeakAlert;
//   bool get showAlert => _showAlert;
//
//   @override
//   Stream<List<DeviceData>> get stream {
//     return Rx.combineLatest3(
//       _deviceService.getDevice1Data(),
//       _deviceService.getDevice2Data(),
//       _deviceService.getDevice3Data(),
//           (device1, device2, device3) {
//         _devices = [device1, device2, device3];
//
//         // Calculate total energy and check consumption
//         double totalEnergy =
//         _devices.fold(0, (sum, device) => sum + device.energy);
//         calculatePeakConsumption();
//         checkEnergyConsumption(totalEnergy);
//
//         // Sync local states with RDB states when hardware updates
//         if (!_isUserToggling) {
//           for (int i = 0; i < _devices.length; i++) {
//             isButtonToggled[i] = _devices[i].isOn;
//           }
//         }
//
//         return _devices;
//       },
//     );
//   }
//
//   Future<void> toggleDeviceState(int index) async {
//     if (index >= 0 && index < _devices.length) {
//       // Toggle the local state
//       isButtonToggled[index] = !_devices[index].isOn;
//       _devices[index].isOn = isButtonToggled[index];
//
//       // Get the correct device ID based on index
//       String deviceId;
//       switch (index) {
//         case 0:
//           deviceId = _deviceService.deviceId;
//           break;
//         case 1:
//           deviceId = _deviceService.deviceId2;
//           break;
//         case 2:
//           deviceId = _deviceService.deviceId3;
//           break;
//         default:
//           throw Exception('Invalid device index');
//       }
//
//       // Update the RDB asynchronously
//       await _deviceService.updateDeviceState(deviceId, _devices[index].isOn);
//
//       calculatePeakConsumption();
//       notifyListeners();
//     }
//   }
//
//   void onDeviceStateUpdatedFromHardware(int deviceIndex, bool isOn) {
//     if (!_isUserToggling) {
//       _devices[deviceIndex].isOn = isOn;
//       isButtonToggled[deviceIndex] = isOn;
//       notifyListeners();
//     }
//   }
//
//   Future<void> _loadLimits() async {
//     final prefs = await SharedPreferences.getInstance();
//     _limits[0] = prefs.getDouble('energyLimit_0') ?? 0.0;
//     _limits[1] = prefs.getDouble('energyLimit_1') ?? 0.0;
//     _limits[2] = prefs.getDouble('energyLimit_2') ?? 0.0;
//     notifyListeners();
//   }
//
//   Future<void> setLimit(int index, double limit) async {
//     if (index >= 0 && index < _limits.length) {
//       _limits[index] = limit;
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setDouble('energyLimit_$index', limit);
//       notifyListeners();
//     }
//   }
//
//   void checkEnergyConsumption(double currentEnergy) {
//     for (int i = 0; i < _devices.length; i++) {
//       if (_devices[i].energy > _limits[i]) {
//         _showAlert = true;
//         break;
//       } else {
//         _showAlert = false;
//       }
//     }
//     notifyListeners();
//   }
//
//   void dismissAlert() {
//     _showAlert = false;
//     notifyListeners();
//   }
//
//   Future<void> saveDeviceName(int index, String name) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('deviceName_$index', name);
//     notifyListeners();
//   }
//
//   Future<String> getDeviceName(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('deviceName_$index') ?? 'Device ${index + 1}';
//   }
//
//   void calculatePeakConsumption() {
//     final now = DateTime.now();
//     bool isPeakHour = now.hour >= 18 && now.hour < 22;
//
//     if (isPeakHour) {
//       bool isAnyDeviceOn = _devices.any((device) => device.isOn);
//
//       if (isAnyDeviceOn && !alertShown) {
//         _showPeakAlert = true;
//         alertShown = true;
//       } else if (!isAnyDeviceOn) {
//         _showPeakAlert = false;
//       }
//     } else {
//       _showPeakAlert = false;
//       alertShown = false; // Reset alert flag outside peak hours
//     }
//
//     notifyListeners();
//   }
//
//   Future<void> resetDevice(int index) async {
//     if (index >= 0 && index < _devices.length) {
//       // Get the device UID
//       final deviceId = _getDeviceId(index);
//
//       // Update the reset state to true
//       _devices[index].reset = true;
//       await _deviceService.updateResetState(deviceId, true);
//       notifyListeners();
//
//       // Revert the reset state to false after 3 seconds
//       await Future.delayed(Duration(seconds: 3));
//       _devices[index].reset = false;
//       await _deviceService.updateResetState(deviceId, false);
//       notifyListeners();
//     }
//   }
//
//   String _getDeviceId(int index) {
//     switch (index) {
//       case 0:
//         return _deviceService.deviceId;
//       case 1:
//         return _deviceService.deviceId2;
//       case 2:
//         return _deviceService.deviceId3;
//       default:
//         throw Exception('Invalid device index');
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stacked/stacked.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/smart_device.dart';
import '../../../services/device_service.dart';
import '../notification/notification_viewmodel.dart';

class DeviceViewModel extends StreamViewModel<List<DeviceData>> {
  final DeviceService _deviceService;
  final NotificationViewModel _notificationViewModel;
  List<DeviceData> _devices = [];
  // List<bool> isButtonToggled = [false, false, false]; // One for each device
  List<bool> _uiButtonStates = [false, false, false];
  List<bool> _userControlled = [false, false, false];
  DeviceViewModel(this._deviceService,this._notificationViewModel) {
    _loadLimits();
  }

  List<DeviceData> get devices => _devices;
  List<double> _limits = [0.0, 0.0, 0.0]; // One for each device
  double _peakConsumption = 0.0;
  bool _showPeakAlert = false;
  bool _showAlert = false;
  bool alertShown = false;

  bool getButtonState(int index) => _uiButtonStates[index];
  double getLimit(int index) => _limits[index];
  double get peakConsumption => _peakConsumption;
  bool get showPeakAlert => _showPeakAlert;
  bool get showAlert => _showAlert;

  @override
  Stream<List<DeviceData>> get stream {
    return Rx.combineLatest3(
      _deviceService.getDevice1Data(),
      _deviceService.getDevice2Data(),
      _deviceService.getDevice3Data(),
      (device1, device2, device3) {
        _devices = [device1, device2, device3];

        // Calculate total energy and check consumption
        double totalEnergy =
            _devices.fold(0, (sum, device) => sum + device.energy);
        calculatePeakConsumption();
        checkEnergyConsumption(totalEnergy);

        // // Sync local states with RDB states when hardware updates
        // for (int i = 0; i < _devices.length; i++) {
        //   if (!isButtonToggled[i]) {
        //     isButtonToggled[i] = _devices[i].isOn;
        //   }
        // }
        for (int i = 0; i < _devices.length; i++) {
          if (!_userControlled[i]) {
            _uiButtonStates[i] = _devices[i].isOn;
          }
        }
        return _devices;
      },
    );
  }

  Future<void> toggleDeviceState(int index) async {
    if (index >= 0 && index < _devices.length) {
      try {
        // Toggle UI state immediately
        _uiButtonStates[index] = !_uiButtonStates[index];
        // Mark this device as under user control
        _userControlled[index] = true;
        notifyListeners();

        // Get the correct device ID
        String deviceId = _getDeviceId(index);

        // Update RDB with new state
        await _deviceService.updateDeviceState(
            deviceId, _uiButtonStates[index]);

        // Update local device state but maintain user control
        _devices[index].isOn = _uiButtonStates[index];
        calculatePeakConsumption();
      } catch (e) {
        // Revert UI state if update fails
        _uiButtonStates[index] = !_uiButtonStates[index];
        _userControlled[index] = false;
        notifyListeners();
        throw Exception('Failed to update device state: $e');
      }
    }
  }

  void releaseUserControl(int index) {
    if (index >= 0 && index < _devices.length) {
      _userControlled[index] = false;
      _uiButtonStates[index] = _devices[index].isOn;
      notifyListeners();
    }
  }

  void onDeviceStateUpdatedFromHardware(int deviceIndex, bool isOn) {
    if (deviceIndex >= 0 && deviceIndex < _devices.length) {
      _devices[deviceIndex].isOn = isOn;
      _uiButtonStates[deviceIndex] = isOn;
      notifyListeners();
    }
  }

  Future<void> _loadLimits() async {
    final prefs = await SharedPreferences.getInstance();
    _limits[0] = prefs.getDouble('energyLimit_0') ?? 0.0;
    _limits[1] = prefs.getDouble('energyLimit_1') ?? 0.0;
    _limits[2] = prefs.getDouble('energyLimit_2') ?? 0.0;
    notifyListeners();
  }

  Future<void> setLimit(int index, double limit) async {
    if (index >= 0 && index < _limits.length) {
      _limits[index] = limit;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('energyLimit_$index', limit);
      notifyListeners();
    }
  }

  void checkEnergyConsumption(double currentEnergy) async{
    for (int i = 0; i < _devices.length; i++) {
      if (_devices[i].energy > _limits[i]) {
        _showAlert = true;
        final deviceName = await getDeviceName(i);
        _notificationViewModel.addNotification(
          '$deviceName exceeds the energy usage limit!!',
          'Current Usage: ${_devices[i]?.energy.toStringAsFixed(2)} kWh',
        );
        break;
      } else {
        _showAlert = false;
      }
    }
    notifyListeners();
  }

  void dismissAlert() {
    _showAlert = false;
    notifyListeners();
  }

  Future<void> saveDeviceName(int index, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceName_$index', name);
    notifyListeners();
  }

  Future<String> getDeviceName(int index) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('deviceName_$index') ?? 'Device ${index + 1}';
  }

  void calculatePeakConsumption() {
    final now = DateTime.now();
    bool isPeakHour = now.hour >= 18 && now.hour < 22;

    if (isPeakHour) {
      bool isAnyDeviceOn = _devices.any((device) => device.isOn);

      if (isAnyDeviceOn && !alertShown) {
        _showPeakAlert = true;
        alertShown = true;

      } else if (!isAnyDeviceOn) {
        _showPeakAlert = false;
      }
    } else {
      _showPeakAlert = false;
      alertShown = false; // Reset alert flag outside peak hours
    }

    notifyListeners();
  }

  Future<void> resetDevice(int index) async {
    if (index >= 0 && index < _devices.length) {
      // Get the device UID
      final deviceId = _getDeviceId(index);

      // Update the reset state to true
      _devices[index].reset = true;
      await _deviceService.updateResetState(deviceId, true);
      notifyListeners();

      // Revert the reset state to false after 3 seconds
      await Future.delayed(Duration(seconds: 3));
      _devices[index].reset = false;
      await _deviceService.updateResetState(deviceId, false);
      notifyListeners();
    }
  }

  String _getDeviceId(int index) {
    switch (index) {
      case 0:
        return _deviceService.deviceId;
      case 1:
        return _deviceService.deviceId2;
      case 2:
        return _deviceService.deviceId3;
      default:
        throw Exception('Invalid device index');
    }
  }
}

// class DeviceViewModel extends StreamViewModel<List<DeviceData>> {
//   final DeviceService _deviceService;
//   bool _isDeviceOn = false;
//   List<DeviceData> _devices = [];
//   bool isButtonToggled = false;
//   DeviceViewModel(this._deviceService) {
//     _loadLimit();
//   }
//
//   List<DeviceData> get devices => _devices;
//   bool get isDeviceOn => _isDeviceOn;
//   double _limit = 0.0;
//   double _peakConsumption = 0.0;
//   bool _showPeakAlert = false;
//   bool _showAlert = false;
//   bool alertShown = false;
//
//   double get limit => _limit;
//   double get peakConsumption => _peakConsumption;
//   bool get showPeakAlert => _showPeakAlert;
//   bool get showAlert => _showAlert;
//
//   @override
//   Stream<List<DeviceData>> get stream {
//     return _deviceService.getDevice1Data().map((device1) {
//       _devices = [device1];
//       calculatePeakConsumption();
//       checkEnergyConsumption(device1.energy);
//
//       // Sync local state with RDB state when hardware updates
//       if (!isButtonToggled) {
//         isButtonToggled = device1.isOn;
//       }
//
//       return _devices;
//     });
//   }
//
//   Future<void> toggleDeviceState(int index) async {
//     if (index >= 0 && index < _devices.length) {
//       // Toggle the local state
//       isButtonToggled = !_devices[index].isOn;
//       _devices[index].isOn = isButtonToggled;
//
//       // Update the RDB asynchronously
//       await _deviceService.updateDeviceState(_deviceService.deviceId, _devices[index].isOn);
//
//       calculatePeakConsumption();
//       notifyListeners(); // Update the UI
//     }
//   }
//
//   // Add a method to handle RDB updates from the hardware
//   void onDeviceStateUpdatedFromHardware(bool isOn) {
//     if (!isButtonToggled) { // Only update if the user hasn't toggled the button
//       _devices[0].isOn = isOn; // Assuming you're dealing with a single device
//       notifyListeners();
//     }
//   }
//
//   Future<void> _loadLimit() async {
//     final prefs = await SharedPreferences.getInstance();
//     _limit = prefs.getDouble('energyLimit') ?? 0.0;
//     notifyListeners();
//   }
//
//   Future<void> setLimit(double limit) async {
//     _limit = limit;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('energyLimit', limit);
//     notifyListeners();
//   }
//
//   void checkEnergyConsumption(double currentEnergy) {
//     print('Current Energy: $currentEnergy, Limit: $_limit');
//     if (currentEnergy > _limit) {
//       _showAlert = true;
//       notifyListeners();
//     } else {
//       _showAlert = false;
//       notifyListeners();
//     }
//   }
//
//   void dismissAlert() {
//     _showAlert = false;
//     notifyListeners();
//   }
//
//   Future<void> saveDeviceName(int index, String name) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('deviceName_$index', name);
//     notifyListeners();
//   }
//
//   Future<String> getDeviceName(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('deviceName_$index') ?? 'Device ${index + 1}';
//   }
//
//   void calculatePeakConsumption() {
//     final now = DateTime.now();
//     bool isPeakHour = now.hour >= 18 && now.hour < 22; // Check if current time is between 6 PM and 10 PM
//
//     if (isPeakHour) {
//       bool isAnyDeviceOn = _devices.any((device) => device.isOn); // Check if any device is ON
//
//       if (isAnyDeviceOn && !alertShown) {
//         _showPeakAlert = true; // Show alert if any device is ON during peak hours
//         alertShown = true; // Prevent repeated alerts
//       } else if (!isAnyDeviceOn) {
//         _showPeakAlert = false; // Hide alert if no devices are ON
//       }
//     } else {
//       _showPeakAlert = false; // Hide alert outside peak hours
//     }
//
//     notifyListeners(); // Update the UI
//   }
//
// }

// class DeviceViewModel extends StreamViewModel<List<DeviceData>> {
//   final DeviceService _deviceService;
//
//   DeviceViewModel(this._deviceService);
//
//   @override
//   Stream<List<DeviceData>> get stream {
//     return Rx.combineLatest3<DeviceData, DeviceData, DeviceData, List<DeviceData>>(
//       _deviceService.getDevice1Data(),
//       _deviceService.getDevice2Data(),
//       _deviceService.getDevice3Data(),
//          (device1,
//          device2,
//          device3) =>
//         [device1, device2, device3],
//     );
//   }
//
//   Future<void> toggleDevice(int index) async {
//     String deviceId;
//     switch(index) {
//       case 0:
//         deviceId = _deviceService.deviceId;
//         break;
//       case 1:
//         deviceId = _deviceService.deviceId2;
//         break;
//       case 2:
//         deviceId = _deviceService.deviceId3;
//         break;
//       default:
//         return;
//     }
//
//     if (data != null && index < data!.length) {
//       await _deviceService.updateDeviceState(deviceId, !data![index].isOn);
//       notifyListeners();
//     }
//   }
//
//   Future<void> updateDeviceName(int index, String newName) async {
//     String deviceId;
//     switch(index) {
//       case 0:
//         deviceId = _deviceService.deviceId;
//         break;
//       case 1:
//         deviceId = _deviceService.deviceId2;
//         break;
//       case 2:
//         deviceId = _deviceService.deviceId3;
//         break;
//       default:
//         return;
//     }
//
//     await _deviceService.updateDeviceName(deviceId, newName);
//     notifyListeners();
//   }
// }
