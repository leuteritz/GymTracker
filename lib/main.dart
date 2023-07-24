import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

List<Map<String, dynamic>> _exerciseList = []; // Global exerciseList variable

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color.fromARGB(255, 173, 15, 226);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CupertinoApp(
        title: 'My Gym Tracker App',
        home: MyHomePage(),
        theme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: primaryColor,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.systemGrey6,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            label: 'Home',
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
            return Foodscreen();
          case 1:
            return HomeScreen();
          case 2:
            return SettingsScreen();
          default:
            return HomeScreen();
        }
      },
    );
  }
}

class Foodscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Text('Food Screen'),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _currentSliderValue = 2;
  String _selectedExercise = 'Select Exercise';

  @override
  Widget build(BuildContext context) {
    print("Exercise List $_exerciseList");
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('GymTracker'),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            CupertinoScrollbar(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final exercise = _exerciseList[index];
                        return ExerciseLabel(
                          key: Key('exercise_${exercise['name']}_$index'),
                          exercise: exercise['name'],
                          sets: exercise['sets'],
                        );
                      },
                      childCount: _exerciseList.length,
                    ),
                  ),
                  // Add more Sliver widgets as needed for additional content
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: CupertinoButton(
                onPressed: () {
                  _showCupertinoModal(context);
                },
                child: Icon(CupertinoIcons.add_circled_solid, size: 60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // function to open modal view
  void _showCupertinoModal(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double modalHeight = screenHeight * 0.3;
    final double modalWidth = screenWidth * 0.8;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: modalWidth,
            height: modalHeight,
            child: CupertinoPopupSurface(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        color: CupertinoColors.activeOrange,
                        onPressed: () {
                          _showExerciseList(context, setState);
                        },
                        child: Text(_selectedExercise),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Text('Sets: ${_currentSliderValue.toInt()}'),
                            CupertinoSlider(
                              value: _currentSliderValue,
                              min: 2.0,
                              max: 5.0,
                              divisions: 3,
                              onChanged: (value) {
                                // Update the slider value when dragging
                                setState(() {
                                  _currentSliderValue = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        color: CupertinoColors.activeBlue,
                        child: Text('Add'),
                        onPressed: () {
                          // Close the modal
                          Navigator.of(context).pop();
                          _addExerciseToList();
                        },
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // function to open exercise list
  void _showExerciseList(BuildContext context, StateSetter setState) {
    final List<String> exercises = [
      'Bench Press',
      'Squat',
      'Deadlift',
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemGrey6,
            itemExtent: 32, // Height of each item in the list
            onSelectedItemChanged: (int index) {
              setState(() {
                // Update the selected exercise label
                _selectedExercise = exercises[index];
              });
            },
            children: exercises.map((exercise) => Text(exercise)).toList(),
          ),
        );
      },
    );
  }

  // function to add exercise to the list
  void _addExerciseToList() {
    setState(() {
      _exerciseList.add({
        'name': _selectedExercise,
        'sets': List.generate(
          _currentSliderValue.toInt(),
          (index) => {'weight': 0, 'reps': 0},
        ),
      });
    });
  }
}

class ExerciseLabel extends StatefulWidget {
  final String exercise;
  final List<Map<String, int>> sets;

  ExerciseLabel({
    required Key key,
    required this.exercise,
    required this.sets,
  }) : super(key: key);

  @override
  _ExerciseLabelState createState() => _ExerciseLabelState();
}

class _ExerciseLabelState extends State<ExerciseLabel> {
  void _removeSetFromGlobalList(int index) {
    setState(() {
      widget.sets.removeAt(index);
      _exerciseList.removeWhere((exercise) =>
          exercise['name'] == widget.exercise && exercise['sets'] == index);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Exercise Label ${widget.exercise}");
    print("Exericse set ${widget.sets}");
    print("Exercise List $_exerciseList");

    return Container(
      padding: EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20),
      child: Column(
        children: [
          Text(
            widget.exercise,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Use ListView with shrinkWrap to fit its content without scrolling
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Disable scrolling
            itemCount: widget.sets.length,
            itemBuilder: (context, index) {
              final set = widget.sets[index];
              return Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  _removeSetFromGlobalList(index);
                },
                background: Container(
                  color: CupertinoColors.systemRed,
                ),
                child: ListItem(
                  index: index,
                  weight: set['weight']!,
                  reps: set['reps']!,
                ),
              );
            },
          ),
          SizedBox(height: 10),
          CupertinoButton(
              color: CupertinoColors.activeGreen,
              child: Text('Add Set'),
              onPressed: () {
                setState(() {
                  widget.sets.add({'weight': 0, 'reps': 0});
                });
              })
        ],
      ),
    );
  }
}

class ListItem extends StatefulWidget {
  int index;
  int weight;
  int reps;

  ListItem({
    required this.index,
    required this.weight,
    required this.reps,
  });

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();

  void updateWeight(String value) {
    setState(() {
      widget.weight = int.tryParse(value) ?? 0;
    });
  }

  void updateReps(String value) {
    setState(() {
      widget.reps = int.tryParse(value) ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    weightController.text = widget.weight == 0 ? '' : widget.weight.toString();
    repsController.text = widget.reps == 0 ? '' : widget.reps.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Set ${widget.index + 1}:'),
          SizedBox(width: 10),
          Expanded(
            child: CupertinoTextField(
              keyboardType: TextInputType.number,
              controller: weightController,
              onChanged: updateWeight,
              placeholder: 'Weight',
              textAlign: TextAlign.center,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBrown,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: CupertinoTextField(
              keyboardType: TextInputType.number,
              controller: repsController,
              onChanged: updateReps,
              placeholder: 'Reps',
              textAlign: TextAlign.center,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBrown,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}
