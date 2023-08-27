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
  GlobalKey<LineChartSample2State> _chartKey =
      GlobalKey<LineChartSample2State>();

  int _selectedMonthIndex = DateTime.now().month - 1;
  int _selectedWeek = DateTime.now().weekday - 1;
  String _currentWeek = '';

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

  String getCurrentYear() {
    DateTime now = DateTime.now();
    return now.year.toString();
  }

  void _showCupertinoModalWeek(BuildContext context, setState) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        List<Widget> weekWidgets = [];

        DateTime firstDayOfMonth =
            DateTime(DateTime.now().year, _selectedMonthIndex + 1, 1);
        DateTime lastDayOfMonth =
            DateTime(DateTime.now().year, _selectedMonthIndex + 2, 0);

        DateTime currentDay = firstDayOfMonth;
        while (currentDay.isBefore(lastDayOfMonth)) {
          DateTime startOfWeek = currentDay;
          DateTime endOfWeek = currentDay.add(Duration(days: 6));
          String startDateString =
              "${startOfWeek.day.toString().padLeft(2, '0')}.${startOfWeek.month.toString().padLeft(2, '0')}";
          String endDateString =
              "${endOfWeek.day.toString().padLeft(2, '0')}.${endOfWeek.month.toString().padLeft(2, '0')}";
          String weekDateRange = '$startDateString - $endDateString';

          weekWidgets.add(
            Center(
              child: Text(weekDateRange),
            ),
          );

          currentDay = currentDay.add(Duration(days: 7));
          _currentWeek = weekDateRange;
        }

        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 40,
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedWeek = index;
              });
            },
            children: weekWidgets,
          ),
        );
      },
    );
  }

  void _showCupertinoModal(BuildContext context, setState) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 40,
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedMonthIndex = index;
              });
            },
            children: List<Widget>.generate(monthNames.length, (int index) {
              return Center(
                child: Text(monthNames[index]),
              );
            }),
          ),
        );
      },
    );
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
              GestureDetector(
                onTap: () {
                  setState(() {});
                  _showCupertinoModalWeek(context, setState);
                },
                child: Text(
                  getCurrentWeekDateRange(), // Display current week date range
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_selectedInterval == 'month')
              GestureDetector(
                onTap: () {
                  setState(() {});
                  _showCupertinoModal(context, setState);
                },
                child: Text(
                  monthNames[_selectedMonthIndex],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
              key: _chartKey,
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
                  _chartKey.currentState?.getInformation(value);
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
