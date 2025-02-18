import 'package:ai_based_smart_energy_meter/ui/components/customappbar.dart';
import 'package:ai_based_smart_energy_meter/ui/views/predict/predict_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

class PredictView extends StatelessWidget {
  const PredictView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PredictionViewModel>.reactive(
        onModelReady: (model) {
          // model.initializeEnergyMonitoring();
          model.initializeMonthlyEnergy();
          model.listenToRealTimeCost();
          // model.calculateMonthlyCost();
        },
        viewModelBuilder: () => PredictionViewModel(),
        builder: (context, model, child) {
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prediction Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFFC8DBFF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prediction',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Year Picker Input
                            InputField(
                              label: 'Select Year',
                              controller: model.yearController,
                              readOnly: true, // Make field read-only
                              onTap: () =>
                                  model.selectYear(context), // Open year picker
                            ),
                            const SizedBox(height: 12),

                            // Month Picker Input
                            InputField(
                              label: 'Select Month',
                              controller: model.monthController,
                              readOnly: true, // Make field read-only
                              onTap: () => model
                                  .selectMonth(context), // Open month picker
                            ),
                            const SizedBox(height: 12),

                            InputField(
                              label: 'Number of Inmates',
                              controller: model.inmatesController,
                              onChanged: model.onInmatesChanged,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            InputField(
                              label: 'Number of Days',
                              controller: model.daysController,
                              onChanged: model.onDaysChanged,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),

                            // Predict Button
                            Center(
                              child: ElevatedButton(
                                onPressed: model.predict,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade100,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Predict',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            if (model.isLoading)
                              const CircularProgressIndicator()
                            else if (model.prediction != null)
                              Text(
                                "Prediction Value: ${model.prediction}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent),
                              )
                            else
                              const Text(
                                "No prediction yet",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Last Month Charge
                      Text(
                        'Current month electricity cost : ₹ ${model.totalMonthlyCost}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Energy Usage Graph
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Energy Usage',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            const SizedBox(height: 10),
                            model.monthlyEnergyData.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _buildUsageGraph(model),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: kBottomNavigationBarHeight + 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildUsageGraph(PredictionViewModel model) {
    return SizedBox(
      height: 250, // Increased height to accommodate Y-axis labels
      child: model.isBusy
          ? const Center(child: CircularProgressIndicator())
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100, // Adjust this based on max energy usage
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()} kWh',
                            style: TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        List<String> months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec'
                        ];
                        return Text(months[value.toInt()],
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold));
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: model.getMonthlyChartData(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
              ),
            ),
    );
  }
}

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final VoidCallback? onTap; // New property for handling tap actions
  final bool readOnly; // New property for making the field read-only

  const InputField({
    Key? key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.keyboardType,
    this.onTap,
    this.readOnly = false, // Default to false if not specified
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      readOnly: readOnly, // Set read-only for fields like year and month
      onTap: onTap, // Trigger the onTap callback when the field is tapped
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
