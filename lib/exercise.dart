import 'package:flutter/cupertino.dart';
import 'exercisedetailpage.dart';

class Exercise extends StatelessWidget {
  final String name;
  final String description;
  final String muscleGroup;

  Exercise({
    required this.name,
    required this.description,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) =>
                ExerciseDetailPage(exercise: name, description: description),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment
              .topRight, // Align the heart icon to the top right corner

          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description.length > 40
                      ? description.substring(0, 40) + "..."
                      : description,
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
                  CupertinoIcons.heart_fill,
                  color: CupertinoColors.systemRed,
                ),
                onPressed: () {
                  // Handle favorite button press
                  // Implement your favorite functionality here
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
