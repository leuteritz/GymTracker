import 'package:flutter/cupertino.dart';
import 'dart:async';
import '/data/database.dart';

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
  List<Map<String, dynamic>> maxWeightList = [];
  List<Map<String, dynamic>> maxRepsList = [];
  List<Map<String, dynamic>> maxDurationList = [];
  List<Map<String, dynamic>> _exerciseduration = [];
  int maxWeightRowIndex = -1;

  bool isDuration = false;
  bool isWeight = false;
  bool isRep = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getMaxWeightByExerciset();
    await _getMaxRepsByExerciset();
    await _getMaxDurationByExerciset();
    await getExercisesForDate(widget.date);
    await _getExerciseDuration();
    _getDuration();
    _getTotalWeight();
    _getStartTime();
    _setRecordsWeight();
    _setRecordsReps();
    _setRecordsDuration();
  }

  Future<void> _getMaxWeightByExerciset() async {
    List<Map<String, dynamic>> _maxWeightList =
        await DatabaseHelper().getAllMaxWeightByExercise();

    setState(() {
      maxWeightList = _maxWeightList;
    });
  }

  Future<void> _getMaxRepsByExerciset() async {
    List<Map<String, dynamic>> _maxRepsList =
        await DatabaseHelper().getAllMaxRepsByExercise();

    setState(() {
      maxRepsList = _maxRepsList;
    });
  }

  Future<void> _getMaxDurationByExerciset() async {
    List<Map<String, dynamic>> _maxDurationList =
        await DatabaseHelper().getAllMaxDurationByExercise();

    setState(() {
      maxDurationList = _maxDurationList;
    });
  }

  void _setRecordsWeight() async {
    for (Map<String, dynamic> exerciseInfo in maxWeightList) {
      if (widget.date == exerciseInfo['date']) {
        for (Map<String, dynamic> transformedExerciseInfo
            in transformedExercises) {
          dynamic sets = transformedExerciseInfo['sets'];

          if (exerciseInfo['name'] == transformedExerciseInfo['name']) {
            int maxWeight = exerciseInfo['max_weight'];

            for (Map<String, dynamic> set in sets) {
              int weight = set['weight'];

              if (weight == maxWeight) {
                setState(() {
                  set['isMaxWeight'] = true;
                });
                break;
              }
            }
          }
        }
      }
    }
  }

  void _setRecordsReps() async {
    for (Map<String, dynamic> exerciseInfo in maxRepsList) {
      if (widget.date == exerciseInfo['date']) {
        for (Map<String, dynamic> transformedExerciseInfo
            in transformedExercises) {
          dynamic sets = transformedExerciseInfo['sets'];

          if (exerciseInfo['name'] == transformedExerciseInfo['name']) {
            int maxReps = exerciseInfo['max_reps'];

            for (Map<String, dynamic> set in sets) {
              int reps = set['reps'];

              if (reps == maxReps) {
                setState(() {
                  set['isMaxReps'] = true;
                });
                break;
              }
            }
          }
        }
      }
    }
  }

  void _setRecordsDuration() async {
    for (Map<String, dynamic> exerciseInfo in maxDurationList) {
      if (widget.date == exerciseInfo['date']) {
        for (Map<String, dynamic> transformedExerciseInfo
            in transformedExercises) {
          String duration = transformedExerciseInfo['duration'];

          if (exerciseInfo['name'] == transformedExerciseInfo['name']) {
            String maxDuration = exerciseInfo['max_duration'];

            if (duration == maxDuration) {
              setState(() {
                transformedExerciseInfo['isMaxDuration'] = true;
              });
              break;
            }
          }
        }
      }
    }
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
  }

  List<Map<String, dynamic>> updateTransformedExercisesWithDurations() {
    // Create a map for exercise durations for quick lookup
    Map<String, String?> exerciseDurationsMap = {};
    for (var exercise in _exerciseduration) {
      exerciseDurationsMap[exercise['name']] = exercise['durationexercise'];
    }

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

  Future<void> getExercisesForDate(String date) async {
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
        'isMaxWeight': false,
        'isMaxReps': false,
      });
    }

    return exerciseMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
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
                    String exerciseName = exercise['name'];
                    bool isMaxDurationExercise =
                        exercise['isMaxDuration'] ?? false;

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
                        Stack(
                          children: [
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
                            if (set['isMaxWeight'])
                              Positioned(
                                right: 90,
                                child: Text("🏆"),
                              ),
                            if (set['isMaxReps'])
                              Positioned(
                                right: 0,
                                child: Text("🏆"),
                              ),
                          ],
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10), // Add horizontal padding
                              child: Center(
                                child: Text(
                                  exerciseName,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                        if (isMaxDurationExercise) // Check if it's a max duration exercise
                          Positioned(
                            top: 38,
                            right: 60,
                            child: Text("🏆"),
                          ),
                      ],
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
