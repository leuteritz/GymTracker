import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'database.dart';

// TODO: add a checker to see if the exercise already exists
void main() {
  runApp(const MyApp());
}

List<Map<String, dynamic>> _exerciseList = [];

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
            return HomeScreen(); // Pass the _key to the HomeScreen widget
          case 2:
            return HistoryScreen();

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

class CustomNavigationBar extends StatefulWidget
    implements ObstructingPreferredSizeWidget {
  const CustomNavigationBar({Key? key}) : super(key: key); // Add Key parameter

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();

  @override
  bool shouldFullyObstruct(BuildContext context) {
    // Return true if you want the custom navigation bar to fully obstruct content.
    // Return false if you want the content to be visible behind the custom navigation bar.
    return false;
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  Timer? _timer;
  int _seconds = 0;
  String _timerValue = '00:00';
  String _duration = '';

  void _updateTimerValue() {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = _seconds % 60;
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    setState(() {
      _timerValue = '$formattedMinutes:$formattedSeconds';
    });
  }

  // Start the timer that runs every second
  void _startTimer() {
    _timer?.cancel(); // Cancel any previous timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _updateTimerValue();
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();

    _duration = _timerValue;

    // insert the exercise into the database
    for (var exercise in _exerciseList) {
      String name = exercise['name'];
      String date = exercise['date'];
      List<Map<String, int>> sets = exercise['sets'];
      for (var set in sets) {
        int reps = set['reps']!;
        int weight = set['weight']!;

        DatabaseHelper().insertExercise(
          name: name,
          sets: sets.length,
          weight: weight,
          reps: reps,
          date: date,
          duration: _duration,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text(_timerValue, style: TextStyle(fontSize: 24)),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<_CustomNavigationBarState> _key =
      GlobalKey<_CustomNavigationBarState>();
  // declaration of the key
  double _currentSliderValue = 2;
  String _selectedExercise = 'Select Exercise';

  bool _isAddButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(key: _key),
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
                          exercise: exercise['name'],
                          sets: exercise['sets'],
                          onDelete: (exerciseName) {
                            _deleteExercise(exerciseName);
                          },
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
              bottom: 5,
              right: 5,
              child: CupertinoButton(
                onPressed: () {
                  _showCupertinoModal(context);
                  _key.currentState?._startTimer();

                  setState(() {
                    _isAddButtonPressed = true; // Show "Stop" button
                  });
                },
                child: Icon(CupertinoIcons.add_circled_solid,
                    size: 60, color: CupertinoColors.systemGreen),
              ),
            ),
            Positioned(
              bottom: 5,
              left: 5,
              child: Visibility(
                visible: _isAddButtonPressed,
                child: CupertinoButton(
                  onPressed: () {
                    _key.currentState?._stopTimer();
                  },
                  child: Icon(CupertinoIcons.stop_circle_fill,
                      size: 60, color: CupertinoColors.systemRed),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: 20,
              child: CupertinoButton(
                onPressed: () {
                  DatabaseHelper().deleteDatabase();
                },
                child: Icon(CupertinoIcons.delete_left_fill,
                    size: 60, color: CupertinoColors.systemRed),
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
    // Get the current date
    DateTime currentDate = DateTime.now();

    // Format the date as dd.mm.yyyy
    String formattedDate =
        "${currentDate.day.toString().padLeft(2, '0')}.${currentDate.month.toString().padLeft(2, '0')}.${currentDate.year.toString()}";

    setState(() {
      _exerciseList.add({
        'name': _selectedExercise,
        'date': formattedDate, // Add the formatted date to the exercise entry
        'sets': List.generate(
          _currentSliderValue.toInt(),
          (index) => {'weight': 0, 'reps': 0},
        ),
      });
    });
  }

  void _deleteExercise(String exerciseName) {
    setState(() {
      _exerciseList.removeWhere((exercise) => exercise['name'] == exerciseName);
    });
  }
}

class ExerciseLabel extends StatefulWidget {
  final String exercise;
  final List<Map<String, int>> sets;
  final Function(String exercise) onDelete; // Add onDelete callback

  ExerciseLabel({
    required this.exercise,
    required this.sets,
    required this.onDelete, // Receive onDelete callback in the constructor
  });

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

  void _deleteExercise() {
    setState(() {
      widget.onDelete(widget.exercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Exercise List $_exerciseList");

    return Container(
      padding: EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.exercise,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                    key: Key('exercise_${widget.exercise}_set_${widget.sets}}'),
                    direction: DismissDirection
                        .startToEnd, // Disable dismiss in this direction
                    onDismissed: (direction) {
                      _removeSetFromGlobalList(index);
                    },
                    background: Container(
                      child: Icon(
                        CupertinoIcons.delete,
                        size: 35,
                        color: CupertinoColors.white,
                      ),
                      color: CupertinoColors.systemRed,
                    ),
                    child: ListItem(
                      index: index,
                      weight: set['weight']!,
                      reps: set['reps']!,
                      name: widget.exercise,
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              CupertinoButton.filled(
                  child: Text('Add Set',
                      style: TextStyle(color: CupertinoColors.white)),
                  onPressed: () {
                    setState(() {
                      widget.sets.add({'weight': 0, 'reps': 0});
                    });
                  })
            ],
          ),
          Positioned(
            top: -15,
            right: -20,
            child: CupertinoButton(
              onPressed: () {
                setState(() {
                  _deleteExercise();
                });
              },
              child: Icon(
                CupertinoIcons.delete,
                size: 24,
                color: CupertinoColors.systemRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListItem extends StatefulWidget {
  int index;
  int weight;
  int reps;
  String name;

  ListItem({
    required this.index,
    required this.weight,
    required this.reps,
    required this.name,
  });

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    weightController.text = widget.weight == 0 ? '' : widget.weight.toString();
    repsController.text = widget.reps == 0 ? '' : widget.reps.toString();
  }

  @override
  Widget build(BuildContext context) {
    print("Exercise List $_exerciseList");

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
              onChanged: (value) {
                setState(() {
                  // Update the weight value when the text field changes
                  widget.weight = int.parse(value);
                  // Update the weight value in the global exercise list
                  _updateSet(
                      _exerciseList.indexWhere(
                          (exercise) => exercise['name'] == widget.name),
                      widget.index,
                      widget.weight,
                      widget.reps);
                });
              },
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
              onChanged: (value) {
                setState(() {
                  // Update the reps value when the text field changes
                  widget.reps = int.parse(value);
                  // Update the reps value in the global exercise list
                  _updateSet(
                      _exerciseList.indexWhere(
                          (exercise) => exercise['name'] == widget.name),
                      widget.index,
                      widget.weight,
                      widget.reps);
                });
              },
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

  void _updateSet(int exerciseIndex, int setIndex, int weight, int reps) {
    setState(() {
      _exerciseList[exerciseIndex]['sets'][setIndex]['weight'] = weight;
      _exerciseList[exerciseIndex]['sets'][setIndex]['reps'] = reps;
    });
  }
}

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> workoutDatesList = [];

  Future<void> _loadWorkoutDates() async {
    List<String> dates = await DatabaseHelper().getDates();
    setState(() {
      workoutDatesList = dates;
    });
    print(workoutDatesList);
  }

  @override
  Widget build(BuildContext context) {
    // Load the workout dates from the database
    _loadWorkoutDates();
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: SizedBox(
          width: 150,
          child: CupertinoSearchTextField(
            placeholder: 'Workout durchsuchen',
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
                    final date = workoutDatesList[index];
                    return WorkoutDateItem(date: date);
                  },
                  childCount: workoutDatesList.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutDateItem extends StatefulWidget {
  String date;

  WorkoutDateItem({required this.date});

  @override
  State<WorkoutDateItem> createState() => _WorkoutDateItemState();
}

class _WorkoutDateItemState extends State<WorkoutDateItem> {
  DateTime myDate = DateTime.now();
  String dayOfWeek = '';
  String _duration = '';
  int _totalWeight = 0;
  List<Map<String, dynamic>> _exercises = [];

  @override
  void initState() {
    super.initState();
    myDate = _parseDate(widget.date);
    dayOfWeek = getDayOfWeek(myDate);
    _getDuration();
    _getTotalWeight();
    _getExercises();
  }

  Future<void> _getDuration() async {
    String duration = await DatabaseHelper().getDuration(widget.date);
    setState(() {
      _duration = duration;
    });
  }

  Future<void> _getTotalWeight() async {
    int totalWeight = await DatabaseHelper().getTotalWeight(widget.date);
    setState(() {
      _totalWeight = totalWeight;
    });
  }

  Future<void> _getExercises() async {
    List<Map<String, dynamic>> exercises =
        await DatabaseHelper().getExercisesByDate(widget.date);
    setState(() {
      _exercises = exercises;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the WorkoutDetailPage when the item is pressed
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => WorkoutDetailPage(
              date: widget.date,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBrown,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayOfWeek,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.date,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
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
                      style: TextStyle(fontSize: 15),
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
                      style: TextStyle(fontSize: 15),
                    ),
                  ]),
                )
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return ExerciseListItem(
                      exerciseName: exercise['name'],
                      date: widget.date,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getDayOfWeek(DateTime date) {
    List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    int dayIndex = date.weekday - 1;

    return daysOfWeek[dayIndex];
  }

  DateTime _parseDate(String dateStr) {
    // Split the date string into day, month, and year components
    List<String> dateComponents = dateStr.split('.');
    int day = int.parse(dateComponents[0]);
    int month = int.parse(dateComponents[1]);
    int year = int.parse(dateComponents[2]);

    // Construct a DateTime object from the components
    return DateTime(year, month, day);
  }
}

class ExerciseListItem extends StatefulWidget {
  final String exerciseName;
  final String date;

  ExerciseListItem({required this.exerciseName, required this.date});

  @override
  State<ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {
  int _set = 0;

  @override
  void initState() {
    super.initState();
    _getSets();
  }

  Future<void> _getSets() async {
    int set = await DatabaseHelper().getSets(widget.date, widget.exerciseName);
    setState(() {
      _set = set;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '$_set x ${widget.exerciseName}', // Display sets before exercise name
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }
}

class WorkoutDetailPage extends StatefulWidget {
  final String date;

  WorkoutDetailPage({required this.date});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  int _selectedIndex =
      0; // The initial selected index for the segmented control

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.date),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoSegmentedControl(
              padding: EdgeInsets.all(20),
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
            SizedBox(height: 20),
            _selectedIndex == 0 ? _buildExerciseList() : _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    // You can implement the exercise list view here
    return Center(
      child: Text('Exercise List'),
    );
  }

  Widget _buildStats() {
    // You can implement the statistics view here
    return Center(
      child: Text('Statistics'),
    );
  }
}
