import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'constants.dart';

class ExerciseTimer extends StatefulWidget {
  final String exercise;

  ExerciseTimer({Key? key, required this.exercise}) : super(key: key);

  @override
  State<ExerciseTimer> createState() => ExerciseTimerState();
}

class ExerciseTimerState extends State<ExerciseTimer> {
  Timer? _timer;
  int _seconds = 0;
  String timerValue = '00:00';
  @override
  void initState() {
    super.initState();
  }

  void startTimer() {
    print(1);

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
    print(exerciseDurationList);
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
        decoration:
            BoxDecoration(color: CupertinoColors.systemGrey.withOpacity(0.3)),
        child: Text(timerValue,
            style: TextStyle(
              fontSize: 14,
            )),
      ),
    );
  }
}
