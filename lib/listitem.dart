import 'package:flutter/cupertino.dart';
import 'constants.dart';

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
    print("Exercise List $exerciseList");

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
              width: 70,
              child: Center(
                child:
                    Text('${widget.index + 1}', style: TextStyle(fontSize: 17)),
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20), // Adjust the padding as needed
              child: CupertinoTextField(
                keyboardType: TextInputType.number,
                controller: weightController,
                onChanged: (value) {
                  setState(() {
                    // Update the weight value when the text field changes
                    widget.weight = int.parse(value);
                    // Update the weight value in the global exercise list
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
                style: TextStyle(color: CupertinoColors.black, fontSize: 17),
                placeholderStyle:
                    TextStyle(color: CupertinoColors.lightBackgroundGray),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
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
                    // Update the reps value when the text field changes
                    widget.reps = int.parse(value);
                    // Update the reps value in the global exercise list
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
                style: TextStyle(color: CupertinoColors.black, fontSize: 17),
                placeholderStyle:
                    TextStyle(color: CupertinoColors.lightBackgroundGray),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
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
    });
  }
}
