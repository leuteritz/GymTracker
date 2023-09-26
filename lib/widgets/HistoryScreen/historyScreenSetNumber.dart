import 'package:flutter/cupertino.dart';
import 'dart:async';
import '/data/database.dart';

class HistoryScreenSetNumber extends StatefulWidget {
  final String exerciseName;
  final String date;

  HistoryScreenSetNumber({required this.exerciseName, required this.date});

  @override
  State<HistoryScreenSetNumber> createState() => _HistoryScreenSetNumberState();
}

class _HistoryScreenSetNumberState extends State<HistoryScreenSetNumber> {
  int _set = 0;

  @override
  void initState() {
    super.initState();
    _getSets();
  }

  Future<void> _getSets() async {
    int set = await DatabaseHelper().getSets(widget.date, widget.exerciseName);
    if (mounted) {
      setState(() {
        _set = set;
      });
    }
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
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemGrey),
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }
}
