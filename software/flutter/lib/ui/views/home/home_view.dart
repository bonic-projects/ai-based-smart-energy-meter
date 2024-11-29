import 'package:ai_based_smart_energy_meter/ui/views/predict/predict_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../components/common_button.dart';
import '../devices/devices_view.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) => model.initialize(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.black12,
          appBar: AppBar(
            backgroundColor: Colors.yellow,
            title:  Row(
              children: [
                Text(
                  'AI Based Smart Energy Meter',
                  style: TextStyle(color: Colors.black),
                ),SizedBox(width: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(model.isOnline ? "Online" : "Offline",
                    //   style: TextStyle(
                    //       color: model.isOnline ? Colors.green : Colors.red,)),
                    Icon(
                      model.isOnline?Icons.wifi:Icons.wifi_off,
                      color: model.isOnline?Colors.green:Colors.red,
                    )
                  ],
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: model.deviceReading == null
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.yellow))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing:
                                16, // Ensures GridView takes minimal space
                            children: [
                              _buildGauge(
                                  title: 'Volt',
                                  value: model.deviceReading!.voltage,
                                  maxValue: 300,
                                  unit: 'V',
                              ),
                              _buildGauge(
                                  title: 'Ampere',
                                  value: model.deviceReading!.current,
                                  maxValue: 300,
                                  unit: 'A'),
                              _buildGauge(
                                  title: 'Watt',
                                  value: model.deviceReading!.power,
                                  maxValue: 1000,
                                  unit: 'W'),
                              _buildGauge(
                                  title: 'Kilowatt',
                                  value: model.deviceReading!.energy,
                                  maxValue: 10,
                                  unit: 'kWh'),
                            ],
                          ),
                        ),
                        Text(
                          "Cost:${model.deviceReading!.cost}",
                          style: const TextStyle(
                              color: Colors.green,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10,),
                        ElevatedButton(onPressed:model.isBusy?null: ()async{
                          await model.resetValue();
                        }, child:  model.isBusy
                            ? const CircularProgressIndicator()
                            : const Text("Reset",),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black12,
                            side: BorderSide(color: Colors.white38)
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 45,
                          width: 200,
                          decoration: BoxDecoration(color: Colors.white24,borderRadius: BorderRadius.circular(10)),
                          child: InkWell(onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>PredictView()));
                          },
                            child: Center(child: Text("Predict",style: TextStyle(fontSize: 20,color: Colors.teal),)),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          height: 45,
                          width: 200,
                          decoration: BoxDecoration(color:Colors.white24,borderRadius: BorderRadius.circular(10)),
                          child: InkWell(onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> DevicesView()));
                          },
                            child: Center(child: Text("Device Monitoring",style: TextStyle(fontSize: 20,color: Colors.teal),)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Usage: ${model.dailyConsumption} kWh',style: TextStyle(
                              color: Colors.blueGrey
                            ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Limit: ${model.energyLimit} kWh',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            CommonButton(
                                text: 'Set Limit',
                                onpress: () async {
                                  _showSetLimitDialog(context, model);
                                }),
                          ],
                        ),

        ])),
        );
      },
    );
  }

  Widget _buildGauge({
    required String title,
    required double value,
    required double maxValue,
    required String unit,
  }) {
    return SfRadialGauge(
      title: GaugeTitle(
        text: '$value $unit',
        textStyle: const TextStyle(color: Colors.green, fontSize: 16),
      ),backgroundColor: Colors.white38,
      axes: [
        RadialAxis(
          minimum: 0,
          maximum: maxValue,
          showLabels: true,
          showTicks: true,
          axisLineStyle: const AxisLineStyle(
            thickness: 0.15,
            cornerStyle: CornerStyle.bothCurve,
            color: Colors.grey,
            thicknessUnit: GaugeSizeUnit.factor,
          ),
          pointers: [
            NeedlePointer(
              value: value,
              needleColor: Colors.green,
              needleLength: 0.7,
              needleEndWidth: 3,
              knobStyle: const KnobStyle(
                color: Colors.green,
                sizeUnit: GaugeSizeUnit.factor,
                knobRadius: 0.07,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSetLimitDialog(BuildContext context, HomeViewModel model) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Energy Limit'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Limit (kWh)'),
        ),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final limit = double.tryParse(controller.text) ?? 0.0;
              model.setEnergyLimit(limit);
              Navigator.pop(context);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
