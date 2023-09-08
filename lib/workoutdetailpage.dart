import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'database.dart';

class WorkoutDetailPage extends StatefulWidget {
  final String date;

  WorkoutDetailPage({required this.date});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  List<Map<String, dynamic>> exercisesForSelectedDate = [];
  List<Map<String, dynamic>> transformedExercises = [];
  String _duration = '';
  int _totalWeight = 0;
  String? _startTime = '';
  List<String> workoutDatesList = [];
  List<Map<String, dynamic>> _exerciseduration = [];

  @override
  void initState() {
    super.initState();
    _getExercisesForDate(widget.date);
    _getDuration();
    _getTotalWeight();
    _loadWorkoutDates();
    _getStartTime();
    _getExerciseDuration();
  }

  void _loadWorkoutDates() async {
    List<String> dates = await DatabaseHelper().getDates();
    setState(() {
      workoutDatesList = dates;
    });
  }

  Future<void> _getExerciseDuration() async {
    List<Map<String, dynamic>> exerciseduration =
        await DatabaseHelper().getExercisesWithDurationsByDate(widget.date);
    if (mounted) {
      setState(() {
        _exerciseduration = exerciseduration;
        // Update transformedExercises with durations
        transformedExercises = updateTransformedExercisesWithDurations();
      });
    }
    print("list: $_exerciseduration");
  }

  List<Map<String, dynamic>> updateTransformedExercisesWithDurations() {
    // Create a map for exercise durations for quick lookup
    Map<String, String?> exerciseDurationsMap = {};
    for (var exercise in _exerciseduration) {
      exerciseDurationsMap[exercise['name']] = exercise['durationexercise'];
    }

    print("map: $exerciseDurationsMap");

    // Update transformedExercises with durations
    List<Map<String, dynamic>> updatedTransformedExercises = [];
    for (var exercise in transformedExercises) {
      String exerciseName = exercise['name'];
      String? duration = exerciseDurationsMap[exerciseName] ?? '00:00';

      Map<String, dynamic> updatedExercise = {
        ...exercise,
        'duration': duration,
      };
      updatedTransformedExercises.add(updatedExercise);
    }

    return updatedTransformedExercises;
  }

  Future<void> _getTotalWeight() async {
    int totalWeight = await DatabaseHelper().getTotalWeight(widget.date);
    setState(() {
      _totalWeight = totalWeight;
    });
  }

  Future<void> _getStartTime() async {
    String? startTime = await DatabaseHelper().getStartTime(widget.date);

    setState(() {
      _startTime = startTime;
    });
  }

  Future<void> _getDuration() async {
    String duration = await DatabaseHelper().getDuration(widget.date);
    setState(() {
      _duration = duration;
    });
  }

  void _getExercisesForDate(String date) async {
    List<Map<String, dynamic>> exercises =
        await DatabaseHelper().getAllInformationByDate(date);
    exercisesForSelectedDate = exercises;
    setState(() {
      transformedExercises = transformExercisesFormat(); // Update here
    });
  }

  List<Map<String, dynamic>> transformExercisesFormat() {
    Map<String, Map<String, dynamic>> exerciseMap = {};

    for (var exercise in exercisesForSelectedDate) {
      String name = exercise['name']!;
      String exerciseDate = exercise['date']!;
      String key = '$name-$exerciseDate';

      if (!exerciseMap.containsKey(key)) {
        exerciseMap[key] = {
          'name': name,
          'date': exerciseDate,
          'sets': [],
        };
      }

      exerciseMap[key]!['sets'].add({
        'weight': exercise['weight']!,
        'reps': exercise['reps']!,
      });
    }

    return exerciseMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    print("Exercises for selected date: $transformedExercises");
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.date),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 10), // Add horizontal padding
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(children: [
                        Icon(
                          CupertinoIcons.time_solid,
                          color: CupertinoColors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          _startTime!,
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ]),
                      Row(children: [
                        Icon(
                          CupertinoIcons.time,
                          color: CupertinoColors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          _duration,
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ]),
                      Row(children: [
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: transformedExercises.map<Widget>((exercise) {
                    print(transformedExercises);
                    String exerciseName = exercise['name'];
                    List<Map<String, dynamic>> sets =
                        List<Map<String, dynamic>>.from(exercise['sets']);

                    // Generate set rows
                    List<Widget> setRows = [];
                    for (int i = 0; i < sets.length; i++) {
                      Map<String, dynamic> set = sets[i];
                      int setNumber = i + 1;
                      int weight = set['weight'];
                      int reps = set['reps'];

                      setRows.add(
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Expanded(
                                // Adjust the padding as needed
                                child: Center(
                                  child: Text(
                                    '$setNumber',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '$weight',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ),
                              ),
                              Expanded(
                                // Adjust the padding as needed
                                child: Center(
                                  child: Text(
                                    '$reps',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10), // Add horizontal padding
                            child: Center(
                              child: Text(
                                exerciseName,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.time,
                                color: CupertinoColors.systemGrey,
                              ),
                              SizedBox(width: 10),
                              Text(
                                exercise.containsKey('duration')
                                    ? exercise['duration']
                                    : '00:00',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: CupertinoColors.systemGrey),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'Set',
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Weight (kg)',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'Reps',
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ),
                                  ]),
                              SizedBox(height: 10),
                              Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              ...setRows, // Spread set rows using the spread operator
                              SizedBox(
                                  height: 8), // Add spacing between exercises
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
