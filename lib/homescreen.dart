import 'database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'exerciseadd.dart';
import 'dart:async';
import 'exerciselabel.dart';
import 'dart:math' as math;

class _SpinnerPainter extends CustomPainter {
  final int angle;

  _SpinnerPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color =
          Color.fromARGB(255, 173, 15, 226) // Set the color of the spinner
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double startAngle = math.pi * 1.5; // 270 degrees in radians
    double sweepAngle = angle * (math.pi / 180);

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ),
      startAngle, // Start angle (top)
      sweepAngle, // Sweep angle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class BreakTimer extends StatefulWidget {
  @override
  State<BreakTimer> createState() => _BreakTimerState();
}

class _BreakTimerState extends State<BreakTimer> with WidgetsBindingObserver {
  Timer? _timer;
  double _seconds = 0;
  String _timerValue = 'Pause';
  int _spinnerAngle = 360;
  double _timeselected = 0;
  int _tempseconds = 0;
  DateTime? _lockTime;
  bool _isModalShown = false;
  bool _showPauseText = true;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_seconds > 0) {
      if (state == AppLifecycleState.paused) {
        _lockTime = DateTime.now();
        _stopTimer();
      } else if (state == AppLifecycleState.resumed) {
        if (_lockTime != null) {
          int lockDurationInSeconds = 0;
          final now = DateTime.now();
          final lockDuration = now.difference(_lockTime!);
          lockDurationInSeconds = lockDuration.inSeconds;

          _seconds -= lockDurationInSeconds;
          _tempseconds += lockDurationInSeconds;

          _lockTime = null;

          if (_seconds <= 0 && !_isModalShown) {
            _showPauseText = true;
            _showBreakTimerEndModal(context);
            _isModalShown = true;
            _timerValue = 'Pause';
            _spinnerAngle = 0;
          } else {
            _startTimer();
          }
        }
      }
    }
  }

  void _updateTimerValue() {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = (_seconds % 60).round();
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    setState(() {
      _timerValue = '$formattedMinutes:$formattedSeconds';
    });
  }

  void _startTimer() {
    _isModalShown = false;
    _showPauseText = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          if (_seconds != 0) {
            _tempseconds++;
          }
          _seconds--;
          _updateTimerValue();
          _spinnerAngle = (360 - (_tempseconds / _timeselected * 360)).round();
        });
      } else {
        _timer?.cancel();

        if (!_isModalShown) {
          _showBreakTimerEndModal(context);
          _isModalShown = true;
        }

        Timer.periodic(Duration(seconds: 1), (timer) {
          SystemSound.play(SystemSoundType.click);
          if (timer.tick == 3) {
            timer.cancel();
          }
        });
        _spinnerAngle = 0;
        _tempseconds = 0;
        _timerValue = 'Pause';
        _showPauseText = true;
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  // Function to open the modal view
  void _showBreakTimerModal(BuildContext context, StateSetter setState) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 27,
            children: List<Widget>.generate(10, (index) {
              index += 1;
              int hours = (index ~/ 2);
              int minutes = (index % 2) * 30;

              String formattedTime =
                  '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} min';

              return Text(formattedTime);
            }),
            onSelectedItemChanged: (index) {
              setState(() {
                _spinnerAngle = 0;
                _tempseconds = 0;
                int hours = ((index + 1) ~/ 2);
                int minutes = ((index + 1) % 2) * 30;

                _timerValue =
                    '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
                _timeselected = (index / 2 + 0.5) * 60;
                _seconds = (index + 1) * 60 * 0.5;
                _startTimer();
              });
            },
          ),
        );
      },
    );
  }

  void _showBreakTimerEndModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.5,
            child: CupertinoPopupSurface(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pause ended!',
                    style:
                        TextStyle(fontSize: 20, color: CupertinoColors.white),
                  ),
                  SizedBox(height: 20),
                  CupertinoButton.filled(
                    child: Text('OK',
                        style: TextStyle(color: CupertinoColors.white)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showBreakTimerModal(context, setState);
        _stopTimer();
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_showPauseText)
                  CustomPaint(
                    size: Size(35, 35),
                    painter: _SpinnerPainter(_spinnerAngle),
                  )
                else
                  Text(
                    _timerValue,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
              ],
            ),
            if (!_showPauseText)
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    _timerValue, // Display the timer value here
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomNavigationBarState extends State<CustomNavigationBar>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _seconds = 0;
  String _timerValue = '00:00';
  String _duration = '';
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

  void _updateTimerValue() {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = _seconds % 60;
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    setState(() {
      _timerValue = '$formattedMinutes:$formattedSeconds';
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

          _startTimer();
        }
      }
    }
  }

  // Start the timer that runs every second
  void _startTimer() {
    _timer?.cancel(); // Cancel any previous timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _updateTimerValue();
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();

    _duration = _timerValue;

    _seconds = 0;

    DateTime now = DateTime.now();

    String _starttime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // insert the exercise into the database
    for (var exercise in exerciseList) {
      String name = exercise['name'];
      String date = exercise['date'];
      List<Map<String, int>> sets = exercise['sets'];

      String exerciseDuration = "00:00";

      for (var exerciseData in exerciseDurationList) {
        if (exerciseData['name'] == name) {
          exerciseDuration = exerciseData['duration'];
          break;
        }
      }
      for (var set in sets) {
        int reps = set['reps']!;
        int weight = set['weight']!;

        DatabaseHelper().insertExercise(
          name: name,
          sets: sets.length,
          weight: weight,
          reps: reps,
          date: date,
          duration: _duration,
          startTime: _starttime,
          exerciseduration: exerciseDuration,
        );
      }
    }

    DatabaseHelper().insertExercise(
      name: "Bench Press",
      sets: 3,
      weight: 50,
      reps: 1,
      date: "26.08.2023",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );

    DatabaseHelper().insertExercise(
      name: "Bench Press",
      sets: 3,
      weight: 10,
      reps: 5,
      date: "15.08.2023",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );

    DatabaseHelper().insertExercise(
      name: "Bench Press",
      sets: 3,
      weight: 4,
      reps: 5,
      date: "22.08.2023",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );
    DatabaseHelper().insertExercise(
      name: "Bench Press",
      sets: 3,
      weight: 7,
      reps: 6,
      date: "23.08.2023",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );

    DatabaseHelper().insertExercise(
      name: "Bench Press",
      sets: 3,
      weight: 7,
      reps: 20,
      date: "23.09.2023",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );

    DatabaseHelper().insertExercise(
      name: "Bench Press",
      sets: 3,
      weight: 7,
      reps: 20,
      date: "22.11.2028",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );
    DatabaseHelper().insertExercise(
      name: "Bench Press",
      sets: 3,
      weight: 7,
      reps: 20,
      date: "21.11.2028",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );

    DatabaseHelper().insertExercise(
      name: "Bench Press",
      sets: 3,
      weight: 10,
      reps: 20,
      date: "21.09.2024",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );

    DatabaseHelper().insertExercise(
      name: "Bench Press",
      sets: 3,
      weight: 7,
      reps: 12,
      date: "24.09.2023",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );

    DatabaseHelper().insertExercise(
      name: "Deadlift",
      sets: 3,
      weight: 4,
      reps: 5,
      date: "24.08.2022",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );

    DatabaseHelper().insertExercise(
      name: "Deadlift",
      sets: 3,
      weight: 4,
      reps: 8,
      date: "16.08.2023",
      duration: _duration,
      startTime: "21:30",
      exerciseduration: "00:00",
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BreakTimer(),
          // Add some spacing between the break timer and text
          Container(
            width: MediaQuery.of(context).size.width / 3.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  CupertinoIcons.stopwatch_fill,
                  size: 30,
                ),
                Text(
                  _timerValue,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3.5,
            child: Icon(
              CupertinoIcons.gear,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<_CustomNavigationBarState> _key =
      GlobalKey<_CustomNavigationBarState>();

  @override
  void initState() {
    super.initState();
    fetchExercises(setState);
  }

  double _currentSliderValue = 2;
  String _selectedExercise = 'Bench Press';

  bool _isAddButtonPressed = false;

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 7 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(key: _key),
      child: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final exercise = exerciseList[index];
                      return ExerciseLabel(
                        exercise: exercise['name'],
                        sets: exercise['sets'],
                        onDelete: (exerciseName) {
                          _deleteExercise(exerciseName);
                        },
                      );
                    },
                    childCount: exerciseList.length,
                  ),
                ),
                // Add more Sliver widgets as needed for additional content
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CupertinoButton(
                onPressed: () {
                  _showCupertinoModal(context);
                  _key.currentState?._startTimer();

                  setState(() {
                    _isAddButtonPressed = true; // Show "Stop" button
                  });
                },
                child: Icon(CupertinoIcons.add_circled_solid,
                    size: 60, color: CupertinoColors.systemGreen),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Visibility(
                visible: _isAddButtonPressed,
                child: CupertinoButton(
                  onPressed: () {
                    _key.currentState?._stopTimer();
                    setState(() {
                      exerciseList.clear();
                    });
                    _showCupertinoModalEndWorkout(context);
                  },
                  child: Icon(CupertinoIcons.stop_circle_fill,
                      size: 60, color: CupertinoColors.systemRed),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: 20,
              child: CupertinoButton(
                onPressed: () {
                  DatabaseHelper().deleteDatabase();
                },
                child: Icon(CupertinoIcons.delete_left_fill,
                    size: 60, color: CupertinoColors.systemRed),
              ),
            ),
            Visibility(
              visible: !_isAddButtonPressed,
              child: Positioned(
                top: 5,
                left: 15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.arrow_up,
                      size: 40,
                      color: CupertinoColors.systemGrey,
                    ),
                    Text(
                      'Tap to set ',
                      style: TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      'a break timer',
                      style: TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: !_isAddButtonPressed,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text.rich(
                      TextSpan(
                        text: 'Press the',
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: CupertinoButton(
                              onPressed: () {
                                _showCupertinoModal(context);
                                _key.currentState?._startTimer();

                                setState(() {
                                  _isAddButtonPressed = true;
                                });
                              },
                              child: Icon(CupertinoIcons.add_circled_solid,
                                  size: 30, color: CupertinoColors.systemGreen),
                            ),
                          ),
                          TextSpan(text: 'to start the workout'),
                        ],
                        style: TextStyle(
                          fontSize: 18,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> exercises = [];
  Map<String, List<ExerciseAdd>> exerciseMap = {};

  void fetchExercises(StateSetter setState) async {
    final List<Map<String, dynamic>> allExerciseData =
        await DatabaseHelper().getAllExerciseListInformation();

    List<Map<String, dynamic>> favoriteExerciseData = [];
    List<Map<String, dynamic>> nonFavoriteExerciseData = [];

    for (var exerciseData in allExerciseData) {
      if (exerciseData['favorite'] == 1) {
        favoriteExerciseData.add(exerciseData);
      } else {
        nonFavoriteExerciseData.add(exerciseData);
      }
    }

    setState(() {
      exercises = favoriteExerciseData + nonFavoriteExerciseData;
    });

    Map<String, List<ExerciseAdd>> initialExerciseMap = {};

    exercises.forEach((exercise) {
      final muscleGroup = exercise['muscle'];
      final exerciseName = exercise['name'];

      if (initialExerciseMap[muscleGroup] == null) {
        initialExerciseMap[muscleGroup] = [];
      }

      initialExerciseMap[muscleGroup]!.add(
        ExerciseAdd(
          name: exerciseName,
          muscleGroup: muscleGroup,
          key: Key(exercise['name']),
        ),
      );
    });
    setState(() {
      exerciseMap = initialExerciseMap;
    });
  }

  void _searchExercise(String searchText, StateSetter setState) {
    print(searchText);
    if (searchText.isEmpty) {
      fetchExercises(setState);
    } else {
      List<Map<String, dynamic>> filteredExercises = [];

      for (var exercise in exercises) {
        if (exercise['name'].toLowerCase().contains(searchText.toLowerCase())) {
          filteredExercises.add(exercise);
        }
      }
      print(filteredExercises);

      // Rebuild exerciseMap based on the filtered exercises
      Map<String, List<ExerciseAdd>> filteredExerciseMap = {};

      for (var exercise in filteredExercises) {
        final muscleGroup = exercise['muscle'];
        final exerciseName = exercise['name'];

        if (filteredExerciseMap[muscleGroup] == null) {
          filteredExerciseMap[muscleGroup] = [];
        }

        filteredExerciseMap[muscleGroup]!.add(
          ExerciseAdd(
            name: exerciseName,
            muscleGroup: muscleGroup,
            key: Key(exercise['name']),
          ),
        );
      }

      setState(() {
        print(1);
        exerciseMap = filteredExerciseMap;
      });
    }
  }

  void _showCupertinoModalExercise(BuildContext context, StateSetter setState) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double modalHeight = screenHeight * 0.8;
    final double modalWidth = screenWidth * 0.8;

    showCupertinoModalPopup(
      context: context,
      builder: (
        BuildContext context,
      ) {
        return Center(
          child: Container(
            width: modalWidth,
            height: modalHeight,
            child: CupertinoPopupSurface(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 50),
                        child: CupertinoSearchTextField(
                          placeholder: 'Search Exercise',
                          onChanged: (searchText) {
                            _searchExercise(searchText, setState);
                          },
                        ),
                      ),
                      Expanded(
                          child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: exerciseMap.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0) {
                            // Favorites section
                            var favoriteExercises = exercises
                                .where((exercise) => exercise['favorite'] == 1)
                                .toList();

                            if (favoriteExercises.isNotEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: Text(
                                        "Favorites" +
                                            " (${favoriteExercises.length})",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.systemGrey),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Center(
                                    child: Column(
                                      children:
                                          favoriteExercises.map((exercise) {
                                        return ExerciseAdd(
                                          name: exercise['name'],

                                          muscleGroup: exercise['muscle'],

                                          key: Key(exercise[
                                              'name']), // Use a unique identifier, like exercise name
                                          // Pass the callback
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      "Favorites" +
                                          " (${favoriteExercises.length})",
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: CupertinoColors.systemGrey),
                                    ),
                                  ),
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
                              );
                            }
                          } else {
                            var muscleGroup =
                                exerciseMap.keys.elementAt(index - 1);
                            var exercisesForGroup =
                                exerciseMap[muscleGroup] ?? [];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    muscleGroup,
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.systemGrey),
                                  ),
                                ),
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.white,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: Column(
                                    children: exercisesForGroup.map((exercise) {
                                      return ExerciseAdd(
                                        name: exercise.name,
                                        muscleGroup: exercise.muscleGroup,
                                        key: Key(exercise.name),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      )),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCupertinoModal(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double modalHeight = screenHeight * 0.3;
    final double modalWidth = screenWidth * 0.8;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: modalWidth,
            height: modalHeight,
            child: CupertinoPopupSurface(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        color: CupertinoColors.activeOrange,
                        onPressed: () {
                          _showCupertinoModalExercise(context, setState);
                        },
                        child: Text(_selectedExercise),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Text('Sets: ${_currentSliderValue.toInt()}'),
                            CupertinoSlider(
                              value: _currentSliderValue,
                              min: 2.0,
                              max: 5.0,
                              divisions: 3,
                              onChanged: (value) {
                                setState(() {
                                  _currentSliderValue = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        color: CupertinoColors.activeBlue,
                        child: Text('Add'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _addExerciseToList();
                        },
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCupertinoModalEndWorkout(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double modalHeight = screenHeight * 0.3;
    final double modalWidth = screenWidth * 0.8;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: modalWidth,
            height: modalHeight,
            child: CupertinoPopupSurface(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Workout ended!',
                        style: TextStyle(fontSize: 25),
                      ),
                      Text(_key.currentState!._timerValue),
                      CupertinoButton(
                        color: CupertinoColors.activeBlue,
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _isAddButtonPressed = false;
                          });
                        },
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // function to open exercise list
  void _showExerciseList(BuildContext context, StateSetter setState) {
    final List<String> exercises = [
      'Bench Press',
      'Squat',
      'Deadlift',
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 27,
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedExercise = exercises[index];
              });
            },
            children: exercises.map((exercise) => Text(exercise)).toList(),
          ),
        );
      },
    );
  }

  // function to add exercise to the list
  void _addExerciseToList() {
    // Get the current date
    DateTime currentDate = DateTime.now();

    // Format the date as dd.mm.yyyy
    String formattedDate =
        "${currentDate.day.toString().padLeft(2, '0')}.${currentDate.month.toString().padLeft(2, '0')}.${currentDate.year.toString()}";

    setState(() {
      exerciseList.add({
        'name': _selectedExercise,
        'date': formattedDate, // Add the formatted date to the exercise entry
        'sets': List.generate(
          _currentSliderValue.toInt(),
          (index) => {'weight': 0, 'reps': 0},
        ),
      });
    });
  }

  void _deleteExercise(String exerciseName) {
    setState(() {
      exerciseList.removeWhere((exercise) => exercise['name'] == exerciseName);
    });
  }
}

class CustomNavigationBar extends StatefulWidget
    implements ObstructingPreferredSizeWidget {
  const CustomNavigationBar({Key? key}) : super(key: key); // Add Key parameter

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();

  @override
  bool shouldFullyObstruct(BuildContext context) {
    // Return true if you want the custom navigation bar to fully obstruct content.
    // Return false if you want the content to be visible behind the custom navigation bar.
    return false;
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
