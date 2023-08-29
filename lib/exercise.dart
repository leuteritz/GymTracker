import 'package:flutter/cupertino.dart';
import 'exercisedetailpage.dart';

class Exercise extends StatefulWidget {
  final String name;
  final String description;
  final String muscleGroup;

  Exercise({
    required this.name,
    required this.description,
    required this.muscleGroup,
  });

  @override
  State<Exercise> createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  bool isPressed = false;

  void _toggleHeart() {
    setState(() {
      isPressed = !isPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ExerciseDetailPage(
                exercise: widget.name, description: widget.description),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.systemGrey,
            width: 4.0,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.3),
              spreadRadius: 10,
              blurRadius: 20,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment
              .topRight, // Align the heart icon to the top right corner

          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.description.length > 40
                      ? widget.description.substring(0, 40) + "..."
                      : widget.description,
                  style: TextStyle(
                      fontSize: 18, color: CupertinoColors.systemGrey),
                ),
              ],
            ),
            Positioned(
              top: -10,
              right: -10,
              child: CupertinoButton(
                padding: EdgeInsets.all(10),
                child: Icon(
                  isPressed ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: CupertinoColors.systemRed,
                ),
                onPressed: () {
                  _toggleHeart();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
