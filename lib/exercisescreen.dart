import 'package:flutter/cupertino.dart';
import 'exercise.dart';

class ExerciseScreen extends StatelessWidget {
  List<Exercise> exercises = [
    Exercise(name: 'Bench Press', description: 'Description of Bench Press'),
    Exercise(name: 'Squat', description: 'Description of Squat'),
    Exercise(name: 'Deadlift', description: 'Description of Deadlift'),
  ];
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: SizedBox(
          width: 150,
          child: CupertinoSearchTextField(
            placeholder: 'Übung durchsuchen',
          ),
        ),
      ),
      child: Center(
        child: ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (BuildContext context, int index) {
            return Exercise(
              name: exercises[index].name,
              description: exercises[index].description,
            );
          },
        ),
      ),
    );
  }
}
