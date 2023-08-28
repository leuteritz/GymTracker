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
  String _currentWeek = '';
  int selectedYear = DateTime.now().year;

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

  @override
  void initState() {
    super.initState();
    getCurrentWeekDateRange();
  }

  void getCurrentWeekDateRange() {
    if (_selectedMonthIndex == DateTime.now().month - 1) {
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));
      String startDateString =
          "${startOfWeek.day.toString().padLeft(2, '0')}.${startOfWeek.month.toString().padLeft(2, '0')}";
      String endDateString =
          "${endOfWeek.day.toString().padLeft(2, '0')}.${endOfWeek.month.toString().padLeft(2, '0')}";
      _currentWeek = "$startDateString - $endDateString";
    } else {
      DateTime now = DateTime(DateTime.now().year, _selectedMonthIndex + 1, 1);
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));
      String startDateString =
          "${startOfWeek.day.toString().padLeft(2, '0')}.${startOfWeek.month.toString().padLeft(2, '0')}";
      String endDateString =
          "${endOfWeek.day.toString().padLeft(2, '0')}.${endOfWeek.month.toString().padLeft(2, '0')}";
      _currentWeek = "$startDateString - $endDateString";
    }
  }

  void _showCupertinoModalWeek(BuildContext context, setState) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        List<String> weekWidgets = [];

        DateTime firstDayOfMonth = DateTime(selectedYear,
            _selectedMonthIndex + 1, 1); // Use the selected year here
        DateTime lastDayOfMonth = DateTime(selectedYear,
            _selectedMonthIndex + 2, 0); // Use the selected year here

        // Calculate the start day of the week based on whether January 1st is a Monday
        int startDay = firstDayOfMonth.weekday == DateTime.monday ? 1 : 2;

        DateTime currentDay = firstDayOfMonth.add(Duration(days: startDay - 1));
        while (currentDay.isBefore(lastDayOfMonth)) {
          DateTime startOfWeek = currentDay;
          DateTime endOfWeek = currentDay.add(Duration(days: 6));
          String startDateString =
              "${startOfWeek.day.toString().padLeft(2, '0')}.${startOfWeek.month.toString().padLeft(2, '0')}";
          String endDateString =
              "${endOfWeek.day.toString().padLeft(2, '0')}.${endOfWeek.month.toString().padLeft(2, '0')}";
          String weekDateRange = '$startDateString - $endDateString';

          weekWidgets.add(weekDateRange);

          currentDay = currentDay.add(Duration(days: 7));
        }

        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 40,
            looping: true,
            onSelectedItemChanged: (int index) {
              setState(() {
                _currentWeek = weekWidgets[index].toString();
                _chartKey.currentState?.getWeek(_currentWeek);
                _chartKey.currentState?.getInformation(_selectedInterval);
              });
            },
            children: List<Widget>.generate(weekWidgets.length, (int index) {
              return Center(
                child: Text(weekWidgets[index]),
              );
            }),
          ),
        );
      },
    );
  }

  void _showCupertinoModalMonth(BuildContext context, setState) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 40,
            looping: true,
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedMonthIndex = index;
                _chartKey.currentState?.getMonth(_selectedMonthIndex);
                _chartKey.currentState?.getInformation(_selectedInterval);
                getCurrentWeekDateRange();
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

  void _showCupertinoModalYear(BuildContext context, setState) {
    int currentYear = 2023;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        ;
        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 40,
            looping: true,
            onSelectedItemChanged: (int index) {
              setState(() {
                selectedYear = currentYear + index;
                _chartKey.currentState?.getYear(selectedYear);
                _chartKey.currentState?.getInformation(_selectedInterval);
              });
            },
            children:
                List<Widget>.generate(2100 - currentYear + 1, (int index) {
              return Center(
                child: Text((currentYear + index).toString()),
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
                  _currentWeek, // Display current week date range
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
                  _showCupertinoModalMonth(context, setState);
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
              GestureDetector(
                onTap: () {
                  setState(() {});
                  _showCupertinoModalYear(context, setState);
                },
                child: Text(
                  selectedYear.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 20),
            LineChartSample2(
              key: _chartKey,
              exercise: widget.exercise,
              selectedInterval: _selectedInterval,
              currentWeek: _currentWeek,
              currentMonth: _selectedMonthIndex,
              currentYear: selectedYear,
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
                  _chartKey.currentState?.getInformation(_selectedInterval);
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
