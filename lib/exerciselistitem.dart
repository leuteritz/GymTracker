import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'database.dart';

class ExerciseListItem extends StatefulWidget {
  final String exerciseName;
  final String date;

  ExerciseListItem({required this.exerciseName, required this.date});

  @override
  State<ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {
  int _set = 0;

  @override
  void initState() {
    super.initState();
    _getSets();
  }

  Future<void> _getSets() async {
    int set = await DatabaseHelper().getSets(widget.date, widget.exerciseName);
    setState(() {
      _set = set;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: Text(
            '$_set x ${widget.exerciseName}', // Display sets before exercise name
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }
}
