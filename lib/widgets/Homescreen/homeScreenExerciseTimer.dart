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

class HomeScreenExerciseTimerState extends State<HomeScreenExerciseTimer>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _seconds = 0;
  String timerValue = '00:00';
  DateTime? _lockTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_seconds > 0) {
      if (state == AppLifecycleState.paused) {
        print("inactive");
        _lockTime = DateTime.now();
        print(_lockTime);
        _timer?.cancel();
      } else if (state == AppLifecycleState.resumed) {
        if (_lockTime != null) {
          print("resumed");
          int lockDurationInSeconds = 0;
          final now = DateTime.now();
          print("now: $now");

          final lockDuration = now.difference(_lockTime!);
          print(lockDuration);
          lockDurationInSeconds = lockDuration.inSeconds;
          print("duration: $lockDurationInSeconds");
          _seconds += lockDurationInSeconds;
          print("seconds: $_seconds");

          _lockTime = null;
          print(lockDurationInSeconds);

          startTimer();
        }
      }
    }
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
