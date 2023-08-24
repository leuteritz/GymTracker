import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database.dart';

class LineChartSample2 extends StatefulWidget {
  final String exercise;
  final String selectedInterval;
  const LineChartSample2(
      {super.key, required this.exercise, required this.selectedInterval});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<FlSpot> dataPoints = [];
  double minY = 100000;
  double maxY = -100000;
  double minX = 0;
  double maxX = 0;
  List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<String> monthNames = [
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
    'Dev'
  ];

  @override
  void initState() {
    super.initState();
    getInformation(); // Call getInformation when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 12,
              bottom: 12,
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(
      double value, TitleMeta meta, String selectedInterval) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    if (selectedInterval == 'week') {
      int dayIndex = (value).toInt();
      if (dayIndex >= 0 && dayIndex < 7) {
        return Text(dayNames[dayIndex], style: style);
      }
    } else if (selectedInterval == 'month') {
      int dayOfMonth = (value + 1).toInt(); // Adjust value to start from 1
      if (dayOfMonth >= 1 && dayOfMonth <= 31 && dayOfMonth % 4 == 0) {
        return Text(dayOfMonth.toString(), style: style);
      }
    } else if (selectedInterval == 'year') {
      int dayIndex = (value).toInt();
      if (dayIndex >= 0 && dayIndex < 12 && dayIndex % 2 == 0) {
        return Text(monthNames[dayIndex], style: style);
      }
    }

    return Container(); // Return an empty container if no text should be shown
  }

  Widget leftTitleWidgets(
      double value, TitleMeta meta, double minY, double maxY) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );

    double midValue = (maxY + minY) / 2;

    if (value == minY) {
      return Text(minY.toStringAsFixed(0),
          style: style, textAlign: TextAlign.left);
    } else if (value == midValue) {
      return Text(midValue.toStringAsFixed(0),
          style: style, textAlign: TextAlign.left);
    } else if (value == maxY) {
      return Text(maxY.toStringAsFixed(0),
          style: style, textAlign: TextAlign.left);
    }

    return Container();
  }

  LineChartData mainData() {
    double interval = 1; // Default interval

    switch (widget.selectedInterval) {
      case 'week':
        interval = 7;
        break;
      case 'month':
        interval = 31;
        break;
      case 'year':
        interval = 12;
        break;
    }

    maxX = interval - 1;
    print(maxX);
    return LineChartData(
      gridData: FlGridData(
        show: true,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) =>
                bottomTitleWidgets(value, meta, widget.selectedInterval),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) =>
                leftTitleWidgets(value, meta, minY, maxY),
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: CupertinoColors.activeBlue, width: 3),
      ),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: dataPoints,
          isCurved: true,
          color: CupertinoColors.activeOrange,
          barWidth: 3,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                CupertinoColors.inactiveGray,
                CupertinoColors.systemPurple, // End color
              ],
            ),
          ),
        ),
      ],
    );
  }

  void getInformation() async {
    List<Map<String, dynamic>> setsRepsAndDate =
        await DatabaseHelper().getMaxWeightRepsForExercise(widget.exercise);
    print(setsRepsAndDate);

    for (var row in setsRepsAndDate) {
      String date = row['date'].replaceAll('.', '');
      double maxWeightReps = row['max_weight_reps'].toDouble();

      // Convert the date to x-axis value
      double xValue = double.parse(date);

      // Use maxWeightReps as the y-axis value
      double yValue = maxWeightReps;

      // Update min and max y-values
      minY = minY > yValue ? yValue : minY;
      maxY = maxY < yValue ? yValue : maxY;

      dataPoints.add(FlSpot(xValue, yValue));
    }

    setState(() {}); // Update the chart with new data and y-axis range
  }
}
