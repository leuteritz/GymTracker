import 'package:flutter/cupertino.dart';
import 'chart.dart';

class ExerciseDetailPage extends StatefulWidget {
  final String exercise;
  final String description;

  ExerciseDetailPage({required this.exercise, required this.description});
  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  String _selectedInterval = 'week';
  List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  String getCurrentWeekDateRange() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));
    String startDateString =
        "${startOfWeek.day.toString().padLeft(2, '0')}.${startOfWeek.month.toString().padLeft(2, '0')}";
    String endDateString =
        "${endOfWeek.day.toString().padLeft(2, '0')}.${endOfWeek.month.toString().padLeft(2, '0')}";
    return "$startDateString - $endDateString";
  }

  String getCurrentMonth() {
    DateTime now = DateTime.now();
    return monthNames[now.month - 1];
  }

  String getCurrentYear() {
    DateTime now = DateTime.now();
    return now.year.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.exercise),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Description",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '"${widget.description}"',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_selectedInterval == 'week')
              Text(
                getCurrentWeekDateRange(), // Display current week date range
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (_selectedInterval == 'month')
              Text(
                getCurrentMonth(), // Display current week date range
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (_selectedInterval == 'year')
              Text(
                getCurrentYear(), // Display current week date range
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 20),
            LineChartSample2(
              exercise: widget.exercise,
              selectedInterval: _selectedInterval,
            ),
            Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: CupertinoSegmentedControl(
                children: {
                  'week': Text('Week'), // Change 'Week' to 'week'
                  'month': Text('Month'), // Change 'Month' to 'month'
                  'year': Text('Year'), // Change 'Year' to 'year'
                },
                onValueChanged: (value) {
                  setState(() {
                    _selectedInterval = value;
                  });
                },
                groupValue: _selectedInterval,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
