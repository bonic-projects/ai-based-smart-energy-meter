class DeviceData {
  // String name;
  double totalUsage;
  double voltage;
  double current;
  double power;
  double energy;
  double cost;
  bool isOn;
  bool reset;
  DeviceData({
    // required this.name,
    required this.totalUsage,
    required this.isOn,
    this.voltage = 0,
    this.current = 0,
    this.power = 0,
    this.energy = 0,
    this.cost = 0,
    this.reset = false,
  });
}
