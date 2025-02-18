// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class EnergyUsageGraph extends StatelessWidget {
//   final List<Map<String, dynamic>> monthlyEnergyData;
//
//   const EnergyUsageGraph({Key? key, required this.monthlyEnergyData}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final gradientColors = [
//       Colors.blue.withOpacity(0.3),
//       Colors.lightBlueAccent.withOpacity(0.3),
//     ];
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (double value, TitleMeta meta) {
//                 return SideTitleWidget(
//                   axisSide: meta.axisSide,
//                   child: Text(chartData[value.toInt()]['label']),
//                 );
//               },
//             ),
//           ),
//         ),
//         barGroups: chartData.map((data) {
//           return BarChartGroupData(
//             x: data['x'],
//             barRods: [
//               BarChartRodData(
//                 fromY: 0,
//                 toY: data['value'],
//                 width: 18,
//                 color: data['x'] == DateTime.now().month - 1
//                     ? Colors.orange
//                     : Colors.amber,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//
//   }
// }
