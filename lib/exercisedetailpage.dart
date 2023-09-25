import 'package:flutter/cupertino.dart';
import 'chartload.dart';
import 'chartweight.dart';
import 'chartreps.dart';
import 'database.dart';
import 'workoutdetailpage.dart';

class ExerciseDetailPage extends StatefulWidget {
  final String exercise;
  final String description;

  ExerciseDetailPage({required this.exercise, required this.description});
  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  GlobalKey<LineChartSampleLoadState> _chartKey1 =
      GlobalKey<LineChartSampleLoadState>();
  GlobalKey<LineChartSampleWeightState> _chartKey2 =
      GlobalKey<LineChartSampleWeightState>();
  GlobalKey<LineChartSampleRepsState> _chartKey3 =
      GlobalKey<LineChartSampleRepsState>();

  int _selectedMonthIndex = DateTime.now().month - 1;
  String _currentWeek = '';
  int selectedYear = DateTime.now().year;
  int descriptionLines = 0;
  String _selectedContent = 'description'; // Add this line

  String _selectedInterval = 'week';
  List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    getCurrentWeekDateRange();
    _getMaxWeight();
    _getMaxReps();
    _getMaxLoad();
    _getAvgWeight();
    _getAvgReps();
    _getAvgLoad();
    _getMinWeight();
    _getMinReps();
    _getMinLoad();
    _getMaxDuration();
    _getMinDuration();
    _getAvgDuration();
  }

  void getCurrentWeekDateRange() {
    if (_selectedMonthIndex == DateTime.now().month - 1) {
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));
      String startDateString =
          "${startOfWeek.day.toString().padLeft(2, '0')}.${startOfWeek.month.toString().padLeft(2, '0')}";
      String endDateString =
          "${endOfWeek.day.toString().padLeft(2, '0')}.${endOfWeek.month.toString().padLeft(2, '0')}";
      _currentWeek = "$startDateString - $endDateString";
    } else {
      DateTime now = DateTime(selectedYear, _selectedMonthIndex + 1, 1);
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));
      String startDateString =
          "${startOfWeek.day.toString().padLeft(2, '0')}.${startOfWeek.month.toString().padLeft(2, '0')}";
      String endDateString =
          "${endOfWeek.day.toString().padLeft(2, '0')}.${endOfWeek.month.toString().padLeft(2, '0')}";
      _currentWeek = "$startDateString - $endDateString";
    }
  }

  void _showCupertinoModalWeek(BuildContext context, setState) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        List<String> weekWidgets = [];

        DateTime firstDayOfMonth =
            DateTime.utc(selectedYear, _selectedMonthIndex + 1, 1);
        DateTime lastDayOfMonth =
            DateTime.utc(selectedYear, _selectedMonthIndex + 2, 0);

        // Find the closest Monday that is before the first day of the month.
        while (firstDayOfMonth.weekday != 1) {
          firstDayOfMonth = firstDayOfMonth.subtract(Duration(days: 1));
        }

        DateTime currentDay = firstDayOfMonth;

        while (currentDay.isBefore(lastDayOfMonth)) {
          DateTime startOfWeek = currentDay;
          DateTime endOfWeek = currentDay.add(Duration(days: 6));
          String startDateString =
              "${startOfWeek.day.toString().padLeft(2, '0')}.${startOfWeek.month.toString().padLeft(2, '0')}";
          String endDateString =
              "${endOfWeek.day.toString().padLeft(2, '0')}.${endOfWeek.month.toString().padLeft(2, '0')}";
          String weekDateRange = '$startDateString - $endDateString';

          weekWidgets.add(weekDateRange);

          currentDay = currentDay.add(Duration(days: 7));
        }

        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 27,
            onSelectedItemChanged: (int index) {
              setState(() {
                _currentWeek = weekWidgets[index].toString();
                _chartKey1.currentState?.getWeek(_currentWeek);
                _chartKey1.currentState?.getInformation(_selectedInterval);
                _chartKey2.currentState?.getWeek(_currentWeek);
                _chartKey2.currentState?.getInformation(_selectedInterval);
                _chartKey3.currentState?.getWeek(_currentWeek);
                _chartKey3.currentState?.getInformation(_selectedInterval);
              });
            },
            children: List<Widget>.generate(weekWidgets.length, (int index) {
              return Center(
                child: Text(weekWidgets[index]),
              );
            }),
          ),
        );
      },
    );
  }

  void _showCupertinoModalMonth(BuildContext context, setState) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 27,
            looping: true,
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedMonthIndex = index;
                _chartKey1.currentState?.getMonth(_selectedMonthIndex);
                _chartKey1.currentState?.getInformation(_selectedInterval);
                _chartKey2.currentState?.getMonth(_selectedMonthIndex);
                _chartKey2.currentState?.getInformation(_selectedInterval);
                _chartKey3.currentState?.getMonth(_selectedMonthIndex);
                _chartKey3.currentState?.getInformation(_selectedInterval);
                getCurrentWeekDateRange();
              });
            },
            children: List<Widget>.generate(monthNames.length, (int index) {
              return Center(
                child: Text(monthNames[index]),
              );
            }),
          ),
        );
      },
    );
  }

  void _showCupertinoModalYear(BuildContext context, setState) {
    int currentYear = 2023;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground,
            itemExtent: 27,
            looping: true,
            onSelectedItemChanged: (int index) {
              setState(() {
                selectedYear = currentYear + index;
                _chartKey1.currentState?.getYear(selectedYear);
                _chartKey1.currentState?.getInformation(_selectedInterval);
                _chartKey2.currentState?.getYear(selectedYear);
                _chartKey2.currentState?.getInformation(_selectedInterval);
                _chartKey3.currentState?.getYear(selectedYear);
                _chartKey3.currentState?.getInformation(_selectedInterval);
              });
            },
            children:
                List<Widget>.generate(2100 - currentYear + 1, (int index) {
              return Center(
                child: Text((currentYear + index).toString()),
              );
            }),
          ),
        );
      },
    );
  }

  int maxWeight = 0;
  int minWeight = 0;
  double avgWeight = 0.0;
  String dateWeightMax = '';
  String dateWeightMin = '';
  int maxReps = 0;
  int minReps = 0;
  double avgReps = 0.0;
  String dateRepsMax = '';
  String dateRepsMin = '';
  int maxLoad = 0;
  int minLoad = 0;
  double avgLoad = 0.0;
  String dateLoadMax = '';
  String dateLoadMin = '';
  String maxDuration = '';
  String minDuration = '';
  String avgDuration = '';
  String dateDurationMax = '';
  String dateDurationMin = '';

  Future<void> _getMaxWeight() async {
    final map = await DatabaseHelper().getMaxWeight(widget.exercise);

    if (mounted) {
      setState(() {
        maxWeight = map['max_weight'] ?? 0;
        dateWeightMax = map['date'] ?? 'No data';
      });
    }
  }

  Future<void> _getMinWeight() async {
    final map = await DatabaseHelper().getMinWeight(widget.exercise);

    if (mounted) {
      setState(() {
        print(map['min_weight']);
        minWeight = map['min_weight'] ?? 0;
        dateWeightMin = map['date'] ?? 'No data';
      });
    }
  }

  Future<void> _getAvgWeight() async {
    final map = await DatabaseHelper().getAverageWeight(widget.exercise);

    if (mounted) {
      setState(() {
        avgWeight = map['avg_weight'] ?? 0;
      });
    }
  }

  Future<void> _getMaxReps() async {
    final map = await DatabaseHelper().getMaxReps(widget.exercise);

    if (mounted) {
      setState(() {
        maxReps = map['max_reps'] ?? 0;
        dateRepsMax = map['date'] ?? 'No data';
      });
    }
  }

  Future<void> _getMinReps() async {
    final map = await DatabaseHelper().getMinReps(widget.exercise);

    if (mounted) {
      setState(() {
        minReps = map['min_reps'] ?? 0;
        dateRepsMin = map['date'] ?? 'No data';
      });
    }
  }

  Future<void> _getAvgReps() async {
    final map = await DatabaseHelper().getAverageReps(widget.exercise);

    if (mounted) {
      setState(() {
        avgReps = map['avg_reps'] ?? 0;
      });
    }
  }

  Future<void> _getMaxLoad() async {
    final map = await DatabaseHelper().getMaxLoad(widget.exercise);

    if (mounted) {
      setState(() {
        maxLoad = map['max_load'] ?? 0;
        dateLoadMax = map['date'] ?? 'No data';
      });
    }
  }

  Future<void> _getMinLoad() async {
    final map = await DatabaseHelper().getMinLoad(widget.exercise);

    if (mounted) {
      setState(() {
        minLoad = map['min_load'] ?? 0;
        dateLoadMin = map['date'] ?? 'No data';
      });
    }
  }

  Future<void> _getAvgLoad() async {
    final map = await DatabaseHelper().getAverageLoad(widget.exercise);

    if (mounted) {
      setState(() {
        avgLoad = map['avg_load'] ?? 0;
      });
    }
  }

  Future<void> _getMaxDuration() async {
    final map = await DatabaseHelper().getMaxDuration(widget.exercise);

    if (mounted) {
      setState(() {
        maxDuration = map['max_duration'] ?? '00:00';
        dateDurationMax = map['date'] ?? 'No data';
      });
    }
  }

  Future<void> _getMinDuration() async {
    final map = await DatabaseHelper().getMinDuration(widget.exercise);

    if (mounted) {
      setState(() {
        minDuration = map['min_duration'] ?? '00:00';
        dateDurationMin = map['date'] ?? 'No data';
      });
    }
  }

  Future<void> _getAvgDuration() async {
    final map = await DatabaseHelper().getAverageDuration(widget.exercise);

    if (mounted) {
      setState(() {
        double _avgDuration = map['avg_duration'] ?? 0;
        int minutes = _avgDuration.floor();
        int seconds = ((_avgDuration - minutes) * 100).round();

        if (seconds >= 60) {
          minutes += seconds ~/ 60;
          seconds %= 60;
        }
        avgDuration =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> descriptionLines = widget.description.split('\n');
    int descriptionLength = descriptionLines.length;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.exercise),
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                        width: MediaQuery.of(context).size.width,
                        child: CupertinoSegmentedControl(
                          children: {
                            'description': Text(
                              'Instructions',
                              style: TextStyle(fontSize: 20),
                            ),
                            'chart':
                                Text('Chart', style: TextStyle(fontSize: 20)),
                            'records':
                                Text('Records', style: TextStyle(fontSize: 20)),
                          },
                          onValueChanged: (value) {
                            setState(() {
                              _selectedContent = value;
                            });
                          },
                          groupValue: _selectedContent,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (_selectedContent == 'description')
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Image.asset('assets/benchpress.gif')),
                              SizedBox(height: 20),
                              Text(
                                "Instructions",
                                style: TextStyle(fontSize: 30),
                              ),
                              Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Column(
                                    children: List<Widget>.generate(
                                      descriptionLength,
                                      (index) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: Center(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                        width: 50,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          '${index + 1}.',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                      child: Text(
                                                          descriptionLines[
                                                              index],
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                          textAlign:
                                                              TextAlign.left),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_selectedContent == 'chart')
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 0),
                                width: MediaQuery.of(context).size.width,
                                child: CupertinoSegmentedControl(
                                  children: {
                                    'week': Text('Week'),
                                    'month': Text('Month'),
                                    'year': Text('Year'),
                                  },
                                  onValueChanged: (value) {
                                    getCurrentWeekDateRange();
                                    setState(() {
                                      _selectedInterval = value;
                                    });
                                    _chartKey1.currentState
                                        ?.getInformation(_selectedInterval);
                                    _chartKey2.currentState
                                        ?.getInformation(_selectedInterval);
                                    _chartKey3.currentState
                                        ?.getInformation(_selectedInterval);
                                  },
                                  groupValue: _selectedInterval,
                                ),
                              ),
                              SizedBox(height: 10),
                              if (_selectedInterval == 'week')
                                GestureDetector(
                                  onTap: () {
                                    setState(() {});
                                    _showCupertinoModalWeek(context, setState);
                                  },
                                  child: Text(
                                    _currentWeek +
                                        "." +
                                        selectedYear.toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              if (_selectedInterval == 'month')
                                GestureDetector(
                                  onTap: () {
                                    setState(() {});
                                    _showCupertinoModalMonth(context, setState);
                                  },
                                  child: Text(
                                    monthNames[_selectedMonthIndex] +
                                        " " +
                                        selectedYear.toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              if (_selectedInterval == 'year')
                                GestureDetector(
                                  onTap: () {
                                    setState(() {});
                                    _showCupertinoModalYear(context, setState);
                                  },
                                  child: Text(
                                    selectedYear.toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              Column(
                                children: [
                                  LineChartSampleLoad(
                                    key: _chartKey1,
                                    exercise: widget.exercise,
                                    selectedInterval: _selectedInterval,
                                    currentWeek: _currentWeek,
                                    currentMonth: _selectedMonthIndex,
                                    currentYear: selectedYear,
                                  ),
                                  LineChartSampleWeight(
                                    key: _chartKey2,
                                    exercise: widget.exercise,
                                    selectedInterval: _selectedInterval,
                                    currentWeek: _currentWeek,
                                    currentMonth: _selectedMonthIndex,
                                    currentYear: selectedYear,
                                  ),
                                  LineChartSampleReps(
                                    key: _chartKey3,
                                    exercise: widget.exercise,
                                    selectedInterval: _selectedInterval,
                                    currentWeek: _currentWeek,
                                    currentMonth: _selectedMonthIndex,
                                    currentYear: selectedYear,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      if (_selectedContent == 'records')
                        SingleChildScrollView(
                            child: Column(children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          10), // Adjust the padding as needed
                                  child: Center(
                                    child: Text(
                                      "Weight",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          10), // Adjust the padding as needed
                                  child: Center(
                                    child: Text(
                                      "Reps",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          10), // Adjust the padding as needed
                                  child: Center(
                                    child: Text(
                                      "Load",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          10), // Adjust the padding as needed
                                  child: Center(
                                    child: Text(
                                      "Duration",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                            ),
                          ),
                          SizedBox(height: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Maximum  🏆 :",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "${maxWeight.toString()} kg",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  WorkoutDetailPage(
                                                date: dateWeightMax,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          dateWeightMax,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CupertinoColors.systemGrey,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("${maxReps.toString()}",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  WorkoutDetailPage(
                                                date: dateRepsMax,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          dateRepsMax,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CupertinoColors.systemGrey,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("${maxLoad.toString()} kg",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  WorkoutDetailPage(
                                                date: dateLoadMax,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          dateLoadMax,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CupertinoColors.systemGrey,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(maxDuration,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  WorkoutDetailPage(
                                                date: dateDurationMax,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          dateDurationMax,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CupertinoColors.systemGrey,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 40),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Minimum 🤏 :",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "${minWeight.toString()} kg",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  WorkoutDetailPage(
                                                date: dateWeightMin,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          dateWeightMin,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CupertinoColors.systemGrey,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("${minReps.toString()}",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  WorkoutDetailPage(
                                                date: dateRepsMin,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          dateRepsMin,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CupertinoColors.systemGrey,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("${minLoad.toString()} kg",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  WorkoutDetailPage(
                                                date: dateLoadMin,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          dateLoadMin,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CupertinoColors.systemGrey,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(minDuration,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  WorkoutDetailPage(
                                                date: dateDurationMin,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          dateDurationMin,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CupertinoColors.systemGrey,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 40),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Average  😐 :",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "${avgWeight.toStringAsFixed(1)} kg",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${avgReps.toStringAsFixed(1)}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${avgLoad.toStringAsFixed(1)} kg",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    avgDuration,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Badges :",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ])),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
