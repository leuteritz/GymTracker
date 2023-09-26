import 'package:flutter/cupertino.dart';
import 'dart:async';
import '/constants/constants.dart';

class HomeScreenExerciseTimer extends StatefulWidget {
  final String exercise;

  HomeScreenExerciseTimer({Key? key, required this.exercise}) : super(key: key);

  @override
  State<HomeScreenExerciseTimer> createState() =>
      HomeScreenExerciseTimerState();
}

class HomeScreenExerciseTimerState extends State<HomeScreenExerciseTimer> {
  Timer? _timer;
  int _seconds = 0;
  String timerValue = '00:00';
  @override
  void initState() {
    super.initState();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
          _updateTimerValue();
        });
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();

    String exerciseName = widget.exercise;
    String duration = timerValue;

    Map<String, dynamic> exerciseData = {
      "name": exerciseName,
      "duration": duration,
    };

    exerciseDurationList.add(exerciseData);
  }

  void _updateTimerValue() {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = (_seconds % 60).round();
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    setState(() {
      timerValue = '$formattedMinutes:$formattedSeconds';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        child: Text(timerValue,
            style: TextStyle(
              fontSize: 14,
            )),
      ),
    );
  }
}
