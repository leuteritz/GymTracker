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
  int _selectedIndex = 0;
  List<Map<String, dynamic>> exercisesForSelectedDate = [];
  List<Map<String, dynamic>> transformedExercises = [];
  String _duration = '';
  int _totalWeight = 0;

  @override
  void initState() {
    super.initState();
    _getExercisesForDate(widget.date);
    _getDuration();
    _getTotalWeight();
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.date),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: CupertinoSegmentedControl(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                children: {
                  0: Padding(
                    padding: EdgeInsets.all(10), // Add the desired padding here
                    child: Text('Exercises'),
                  ),
                  1: Padding(
                    padding: EdgeInsets.all(10), // Add the desired padding here
                    child: Text('Stats'),
                  ),
                },
                onValueChanged: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                groupValue: _selectedIndex,
              ),
            ),
            SizedBox(height: 20),
            _selectedIndex == 0 ? _buildExerciseList() : _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 50), // Add horizontal padding

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(children: [
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
              ),
              Container(
                child: Row(children: [
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
              )
            ],
          ),
        ),
        SizedBox(height: 16),
        Column(
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
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Set $setNumber: Weight: $weight Reps: $reps',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      exerciseName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...setRows, // Spread set rows using the spread operator
                    SizedBox(height: 8), // Add spacing between exercises
                  ],
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Center(
      child: Text('Statistics'),
    );
  }
}
