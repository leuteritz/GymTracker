import 'package:flutter/cupertino.dart';
import 'dart:async';
import '/data/database.dart';
import '/pages/workoutDetailPage.dart';
import 'historyScreenSetNumber.dart';

class HistoryScreenItem extends StatefulWidget {
  final String date;

  HistoryScreenItem({required this.date, Key? key}) : super(key: key);
  @override
  State<HistoryScreenItem> createState() => HistoryScreenItemState();
}

class HistoryScreenItemState extends State<HistoryScreenItem> {
  DateTime myDate = DateTime.now();
  String dayOfWeek = '';
  String _duration = '';
  String? _startTime = '';
  int _totalWeight = 0;
  List<Map<String, dynamic>> _exercises = [];

  @override
  void initState() {
    super.initState();
    myDate = _parseDate(widget.date);
    dayOfWeek = getDayOfWeek(myDate);

    _getDuration();
    _getTotalWeight();
    _getExercises();
    _getStartTime();
  }

  Future<void> _getDuration() async {
    String duration = await DatabaseHelper().getDuration(widget.date);
    if (mounted) {
      setState(() {
        _duration = duration;
      });
    }
  }

  Future<void> _getStartTime() async {
    String? startTime = await DatabaseHelper().getStartTime(widget.date);
    if (mounted) {
      setState(() {
        _startTime = startTime;
      });
    }
  }

  Future<void> _getTotalWeight() async {
    int totalWeight = await DatabaseHelper().getTotalWeight(widget.date);

    if (mounted) {
      setState(() {
        _totalWeight = totalWeight;
      });
    }
  }

  Future<void> _getExercises() async {
    List<Map<String, dynamic>> exercises =
        await DatabaseHelper().getExercisesByDate(widget.date);
    if (mounted) {
      setState(() {
        _exercises = exercises;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _getDuration();
    _getTotalWeight();
    _getExercises();
    _getStartTime();

    return GestureDetector(
      onTap: () {
        // Navigate to the WorkoutDetailPage when the item is pressed
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => WorkoutDetailPage(
              date: widget.date,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayOfWeek,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.date,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(children: [
                    Icon(
                      CupertinoIcons.time_solid,
                      color: CupertinoColors.systemGrey,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "$_startTime h",
                      style: TextStyle(
                          fontSize: 17, color: CupertinoColors.systemGrey),
                    ),
                  ]),
                ),
                Container(
                  child: Row(children: [
                    Icon(
                      CupertinoIcons.time,
                      color: CupertinoColors.systemGrey,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "$_duration min",
                      style: TextStyle(
                          fontSize: 17, color: CupertinoColors.systemGrey),
                    ),
                  ]),
                ),
                Container(
                  child: Row(children: [
                    Icon(
                      CupertinoIcons.sum,
                      color: CupertinoColors.systemGrey,
                    ),
                    SizedBox(width: 5),
                    Text(
                      _totalWeight.toString() + ' kg',
                      style: TextStyle(
                          fontSize: 17, color: CupertinoColors.systemGrey),
                    ),
                  ]),
                )
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return HistoryScreenSetNumber(
                      exerciseName: exercise['name'],
                      date: widget.date,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getDayOfWeek(DateTime date) {
    List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    int dayIndex = date.weekday - 1;

    return daysOfWeek[dayIndex];
  }

  DateTime _parseDate(String dateStr) {
    // Split the date string into day, month, and year components
    List<String> dateComponents = dateStr.split('.');
    int day = int.parse(dateComponents[0]);
    int month = int.parse(dateComponents[1]);
    int year = int.parse(dateComponents[2]);

    // Construct a DateTime object from the components
    return DateTime(year, month, day);
  }
}
