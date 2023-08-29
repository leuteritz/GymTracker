import 'package:flutter/cupertino.dart';
import 'constants.dart';
import 'listitem.dart';

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
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.systemGrey,
          width: 4.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
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
              Row(children: [
                Container(
                    width: 70,
                    child: Center(
                        child: Text('Set', style: TextStyle(fontSize: 17)))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10), // Adjust the padding as needed
                    child: Center(
                      child: Text(
                        'Weight (kg)',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20), // Adjust the padding as needed
                    child: Center(
                      child: Text(
                        'Reps',
                        style: TextStyle(fontSize: 17),
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
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              CupertinoButton.filled(
                  child: Text('Add Set',
                      style: TextStyle(
                          color: CupertinoColors.white, fontSize: 17)),
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
