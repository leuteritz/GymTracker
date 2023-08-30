import 'package:flutter/cupertino.dart';
import 'exercise.dart';
import 'database.dart';

class ExerciseScreen extends StatefulWidget {
  ExerciseScreen({Key? key}) : super(key: key); // Add Key parameter

  @override
  State<ExerciseScreen> createState() => ExerciseScreenState();
}

class ExerciseScreenState extends State<ExerciseScreen> {
  List<Map<String, dynamic>> exercises = [];

  void insertExercises() async {
    List<Map<String, dynamic>> exercisesToAdd = [
      {
        'name': 'Bench Press',
        'muscle': 'Chest',
        'favorite': 1,
        'description':
            'Lie on training bench, position bar over chest, grasp hands slightly wider than shoulder-width. Slowly lower bar, then press up explosively. Strengthens chest, shoulders and triceps.',
      },
      {
        'name': 'Squat',
        'muscle': 'Legs',
        'favorite': 0,
        'description':
            'Feet shoulder-width apart, bend knees as if to sit down, then straighten. Strengthens legs and gluteal muscles.',
      },
      {
        'name': 'Deadlift',
        'muscle': 'Back',
        'favorite': 0,
        'description':
            'Stand in front of barbell, grasp hands at shoulder width, keep back straight. Bend, lift barbell, straighten hips and knees. Then lower in a controlled manner. Exercises back, legs and buttocks. Ensure correct posture to avoid injury.',
      },
    ];

    for (var exerciseData in exercisesToAdd) {
      final exerciseName = exerciseData['name'];

      // Check if the exercise already exists in the database
      final existingExercise =
          await DatabaseHelper().getExerciseByName(exerciseName);

      if (existingExercise == null) {
        await DatabaseHelper().insertExerciseList(
          name: exerciseData['name'],
          muscle: exerciseData['muscle'],
          favorite: exerciseData['favorite'],
          description: exerciseData['description'],
        );
      }
    }
  }

  void update() {
    fetchExercises();
    print("test 1");
  }

  void fetchExercises() async {
    final List<Map<String, dynamic>> allExerciseData =
        await DatabaseHelper().getAllExerciseListInformation();

    List<Map<String, dynamic>> favoriteExerciseData = [];
    List<Map<String, dynamic>> nonFavoriteExerciseData = [];

    for (var exerciseData in allExerciseData) {
      if (exerciseData['favorite'] == 1) {
        favoriteExerciseData.add(exerciseData);
      } else {
        nonFavoriteExerciseData.add(exerciseData);
      }
    }

    setState(() {
      exercises = favoriteExerciseData + nonFavoriteExerciseData;
    });

    print("favorite exercises: $favoriteExerciseData");
    print("non-favorite exercises: $nonFavoriteExerciseData");
  }

  @override
  void initState() {
    super.initState();
    insertExercises();
    fetchExercises();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Exercise>> exerciseMap = {};

    // Group exercises by muscle group
    exercises.forEach((exercise) {
      final muscleGroup = exercise['muscle'];
      final exerciseName = exercise['name'];
      final exerciseDescription = exercise['description'];

      if (exerciseMap[muscleGroup] == null) {
        exerciseMap[muscleGroup] = [];
      }

      exerciseMap[muscleGroup]!.add(
        Exercise(
          name: exerciseName,
          description: exerciseDescription,
          muscleGroup: muscleGroup,
          fetchExercisesCallback: fetchExercises,
          key: Key(
              exercise['name']), // Use a unique identifier, like exercise name
          // Pass the callback
        ),
      );
    });

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
        itemCount: exerciseMap.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            // Favorites section
            var favoriteExercises = exercises
                .where((exercise) => exercise['favorite'] == 1)
                .toList();

            if (favoriteExercises.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "Favorites" + " (${favoriteExercises.length})",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: favoriteExercises.map((exercise) {
                        return Exercise(
                          name: exercise['name'],
                          description: exercise['description'],
                          muscleGroup: exercise['muscle'],
                          fetchExercisesCallback: fetchExercises,
                          key: Key(exercise[
                              'name']), // Use a unique identifier, like exercise name
                          // Pass the callback
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Favorites" + " (${favoriteExercises.length})",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              );
            }
          } else {
            // Regular muscle group section
            var muscleGroup = exerciseMap.keys.toList()[
                index - 1]; // Subtract 1 to account for "Favorites" section
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
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Column(
                    children: exercisesForGroup.map((exercise) {
                      return Exercise(
                        name: exercise.name,
                        description: exercise.description,
                        muscleGroup: exercise.muscleGroup,
                        fetchExercisesCallback: fetchExercises,
                        key: Key(exercise.name),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }
        },
      )),
    );
  }
}
