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
  List<Map<String, dynamic>> maxWeightList = [];
  List<Map<String, dynamic>> maxRepsList = [];
  List<Map<String, dynamic>> maxDurationList = [];
  int _pr = 0;

  @override
  void initState() {
    super.initState();
    _getSets();
    _getMaxWeightByExerciset();
    _getMaxRepsByExerciset();
    _getMaxDurationByExerciset();
  }

  Future<void> _getSets() async {
    int set = await DatabaseHelper().getSets(widget.date, widget.exerciseName);
    if (mounted) {
      setState(() {
        _set = set;
      });
    }
  }

  Future<void> _getMaxWeightByExerciset() async {
    List<Map<String, dynamic>> _maxWeightList =
        await DatabaseHelper().getAllMaxWeightByExercise();

    int maxPR = 0;
    for (Map<String, dynamic> maxWeightData in _maxWeightList) {
      if (maxWeightData['name'] == widget.exerciseName &&
          maxWeightData['date'] == widget.date) {
        maxPR += 1;
      }
    }
    setState(() {
      _pr += maxPR;
    });
  }

  Future<void> _getMaxRepsByExerciset() async {
    List<Map<String, dynamic>> _maxRepsList =
        await DatabaseHelper().getAllMaxRepsByExercise();

    int maxPR = 0;
    for (Map<String, dynamic> maxRepsData in _maxRepsList) {
      if (maxRepsData['name'] == widget.exerciseName &&
          maxRepsData['date'] == widget.date) {
        maxPR += 1;
      }
    }
    setState(() {
      _pr += maxPR;
    });
  }

  Future<void> _getMaxDurationByExerciset() async {
    List<Map<String, dynamic>> _maxDurationList =
        await DatabaseHelper().getAllMaxDurationByExercise();

    int maxPR = 0;
    for (Map<String, dynamic> maxDurationData in _maxDurationList) {
      if (maxDurationData['name'] == widget.exerciseName &&
          maxDurationData['date'] == widget.date) {
        maxPR += 1;
      }
    }
    setState(() {
      _pr += maxPR;
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
            '$_set x ${widget.exerciseName}  |  $_pr x 🏆', // Display sets before exercise name
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
