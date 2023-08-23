import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'database.dart';
import 'dart:async';
import 'exerciselabel.dart';

class BreakTimer extends StatefulWidget {
  @override
  State<BreakTimer> createState() => _BreakTimerState();
}

class _BreakTimerState extends State<BreakTimer> {
  Timer? _timer;
  double _seconds = 0;
  String _timerValue = 'Pause';

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
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
          _updateTimerValue();
        });
      } else {
        _timer?.cancel();
        _showBreakTimerEndModal(context);
        Timer.periodic(Duration(seconds: 1), (timer) {
          SystemSound.play(SystemSoundType.click);
          if (timer.tick == 3) {
            timer.cancel();
          }
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  // Function to open the modal view
  void _showBreakTimerModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 32,
            children: List<Widget>.generate(8, (index) {
              String timeValue = '${index / 2 + 0.5} min';
              return Text(timeValue);
            }),
            onSelectedItemChanged: (index) {
              setState(() {
                _seconds = (index + 1) * 60 * 0.5;
                _startTimer();
                _updateTimerValue();
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
        _showBreakTimerModal(context);
        _stopTimer();
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                CupertinoIcons.pause_rectangle_fill,
                size: 25,
              ),
              // Add some spacing between the icon and text
              Text(
                _timerValue,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  Timer? _timer;
  int _seconds = 0;
  String _timerValue = '00:00';
  String _duration = '';

  void _updateTimerValue() {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = _seconds % 60;
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    setState(() {
      _timerValue = '$formattedMinutes:$formattedSeconds';
    });
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

    // insert the exercise into the database
    for (var exercise in exerciseList) {
      String name = exercise['name'];
      String date = exercise['date'];
      List<Map<String, int>> sets = exercise['sets'];
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
        );
      }
    }
    DatabaseHelper().insertExercise(
      name: "nam",
      sets: 3,
      weight: 4,
      reps: 5,
      date: "15.09.2021",
      duration: _duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BreakTimer(),
          // Add some spacing between the break timer and text
          Container(
            width: MediaQuery.of(context).size.width / 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  CupertinoIcons.stopwatch_fill,
                  size: 25,
                ),
                Text(
                  _timerValue,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 4,
          )
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

  double _currentSliderValue = 2;
  String _selectedExercise = 'Select Exercise';

  bool _isAddButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(key: _key),
      child: SafeArea(
        child: Stack(
          children: [
            CupertinoScrollbar(
              child: CustomScrollView(
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
            ),
            Positioned(
              bottom: 5,
              right: 5,
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
              bottom: 5,
              left: 5,
              child: Visibility(
                visible: _isAddButtonPressed,
                child: CupertinoButton(
                  onPressed: () {
                    _key.currentState?._stopTimer();
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
          ],
        ),
      ),
    );
  }

  // function to open modal view
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
                          _showExerciseList(context, setState);
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
                                // Update the slider value when dragging
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
                          // Close the modal
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
            backgroundColor: CupertinoColors.systemGrey6,
            itemExtent: 32, // Height of each item in the list
            onSelectedItemChanged: (int index) {
              setState(() {
                // Update the selected exercise label
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
