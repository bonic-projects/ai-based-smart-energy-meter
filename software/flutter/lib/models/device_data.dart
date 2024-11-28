import 'dart:core';

class DeviceReading {
  double cost;
  double current;
  double energy;
  double power;
  DateTime timestamp;
  double voltage;

  DeviceReading(
      {required this.cost,
      required this.current,
      required this.power,
      required this.energy,
      required this.timestamp,
      required this.voltage});

  factory DeviceReading.fromMap(Map data) {
    return DeviceReading(
      cost: data['cost'] != null ? data['cost'].toDouble() : 0.0,
      current: data['current'] != null ? data['current'].toDouble() : 0.0,
      power: data['power'] != null ? data['power'].toDouble() : 0.0,
      energy: data['energy'] != null ? data['energy'].toDouble() : 0.0,
      voltage: data['voltage'] != null ? data['voltage'].toDouble() : 0.0,
      timestamp: data['timestamp'] != null
          ? DateTime.tryParse(data['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}


