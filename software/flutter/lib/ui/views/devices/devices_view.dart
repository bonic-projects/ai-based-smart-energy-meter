import 'package:ai_based_smart_energy_meter/ui/components/topenergy_alert.dart';
import 'package:ai_based_smart_energy_meter/ui/views/notification/notification_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:ai_based_smart_energy_meter/ui/views/devices/devices_viewmodel.dart';

import '../../../services/device_service.dart';

class DevicesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeviceViewModel>.reactive(
      viewModelBuilder: () => DeviceViewModel(DeviceService(),NotificationViewModel()),
      builder: (context, model, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget>[
                // Peak Hour Alert Banner (Only visible during peak hours when any device is ON)
                if (model.showPeakAlert)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    color: Colors.red.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Devices are running during peak hours!',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                // Energy Limit Exceeded Alert
                if (model.showAlert)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    color: Colors.orange.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'Energy limit exceeded!',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => model.dismissAlert(),
                          child: Text('Dismiss'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 80),
                    itemCount: model.devices.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<String?>(
                        future: model.getDeviceName(index),
                        builder: (context, snapshot) {
                          final device = model.devices[index];
                          final customName =
                              snapshot.data; // Custom name (null if not set)
                          final defaultName =
                              'DEVICE ${index + 1}'; // Default name
                          final deviceName = customName ?? defaultName;

                          return Card(
                            color: Color(0xFFC8DBFF),
                            margin: EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        defaultName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Limit: ${model.getLimit(index)} kWh',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () => _showEditDialog(
                                            context, model, index),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    deviceName,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () =>
                                              model.toggleDeviceState(index),
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder()),
                                          child: Text(
                                            model.getButtonState(index)
                                                ? 'Turn Off'
                                                : 'Turn On',
                                            style: TextStyle(
                                                color: Color(0XFFA10000)),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => _showSetLimitDialog(
                                              context, model, index),
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder()),
                                          child: Text(
                                            'Set Limit',
                                            style: TextStyle(
                                                color: Color(0XFFA10000)),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              model.resetDevice(index),
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder()),
                                          child: Text(
                                            'Reset',
                                            style: TextStyle(
                                                color: Color(0XFFA10000)),
                                          ),
                                        )
                                        // SizedBox(width: 8),
                                        // Text(
                                        //   'Set Limit: ${model.getLimit(index)} kWh',
                                        //   style: TextStyle(
                                        //     fontSize: 16,
                                        //     fontWeight: FontWeight.bold,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  GridView.count(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.8,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    children: [
                                      _buildMetricItem(
                                        'Voltage',
                                        '${device.voltage.toStringAsFixed(2)}V',
                                      ),
                                      _buildMetricItem(
                                        'Current',
                                        '${device.current.toStringAsFixed(2)}A',
                                      ),
                                      _buildMetricItem(
                                        'Power',
                                        '${device.power.toStringAsFixed(2)}W',
                                      ),
                                      _buildMetricItem(
                                        'Energy',
                                        '${device.energy.toStringAsFixed(2)}kWh',
                                      ),
                                      _buildMetricItem(
                                        'Cost',
                                        '\$${device.cost.toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade500),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, DeviceViewModel model, int index) async {
    final savedName = await model.getDeviceName(index);
    final controller = TextEditingController(text: savedName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Device Name'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await model.saveDeviceName(index, controller.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSetLimitDialog(
      BuildContext context, DeviceViewModel model, int index) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Limit for Device ${index + 1}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter limit'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final limit = double.tryParse(controller.text) ?? 0.0;
                await model.setLimit(
                    index, limit); // Set limit for the specific device
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
