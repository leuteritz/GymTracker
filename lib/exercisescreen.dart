import 'package:flutter/cupertino.dart';
import 'exercise.dart';

class ExerciseScreen extends StatelessWidget {
  List<Exercise> exercises = [
    Exercise(
      name: 'Bench Press',
      description:
          'Lie on training bench, position bar over chest, grasp hands slightly wider than shoulder-width. Slowly lower bar, then press up explosively. Strengthens chest, shoulders and triceps.',
      muscleGroup: 'Chest',
    ),
    Exercise(
      name: 'Squat',
      description:
          'Feet shoulder-width apart, bend knees as if to sit down, then straighten. Strengthens legs and gluteal muscles.',
      muscleGroup: 'Legs',
    ),
    Exercise(
      name: 'Deadlift',
      description:
          'Stand in front of barbell, grasp hands at shoulder width, keep back straight. Bend, lift barbell, straighten hips and knees. Then lower in a controlled manner. Exercises back, legs and buttocks. Ensure correct posture to avoid injury.',
      muscleGroup: 'Back',
    ),
    Exercise(
      name: 'Dumbbell Bench Press',
      description:
          'Lie on bench, hold dumbbells at chest height. Bend arms, lower dumbbells, then press up explosively. Strengthens chest, shoulders and triceps. Keep wrists stable and control movement.',
      muscleGroup: 'Chest',
    ),
    // Add more exercises
  ];

  @override
  Widget build(BuildContext context) {
    Map<String, List<Exercise>> exerciseMap = {};

    // Group exercises by muscle group
    for (var exercise in exercises) {
      if (!exerciseMap.containsKey(exercise.muscleGroup)) {
        exerciseMap[exercise.muscleGroup] = [];
      }
      exerciseMap[exercise.muscleGroup]!.add(exercise);
    }

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
          itemCount: exerciseMap.length,
          itemBuilder: (BuildContext context, int index) {
            var muscleGroup = exerciseMap.keys.toList()[index];
            var exercisesForGroup = exerciseMap[muscleGroup]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    muscleGroup,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                Center(
                  child: Column(
                    children: exercisesForGroup.map((exercise) {
                      return Exercise(
                        name: exercise.name,
                        description: exercise.description,
                        muscleGroup: exercise.muscleGroup,
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
