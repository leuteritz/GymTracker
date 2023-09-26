import 'package:flutter/cupertino.dart';
import '/screens/exerciseScreen.dart';
import '/screens/homeScreen.dart';
import '/screens/historyScreen.dart';
import '../data/insertExercise.dart';
import '/screens/mapScreen.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<HistoryScreenState> historyKey = GlobalKey<HistoryScreenState>();
  GlobalKey<ExerciseScreenState> exerciseKey = GlobalKey<ExerciseScreenState>();

  int _selectedIndex = 1;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        historyKey.currentState?.loadWorkoutDates();
      }
      if (index == 0) {
        exerciseKey.currentState?.fetchExercises(setState);
      }
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
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map),
            label: 'Map',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return ExerciseScreen(
              key: exerciseKey,
            );
          case 1:
            return HomeScreen();
          case 2:
            return HistoryScreen(
              key: historyKey,
            );
          case 3:
            return MapScreen();
          default:
            return HomeScreen();
        }
      },
    );
  }
}
