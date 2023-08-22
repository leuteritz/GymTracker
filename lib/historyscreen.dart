import 'package:flutter/cupertino.dart';
import 'database.dart';
import 'workoutdateitem.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> workoutDatesList = [];
  List<String> filteredWorkoutDatesList = [];

  @override
  void initState() {
    super.initState();
    _loadWorkoutDates();
  }

  void _loadWorkoutDates() async {
    List<String> dates = await DatabaseHelper().getDates();
    setState(() {
      workoutDatesList = dates;
      filteredWorkoutDatesList = dates;
    });
  }

  void _searchWorkoutDates(String searchText) {
    // If there is a search text, filter the workout dates accordingly
    setState(() {
      filteredWorkoutDatesList = workoutDatesList
          .where((date) => date.startsWith(searchText))
          .toList();
    });
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
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final date = filteredWorkoutDatesList[index];
                    return WorkoutDateItem(date: date);
                  },
                  childCount: filteredWorkoutDatesList.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
