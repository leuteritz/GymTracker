import 'package:flutter/cupertino.dart';
import 'constants.dart';
import 'exercisetimer.dart';

class ListItem extends StatefulWidget {
  int index;
  int weight;
  int reps;
  String name;
  final GlobalKey<ExerciseTimerState> timerKey;

  ListItem({
    required this.index,
    required this.weight,
    required this.reps,
    required this.name,
    required this.timerKey, // Add this line
  });

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  GlobalKey<ExerciseTimerState> _key = GlobalKey<ExerciseTimerState>();

  @override
  void initState() {
    super.initState();
    weightController.text = widget.weight == 0 ? '' : widget.weight.toString();
    repsController.text = widget.reps == 0 ? '' : widget.reps.toString();
  }

  @override
  Widget build(BuildContext context) {
    print("Exercise List $exerciseList");

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
              width: 70,
              child: Center(
                child:
                    Text('${widget.index + 1}', style: TextStyle(fontSize: 15)),
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CupertinoTextField(
                keyboardType: TextInputType.number,
                controller: weightController,
                onChanged: (value) {
                  setState(() {
                    widget.weight = int.parse(value);
                    _updateSet(
                        exerciseList.indexWhere(
                            (exercise) => exercise['name'] == widget.name),
                        widget.index,
                        widget.weight,
                        widget.reps);
                  });
                },
                placeholder: 'Weight',
                textAlign: TextAlign.center,
                style: TextStyle(color: CupertinoColors.black, fontSize: 15),
                placeholderStyle:
                    TextStyle(color: CupertinoColors.lightBackgroundGray),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CupertinoTextField(
                keyboardType: TextInputType.number,
                controller: repsController,
                onChanged: (value) {
                  setState(() {
                    widget.reps = int.parse(value);
                    _updateSet(
                        exerciseList.indexWhere(
                            (exercise) => exercise['name'] == widget.name),
                        widget.index,
                        widget.weight,
                        widget.reps);
                  });
                },
                placeholder: 'Reps',
                textAlign: TextAlign.center,
                style: TextStyle(color: CupertinoColors.black, fontSize: 15),
                placeholderStyle:
                    TextStyle(color: CupertinoColors.lightBackgroundGray),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateSet(int exerciseIndex, int setIndex, int weight, int reps) {
    setState(() {
      exerciseList[exerciseIndex]['sets'][setIndex]['weight'] = weight;
      exerciseList[exerciseIndex]['sets'][setIndex]['reps'] = reps;

      widget.timerKey.currentState?.startTimer();
    });
    if (hasNoZeroEntries()) {
      widget.timerKey.currentState?.stopTimer();
    }
  }

  bool hasNoZeroEntries() {
    for (var exercise in exerciseList) {
      for (var set in exercise['sets']) {
        if (set['weight'] == 0 || set['reps'] == 0) {
          return false; // Found an entry with 0 weight or reps
        }
      }
    }
    return true; // No entry with 0 weight or reps found
  }
}
