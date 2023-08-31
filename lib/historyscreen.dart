import 'package:flutter/cupertino.dart';
import 'database.dart';
import 'workoutdateitem.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<String> filteredWorkoutDatesList = [];
  Map<String, List<String>> filteredGroups = {};

  Map<String, List<String>> groupedWorkoutDates = {};

  @override
  void initState() {
    super.initState();
    loadWorkoutDates();
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Unknown';
    }
  }

  Map<String, List<String>> groupDatesByMonthAndYear(List<String> dates) {
    Map<String, List<String>> groupedDates = {};

    for (String date in dates) {
      List<String> dateParts = date.split('.');
      if (dateParts.length != 3) {
        // Handle invalid date format
        continue;
      }

      int month = int.tryParse(dateParts[1]) ?? 1;
      int year = int.tryParse(dateParts[2]) ?? DateTime.now().year;

      String monthName =
          _getMonthName(month); // Implement _getMonthName function
      String monthYearKey = '$monthName $year';
      // Format the date as "Month Year"

      if (groupedDates.containsKey(monthYearKey)) {
        groupedDates[monthYearKey]!.add(date);
      } else {
        groupedDates[monthYearKey] = [date];
      }
    }

    return groupedDates;
  }

  void loadWorkoutDates() async {
    List<String> dates = await DatabaseHelper().getDates();
    Map<String, List<String>> groupedDates = groupDatesByMonthAndYear(dates);

    setState(() {
      filteredGroups = groupedDates;
      groupedWorkoutDates = groupedDates;
    });
  }

  void _searchWorkoutDates(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        filteredGroups = groupedWorkoutDates;
      });
    } else {
      Map<String, List<String>> newFilteredGroups = {};
      for (String groupKey in groupedWorkoutDates.keys) {
        List<String> filteredDates = groupedWorkoutDates[groupKey]!
            .where((date) => date.startsWith(searchText))
            .toList();
        if (filteredDates.isNotEmpty) {
          newFilteredGroups[groupKey] = filteredDates;
        }
      }
      setState(() {
        filteredGroups = newFilteredGroups;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: SizedBox(
          width: 150,
          child: CupertinoSearchTextField(
            placeholder: 'Workout durchsuchen',
            onChanged: _searchWorkoutDates,
          ),
        ),
      ),
      child: SafeArea(
        child: CupertinoScrollbar(
          child: ListView.builder(
            itemCount: filteredGroups.length,
            itemBuilder: (context, index) {
              String monthYearKey = filteredGroups.keys.elementAt(index);
              List<String> datesForMonthYear = filteredGroups[monthYearKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      monthYearKey,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: datesForMonthYear.length,
                    itemBuilder: (context, subIndex) {
                      final date = datesForMonthYear[subIndex];
                      return WorkoutDateItem(
                        date: date,
                        key: Key(date),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
