import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'database.dart';
import 'workoutdetailpage.dart';
import 'exerciselistitem.dart';

class WorkoutDateItem extends StatefulWidget {
  final String date;

  WorkoutDateItem({required this.date});

  @override
  State<WorkoutDateItem> createState() => _WorkoutDateItemState();
}

class _WorkoutDateItemState extends State<WorkoutDateItem> {
  DateTime myDate = DateTime.now();
  String dayOfWeek = '';
  String _duration = '';
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
  }

  Future<void> _getDuration() async {
    String duration = await DatabaseHelper().getDuration(widget.date);
    setState(() {
      _duration = duration;
    });
  }

  Future<void> _getTotalWeight() async {
    int totalWeight = await DatabaseHelper().getTotalWeight(widget.date);
    setState(() {
      _totalWeight = totalWeight;
    });
  }

  Future<void> _getExercises() async {
    List<Map<String, dynamic>> exercises =
        await DatabaseHelper().getExercisesByDate(widget.date);
    setState(() {
      _exercises = exercises;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 60, 60, 60),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(20),
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
                      CupertinoIcons.time,
                      color: CupertinoColors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      _duration,
                      style: TextStyle(fontSize: 17),
                    ),
                  ]),
                ),
                Container(
                  child: Row(children: [
                    Icon(
                      CupertinoIcons.sum,
                      color: CupertinoColors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      _totalWeight.toString() + ' kg',
                      style: TextStyle(fontSize: 17),
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
                    return ExerciseListItem(
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