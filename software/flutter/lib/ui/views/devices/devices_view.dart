import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'devices_viewmodel.dart';

class DevicesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeviceViewModel>.reactive(
      viewModelBuilder: () => DeviceViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.black12,
          appBar: AppBar(
            backgroundColor: Colors.yellow,
            title: Text('Devices'),
          ),
          body: StreamBuilder(
            stream: model.devicesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

              final devices = snapshot.data!.docs;

              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final deviceId = device.id;
                  return Card(
                    color: Colors.black12,
                    child: ListTile(
                      title: Text(
                        device['name'],
                        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Total Usage: ${device['totalUsage']} kWh',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: device['isMonitoring']
                                ? null
                                : () => _showMonitoringDialog(context, model, deviceId, device),
                            child: Text(device['isMonitoring'] ? 'Monitoring...' : 'Start Monitoring'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black12,
                              side: BorderSide(color: Colors.white38),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => model.resetUsage(deviceId),
                            child: Text('Reset'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black12,
                              side: BorderSide(color: Colors.white38),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddDeviceDialog(context, model);
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showMonitoringDialog(BuildContext context, DeviceViewModel model, String deviceId, dynamic device) {
    final currentUsageController = ValueNotifier<double>(0.0);

    final energyRef = FirebaseDatabase.instance.ref().child('devices/$deviceId/reading/energy');
    energyRef.onValue.listen((event) {
      final currentValue = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      final beforeValue = (device['beforeValue'] as num?)?.toDouble() ?? 0.0;
      currentUsageController.value = currentValue - beforeValue;
    });

    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<double>(
          valueListenable: currentUsageController,
          builder: (context, currentUsage, child) {
            return AlertDialog(
              title: Text('${device['name']} Monitoring'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Before kWh Value: ${device['beforeValue']}'),
                  Text('Current Usage: ${currentUsage.toStringAsFixed(2)} kWh'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    model.endMonitoring(deviceId);
                    Navigator.of(context).pop();
                  },
                  child: Text('End Monitoring'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDeviceDialog(BuildContext context, DeviceViewModel model) {
    final TextEditingController deviceNameController = TextEditingController();
    final TextEditingController deviceIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deviceNameController,
                decoration: InputDecoration(labelText: 'Device Name'),
              ),
              TextField(
                controller: deviceIdController,
                decoration: InputDecoration(labelText: 'Device ID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                model.addDevice(
                  deviceNameController.text.trim(),
                  deviceIdController.text.trim(),
                );
                deviceNameController.clear();
                deviceIdController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
