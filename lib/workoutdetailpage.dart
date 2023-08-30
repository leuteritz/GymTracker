import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'database.dart';
import 'package:fl_chart/fl_chart.dart';

class WorkoutDetailPage extends StatefulWidget {
  final String date;

  WorkoutDetailPage({required this.date});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> exercisesForSelectedDate = [];
  List<Map<String, dynamic>> transformedExercises = [];
  String _duration = '';
  int _totalWeight = 0;
  List<String> workoutDatesList = [];

  @override
  void initState() {
    super.initState();
    _getExercisesForDate(widget.date);
    _getDuration();
    _getTotalWeight();
    _loadWorkoutDates();
  }

  void _loadWorkoutDates() async {
    List<String> dates = await DatabaseHelper().getDates();
    setState(() {
      workoutDatesList = dates;
    });
  }

  Future<void> _getTotalWeight() async {
    int totalWeight = await DatabaseHelper().getTotalWeight(widget.date);
    setState(() {
      _totalWeight = totalWeight;
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
          decoration: BoxDecoration(
            border: Border.all(
              color: CupertinoColors.systemGrey,
              width: 4.0,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.3),
                spreadRadius: 10,
                blurRadius: 20,
              ),
            ],
          ),
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
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: transformedExercises.map<Widget>((exercise) {
                    // Extract exercise information
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
