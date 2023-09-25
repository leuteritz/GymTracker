import 'package:flutter/cupertino.dart';
import 'constants.dart';
import 'listitem.dart';
import 'exercisetimer.dart';

class ExerciseLabel extends StatefulWidget {
  final String exercise;
  final List<Map<String, int>> sets;
  final Function(String exercise) onDelete;

  ExerciseLabel({
    required this.exercise,
    required this.sets,
    required this.onDelete,
  });

  @override
  _ExerciseLabelState createState() => _ExerciseLabelState();
}

class _ExerciseLabelState extends State<ExerciseLabel> {
  GlobalKey<ExerciseTimerState> _key = GlobalKey<ExerciseTimerState>();

  void _removeSetFromGlobalList(int index) {
    setState(() {
      widget.sets.removeAt(index);
      exerciseList.removeWhere((exercise) =>
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
    print("Exercise List $exerciseList");

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.exercise,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(children: [
                Container(
                    width: 70,
                    child: Center(
                        child: Text('Set', style: TextStyle(fontSize: 15)))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10), // Adjust the padding as needed
                    child: Center(
                      child: Text(
                        'Weight (kg)',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 0), // Adjust the padding as needed
                    child: Center(
                      child: Text(
                        'Reps',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
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
                        timerKey: _key),
                  );
                },
              ),
              SizedBox(height: 10),
              CupertinoButton.filled(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text('Add Set',
                      style: TextStyle(
                          color: CupertinoColors.white, fontSize: 15)),
                  onPressed: () {
                    setState(() {
                      widget.sets.add({'weight': 0, 'reps': 0});
                      _key.currentState?.startTimer();
                    });
                  })
            ],
          ),
          Positioned(
            top: -15,
            right: -17,
            child: CupertinoButton(
              onPressed: () {
                setState(() {
                  delete();
                });
              },
              child: Icon(
                CupertinoIcons.delete,
                size: 24,
                color: CupertinoColors.systemRed,
              ),
            ),
          ),
          Positioned(
              top: 6,
              left: 0,
              child: ExerciseTimer(
                exercise: widget.exercise,
                key: _key,
              )),
        ],
      ),
    );
  }

  void delete() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double modalHeight = screenHeight * 0.3;
    final double modalWidth = screenWidth * 0.8;
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: modalWidth, // Set the desired width
            height: modalHeight, // Set the desired height
            child: CupertinoAlertDialog(
              title: Text(
                'Delete?',
                style: TextStyle(),
              ),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(
                    'OK',
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ),
                  onPressed: () {
                    _deleteExercise();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
