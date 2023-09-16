import 'package:flutter/cupertino.dart';
import 'chartload.dart';
import 'chartweight.dart';
import 'chartreps.dart';

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
                              style: TextStyle(fontSize: 22),
                            ),
                            'chart':
                                Text('Chart', style: TextStyle(fontSize: 22)),
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
                        )
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
