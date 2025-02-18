// home_view.dart
import 'package:ai_based_smart_energy_meter/ui/views/home/home_viewmodel.dart';
import 'package:ai_based_smart_energy_meter/ui/views/notification/notification_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../services/database_service.dart';
import '../../components/gauge_painter.dart';
import '../../components/topenergy_alert.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(
        snackbarService: SnackbarService(),
        databaseService: DatabaseService(),
        notificationViewModel: NotificationViewModel()
      ),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Color(0xFFEEF1F9),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Voltage and Current cards
                  _buildMeterCards(model),

                  const SizedBox(height: 16),

                  // Power and Energy cards
                  _buildInfoCards(model),

                  const SizedBox(height: 16),

                  // Usage Graph
                  _buildUsageGraph(model),

                  const SizedBox(height: 16),

                  // Monthly Usage Card
                  _buildMonthlyUsageCard(context, model),
                  const SizedBox(height: kBottomNavigationBarHeight + 16)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeterCards(HomeViewModel model) {
    return Row(
      children: [
        Expanded(
          child: _buildGaugeMeter(
            'Voltage',
            model.formatVoltage(),
            300,
            'V',
            Colors.purple,
            model.deviceData?.voltage ?? 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGaugeMeter(
            'Current',
            model.formatCurrent(),
            1,
            'A',
            Colors.red,
            model.deviceData?.current ?? 0,
          ),
        ),
      ],
    );
  }

  Widget _buildGaugeMeter(
    String title,
    String value,
    double maxValue,
    String unit,
    Color color,
    double currentValue,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: GaugePainter(
                value: currentValue,
                maxValue: maxValue,
                color: color,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      unit,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(HomeViewModel model) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Power',
            model.formatPower(),
            'W',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            'Energy',
            model.formatEnergy(),
            'kWh',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageGraph(HomeViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Energy Usage',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
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
                              List<String> days = [
                                'Sun',
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat'
                              ];
                              return Text(days[value.toInt()],
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold));
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: model.getBarChartData(),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildMonthlyUsageCard(BuildContext context, HomeViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFC8DBFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Monthly Usage: ${model.formatEnergy()} kWh',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () => _showLimitDialog(context, model),
            child: Row(
              children: [
                Text(
                  'Monthly usage limit: ${model.monthlyLimit} kWh',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: model.getUsagePercentage() / 100,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${model.monthlyLimit} kWh',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              ElevatedButton.icon(
                onPressed: model.toggleAIMonitoring,
                icon: Icon(
                  Icons.auto_awesome,
                  color:
                      model.isAIMonitoringEnabled ? Colors.green : Colors.grey,
                ),
                label: Text('AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor:
                      model.isAIMonitoringEnabled ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
          if (model.aiPrediction != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'AI Generated Bill Amount: ${model.aiPrediction}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showLimitDialog(
      BuildContext dialogContext, HomeViewModel model) async {
    final controller = TextEditingController(
      text: model.monthlyLimit.toString(),
    );

    return showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: Text(
          'Set Monthly Usage Limit',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Monthly Limit (kWh)',
            suffix: Text(
              'kWh',
              style: GoogleFonts.poppins(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () {
              final newLimit = double.tryParse(controller.text);
              if (newLimit != null) {
                model.updateMonthlyLimit(newLimit);
              }
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}
