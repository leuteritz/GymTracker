import 'package:flutter/cupertino.dart';
import 'database.dart';
import 'workoutdateitem.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<String> workoutDatesList = [];
  List<String> filteredWorkoutDatesList = [];

  void loadWorkoutDates() async {
    List<String> dates = await DatabaseHelper().getDates();
    setState(() {
      workoutDatesList = dates;
      filteredWorkoutDatesList = dates;
    });
  }

  void _searchWorkoutDates(String searchText) {
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
