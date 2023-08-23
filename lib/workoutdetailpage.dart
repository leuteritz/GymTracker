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
    print(workoutDatesList);
    return LineChartSample2();
  }
}

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 12,
              bottom: 12,
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: CupertinoColors.activeBlue, width: 2),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          color: CupertinoColors.activeOrange,
          barWidth: 3,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                CupertinoColors.inactiveGray,
                CupertinoColors.systemPurple, // End color
              ],
            ),
          ),
        ),
      ],
    );
  }
}
