import 'package:flutter/cupertino.dart';
import 'exercisescreen.dart';
import 'homescreen.dart';
import 'historyscreen.dart';
import 'insertexercise.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();

  int _selectedIndex = 1;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    insertExercises();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.systemGrey6,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return ExerciseScreen();
          case 1:
            return HomeScreen();
          case 2:
            load(); // Call the load function here
            return HistoryScreen(
              key: _historyKey,
            );
          default:
            return HomeScreen();
        }
      },
    );
  }

  void load() {
    _historyKey.currentState?.loadWorkoutDates();
  }
}
