import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database.dart';

class LineChartSample2 extends StatefulWidget {
  final String exercise;
  final String selectedInterval;
  String currentWeek;

  LineChartSample2(
      {super.key,
      required this.exercise,
      required this.selectedInterval,
      required this.currentWeek});

  @override
  State<LineChartSample2> createState() => LineChartSample2State();
}

class LineChartSample2State extends State<LineChartSample2> {
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
  List<Map<String, dynamic>> setsRepsAndDate = [];
  Map<int, List<double>> monthData = {};

  @override
  void initState() {
    super.initState();
    getInformation('week');
  }

  void getWeek(String currentWeek) {
    setState(() {
      widget.currentWeek = currentWeek;
    });
  }

  Future<void> getInformation(String selectedIndex) async {
    List<Map<String, dynamic>> setsRepsAndDate1 =
        await DatabaseHelper().getMaxWeightRepsForExercise(widget.exercise);

    setState(() {
      setsRepsAndDate = setsRepsAndDate1;
    });
    print(dataPoints);
    // Reset
    dataPoints.clear();
    minY = 100000;
    maxY = -100000;
    monthData.clear();

    for (var row in setsRepsAndDate) {
      String date = row['date'];
      double maxWeightReps = row['max_weight_reps'].toDouble();

      // Convert the date to x-axis value
      double xValue = convertDateToXValue(date, selectedIndex);

      List<String> dateParts = date.split('.');
      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]);

      DateTime parsedDate = DateTime(year, month, day);
      print(parsedDate);

      List<String> currentWeekParts = widget.currentWeek.split(' - ');
      String startWeekPart = currentWeekParts[0];
      String endWeekPart = currentWeekParts[1];

      int startDay = int.parse(startWeekPart.split('.')[0]);
      int startMonth = int.parse(startWeekPart.split('.')[1]);

      int endDay = int.parse(endWeekPart.split('.')[0]);
      int endMonth = int.parse(endWeekPart.split('.')[1]);

      DateTime startWeekDate = DateTime(year, startMonth, startDay);
      DateTime endWeekDate = DateTime(year, endMonth, endDay);

      if (selectedIndex == 'week' &&
          (parsedDate.isAtSameMomentAs(startWeekDate) ||
              parsedDate.isAfter(startWeekDate)) &&
          (parsedDate.isAtSameMomentAs(endWeekDate) ||
              parsedDate.isBefore(endWeekDate))) {
        // Use maxWeightReps as the y-axis value
        double yValue = maxWeightReps;
        minY = minY > yValue ? yValue : minY;
        maxY = maxY < yValue ? yValue : maxY;

        dataPoints.add(FlSpot(
          xValue,
          yValue,
        ));
      } else if (selectedIndex == 'month' &&
          parsedDate.year == DateTime.now().year &&
          parsedDate.month == DateTime.now().month) {
        // Use a different formula for yValue based on month interval
        double yValue =
            maxWeightReps; // Calculate the appropriate yValue for month
        minY = minY > yValue ? yValue : minY;
        maxY = maxY < yValue ? yValue : maxY;

        dataPoints.add(FlSpot(
          xValue,
          yValue,
        ));
      } else if (selectedIndex == 'year' &&
          parsedDate.year == DateTime.now().year) {
        double yValue =
            maxWeightReps; // Calculate the appropriate yValue for year

        int monthKey = month;
        if (!monthData.containsKey(monthKey)) {
          monthData[monthKey] = [];
        }
        monthData[monthKey]?.add(yValue);
        print("Data: ${monthData[monthKey]}");
      }
    }
    monthData.forEach((monthKey, values) {
      if (values.isNotEmpty) {
        double average = calculateAverage(values);
        print("Average for month $monthKey: $average");

        minY = minY > average ? average : minY;
        maxY = maxY < average ? average : maxY;

        dataPoints.add(FlSpot(
          monthKey.toDouble() - 1,
          average,
        ));
      }
    });
  }

  double calculateAverage(List<double> values) {
    if (values.isEmpty) {
      return 0.0; // Return 0 if the list is empty to avoid division by zero
    }

    double sum = values.reduce((a, b) => a + b);
    print(sum / values.length);
    return sum / values.length;
  }

  double convertDateToXValue(String date, String selectedIndex) {
    List<String> dateParts = date.split('.');

    print("current week: ${widget.currentWeek}");

    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);

    DateTime parsedDate = DateTime(year, month, day);
    print(parsedDate);

    List<String> currentWeekParts = widget.currentWeek.split(' - ');
    String startWeekPart = currentWeekParts[0];
    String endWeekPart = currentWeekParts[1];

    int startDay = int.parse(startWeekPart.split('.')[0]);
    int startMonth = int.parse(startWeekPart.split('.')[1]);

    int endDay = int.parse(endWeekPart.split('.')[0]);
    int endMonth = int.parse(endWeekPart.split('.')[1]);

    DateTime startWeekDate = DateTime(year, startMonth, startDay);
    DateTime endWeekDate = DateTime(year, endMonth, endDay);

    if (selectedIndex == 'week' &&
        (parsedDate.isAtSameMomentAs(startWeekDate) ||
            parsedDate.isAfter(startWeekDate)) &&
        (parsedDate.isAtSameMomentAs(endWeekDate) ||
            parsedDate.isBefore(endWeekDate))) {
      // If the date is within the selected week, return the day index
      return parsedDate.weekday.toDouble() - 1;
    } else if (selectedIndex == 'month') {
      // Check if the date is in the current month
      if (parsedDate.year == DateTime.now().year &&
          parsedDate.month == DateTime.now().month) {
        // Return the day of the month
        return day.toDouble() - 1;
      }
    } else if (selectedIndex == 'year') {
      if (parsedDate.year == DateTime.now().year) {
        // Return the day of the month
        return day.toDouble() - 1;
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Add a container or text widget for the y-axis description
        Positioned(
          top: 0, // Adjust the position as needed
          left: 2, // Adjust the position as needed
          child: Text(
            'Load', // Your y-axis description text
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top:
                  30, // Adjust the top padding to make space for the description
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
    print(setsRepsAndDate);
    print(dataPoints);

    print(minY);
    print(maxY);
    // Update the chart when the interval is changed
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
          isCurved: false,
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
}
