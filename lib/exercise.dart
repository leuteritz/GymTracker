import 'package:flutter/cupertino.dart';
import 'exercisedetailpage.dart';

class Exercise extends StatelessWidget {
  final String name;
  final String description;
  final String muscleGroup; // Add this line

  Exercise({
    required this.name,
    required this.description,
    required this.muscleGroup, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the WorkoutDetailPage when the item is pressed
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
          color: Color.fromARGB(255, 60, 60, 60),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
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
              description.length > 50
                  ? description.substring(0, 50) + "..."
                  : description,
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
